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