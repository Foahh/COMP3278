#!/bin/bash

# Configuration
DOCKER_CONTAINER="apc_mysql"
MYSQL_USER="student"
MYSQL_PASS="student123"
MYSQL_DB="apc_printing"

run_query() {
    local query_num=$1
    local query=$2
    echo "#block(breakable: false)["
    echo "== ($query_num)"
    echo ""
    echo '```sql'
    echo "$query"
    echo '```'
    echo '```'
    docker exec -i ${DOCKER_CONTAINER} mysql -u ${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DB} -t -e "$query" 2>/dev/null
    echo '```'
    echo "]"
}
run_query 1 "
-- List all available products in the system ordered by price.
SELECT
    product_id,
    description,
    price
FROM
    Product
ORDER BY
    price ASC;
"

run_query 2 "
-- Find the user IDs and names of all customers.
SELECT
    au.user_id,
    au.name
FROM
    Customer c
    JOIN AppUser au ON c.user_id = au.user_id;
"

run_query 3 "
-- Find the customer name, phone numbers, and order ID of all orders that has “New” in the status.
-- If the customer has multiple phone numbers, concatenate them by commas in the result.
-- (Hint: use GROUP_CONCAT)
SELECT
    au.name,
    GROUP_CONCAT(cp.phone) AS phone,
    po.order_id
FROM
    PrintOrder po
    JOIN AppUser au ON po.user_id = au.user_id
    LEFT JOIN CustomerPhone cp ON po.user_id = cp.user_id
WHERE
    po.status LIKE '%New%'
GROUP BY
    po.order_id,
    au.name;
"

run_query 4 "
-- List all items of order ID 3, showing the item ID, quantity, product description, and the subtotal.
-- Subtotal equals to the product price times quantity.
SELECT
    i.item_id,
    i.quantity,
    p.description,
    (i.quantity * p.price) AS subtotal
FROM
    Item i
    JOIN Product p ON i.product_id = p.product_id
WHERE
    i.order_id = 3;
"

run_query 5 "
-- List all orders by customer with user ID 5, showing the order ID, status, number of items (sum of quantity), and the total amount.
SELECT
    po.order_id,
    po.status,
    SUM(i.quantity) AS num_items,
    SUM(i.quantity * p.price) AS total_amount
FROM
    PrintOrder po
    LEFT JOIN Item i ON po.order_id = i.order_id
    LEFT JOIN Product p ON i.product_id = p.product_id
WHERE
    po.user_id = 5
GROUP BY
    po.order_id,
    po.status;
"

run_query 6 "
-- Find the names of all users that is a customer and an admin user.
SELECT
    au.user_id,
    au.name
FROM
    Customer c
    JOIN Admin a ON c.user_id = a.user_id
    JOIN AppUser au ON c.user_id = au.user_id;
"

run_query 7 "
-- Find all admin users is not a supervisor.
SELECT
    a.user_id,
    au.name
FROM
    Admin a
    JOIN AppUser au ON a.user_id = au.user_id
WHERE
    a.user_id NOT IN (
        SELECT
            DISTINCT supervisor_id
        FROM
            Admin
        WHERE
            supervisor_id IS NOT NULL
    );
"

run_query 8 "
-- List all albums owned by admin users, in a descending order of the number of images in the album.
-- If there exist two albums with the same number of images, order them in descending order of the creation date.
SELECT
    al.*,
    COUNT(img.image_id) AS num_images
FROM
    Album al
    JOIN Admin ad ON al.user_id = ad.user_id
    LEFT JOIN Image img ON al.album_id = img.album_id
GROUP BY
    al.album_id,
    al.name,
    al.creation_date,
    al.user_id
ORDER BY
    num_images DESC,
    al.creation_date DESC;
"

run_query 9 "
-- Find the number of times each of the images in album ID 1 is included in an order.
-- An image that is placed in the same order multiple times should be counted as once only.
-- Images that has never been ordered must also be shown.
SELECT
    img.*,
    COUNT(DISTINCT i.order_id) AS order_count
FROM
    Image img
    LEFT JOIN Item i ON img.album_id = i.album_id
    AND img.image_id = i.image_id
WHERE
    img.album_id = 1
GROUP BY
    img.album_id,
    img.image_id,
    img.filename;
"

run_query 10 "
-- Find all customer name of orders that has the greatest number of order items (not considering quantity).
SELECT
    DISTINCT au.name
FROM
    PrintOrder po
    JOIN Item i ON po.order_id = i.order_id
    JOIN AppUser au ON po.user_id = au.user_id
GROUP BY
    po.order_id,
    au.user_id,
    au.name
HAVING
    COUNT(i.item_id) = (
        SELECT
            MAX(item_count)
        FROM
            (
                SELECT
                    COUNT(item_id) AS item_count
                FROM
                    Item
                GROUP BY
                    order_id
            ) AS counts
    );
"
