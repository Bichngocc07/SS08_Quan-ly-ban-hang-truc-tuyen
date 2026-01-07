-- =======================
-- PHẦN A – TRUY VẤN CƠ BẢN
-- =======================

-- 1. Danh sách tất cả danh mục
SELECT * FROM categories;

-- 2. Đơn hàng trạng thái COMPLETED
SELECT *
FROM orders
WHERE status = 'Completed';

-- 3. Danh sách sản phẩm, sắp xếp giá giảm dần
SELECT *
FROM products
ORDER BY price DESC;

-- 4. 5 sản phẩm giá cao nhất, bỏ qua 2 sản phẩm đầu
SELECT *
FROM products
ORDER BY price DESC
LIMIT 5 OFFSET 2;


-- =========================
-- PHẦN B – TRUY VẤN NÂNG CAO
-- =========================

-- 5. Sản phẩm kèm tên danh mục
SELECT p.product_name, p.price, c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- 6. Danh sách đơn hàng (order_id, order_date, customer_name, status)
SELECT o.order_id, o.order_date, c.customer_name, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- 7. Tổng số lượng sản phẩm trong từng đơn hàng
SELECT order_id, SUM(quantity) AS total_quantity
FROM order_items
GROUP BY order_id;

-- 8. Thống kê số đơn hàng của mỗi khách hàng
SELECT customer_id, COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id;

-- 9. Khách hàng có tổng số đơn hàng ≥ 2
SELECT customer_id, COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 2;

-- 10. Giá trung bình, thấp nhất, cao nhất theo danh mục
SELECT category_id,
       AVG(price) AS avg_price,
       MIN(price) AS min_price,
       MAX(price) AS max_price
FROM products
GROUP BY category_id;


-- =========================
-- PHẦN C – TRUY VẤN LỒNG
-- =========================

-- 11. Sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT *
FROM products
WHERE price > (
    SELECT AVG(price) FROM products
);

-- 12. Khách hàng đã từng đặt ít nhất một đơn hàng (KHÔNG JOIN)
SELECT *
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM orders
);

-- 13. Đơn hàng có tổng số lượng sản phẩm lớn nhất
SELECT order_id
FROM order_items
GROUP BY order_id
HAVING SUM(quantity) = (
    SELECT MAX(total_qty)
    FROM (
        SELECT SUM(quantity) AS total_qty
        FROM order_items
        GROUP BY order_id
    ) t
);

-- 14. Tên khách hàng đã mua sản phẩm thuộc danh mục có giá trung bình cao nhất
SELECT DISTINCT c.customer_name
FROM customers c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders o
    WHERE o.order_id IN (
        SELECT oi.order_id
        FROM order_items oi
        WHERE oi.product_id IN (
            SELECT p.product_id
            FROM products p
            WHERE p.category_id = (
                SELECT category_id
                FROM products
                GROUP BY category_id
                ORDER BY AVG(price) DESC
                LIMIT 1
            )
        )
    )
);

-- 15. Từ bảng tạm: tổng số lượng sản phẩm đã mua của từng khách hàng
SELECT customer_id, SUM(total_qty) AS total_products
FROM (
    SELECT o.customer_id, SUM(oi.quantity) AS total_qty
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) t
GROUP BY customer_id;

-- 16. Sản phẩm có giá cao nhất (Subquery trả về 1 giá trị – KHÔNG lỗi)
SELECT *
FROM products
WHERE price = (
    SELECT MAX(price)
    FROM products
);
