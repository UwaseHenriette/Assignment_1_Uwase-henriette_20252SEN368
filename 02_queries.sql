-- ============================================================
-- Sunrise Supermarket - Assignment 1
-- JOIN / CTE / Window-function Queries
-- DBMS: Oracle 10g
-- ============================================================


-- ------------------------------------------------------------
-- JOIN QUERY 1
-- List every order with the customer's name, city, and order date
-- (INNER JOIN: orders + customers)
-- ------------------------------------------------------------
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;


-- ------------------------------------------------------------
-- JOIN QUERY 2
-- List every order item with product name, category, price, and quantity
-- (JOIN: order_items + products)
-- ------------------------------------------------------------
SELECT
    oi.order_item_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id, oi.order_item_id;


-- ------------------------------------------------------------
-- JOIN QUERY 3
-- List all customers and their orders where they exist,
-- including customers with no orders
-- (LEFT JOIN: customers + orders)
-- ------------------------------------------------------------
SELECT c.customer_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name;


-- ------------------------------------------------------------
-- CTE QUERY 1
-- Calculate each customer's total spend (quantity x price) and
-- return customers above average spend.
-- ------------------------------------------------------------
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spend
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spend
FROM customer_totals
WHERE total_spend > (SELECT AVG(total_spend) FROM customer_totals)
ORDER BY total_spend DESC;


-- ------------------------------------------------------------
-- WINDOW-FUNCTION QUERY 1
-- Rank customers by total amount spent, highest first.
-- ------------------------------------------------------------
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM customer_totals
ORDER BY spend_rank;


-- ------------------------------------------------------------
-- WINDOW-FUNCTION QUERY 2
-- Number each customer's orders in the order placed.
-- ------------------------------------------------------------
SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_sequence
FROM orders
ORDER BY customer_id, order_sequence;


-- ------------------------------------------------------------
-- WINDOW-FUNCTION QUERY 3
-- Show a running total of revenue over time, ordered by order date.
-- ------------------------------------------------------------
WITH order_revenue AS (
    SELECT
        o.order_id,
        o.order_date,
        SUM(oi.quantity * p.price) AS order_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY o.order_id, o.order_date
)
SELECT
    order_id,
    order_date,
    order_revenue,
    SUM(order_revenue) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM order_revenue
ORDER BY order_date, order_id;


-- ------------------------------------------------------------
-- WINDOW-FUNCTION QUERY 4
-- For each customer with more than one order, show days between
-- the current and previous order.
-- ------------------------------------------------------------
WITH customer_order_gaps AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date
    FROM orders
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,
    (order_date - previous_order_date) AS days_since_previous_order
FROM customer_order_gaps
WHERE previous_order_date IS NOT NULL
ORDER BY customer_id, order_date;
