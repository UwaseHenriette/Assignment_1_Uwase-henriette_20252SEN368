-- ============================================================
-- Sunrise Supermarket - Assignment 1
-- Schema + Sample Data
-- DBMS: Oracle 10g
-- ============================================================

-- Drop tables if they already exist (clean re-run)
-- (ignore ORA-00942 "table or view does not exist" errors on first run)
DROP TABLE order_items;
DROP TABLE orders;
DROP TABLE products;
DROP TABLE customers;

-- ------------------------------------------------------------
-- TABLES
-- ------------------------------------------------------------

CREATE TABLE customers (
    customer_id   NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100),
    email         VARCHAR2(100),
    city          VARCHAR2(50)
);

CREATE TABLE products (
    product_id    NUMBER PRIMARY KEY,
    product_name  VARCHAR2(100),
    category      VARCHAR2(50),
    price         NUMBER(10,2)
);

CREATE TABLE orders (
    order_id      NUMBER PRIMARY KEY,
    customer_id   NUMBER REFERENCES customers(customer_id),
    order_date    DATE
);

CREATE TABLE order_items (
    order_item_id NUMBER PRIMARY KEY,
    order_id      NUMBER REFERENCES orders(order_id),
    product_id    NUMBER REFERENCES products(product_id),
    quantity      NUMBER
);

-- ------------------------------------------------------------
-- SAMPLE DATA
-- 6 customers (one with zero orders, to prove the LEFT JOIN works)
-- 8 products across 3 categories: Bakery, Groceries, Grains
-- 15 orders | 25 order items across multiple dates
-- ------------------------------------------------------------

-- Customers
INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(1, 'Uwase Henriette', 'uwase.henriette@example.com', 'Kigali');
INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(2, 'Jean Bosco',       'jean.bosco@example.com',       'Musanze');
INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(3, 'Aline Umutoni',    'aline.umutoni@example.com',    'Kigali');
INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(4, 'Eric Habimana',    'eric.habimana@example.com',    'Huye');
INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(5, 'Grace Mukamana',   'grace.mukamana@example.com',   'Rubavu');
INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(6, 'Patrick Niyonzima','patrick.niyonzima@example.com','Nyagatare');
-- Note: customer 6 has no orders below, on purpose, to demonstrate the LEFT JOIN

-- Products (8, across 3 categories)
INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Cake',        'Bakery',    5.00);
INSERT INTO products (product_id, product_name, category, price) VALUES
(2, 'Bread',       'Bakery',    1.50);
INSERT INTO products (product_id, product_name, category, price) VALUES
(3, 'Croissant',   'Bakery',    1.10);
INSERT INTO products (product_id, product_name, category, price) VALUES
(4, 'Cooking Oil', 'Groceries', 4.20);
INSERT INTO products (product_id, product_name, category, price) VALUES
(5, 'Sugar',       'Groceries', 1.00);
INSERT INTO products (product_id, product_name, category, price) VALUES
(6, 'Salt',        'Groceries', 0.50);
INSERT INTO products (product_id, product_name, category, price) VALUES
(7, 'Beans',       'Grains',    1.80);
INSERT INTO products (product_id, product_name, category, price) VALUES
(8, 'Rice',        'Grains',    2.30);

-- Orders (15, spread across multiple dates)
INSERT INTO orders (order_id, customer_id, order_date) VALUES (1,  1, DATE '2026-08-01');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (2,  2, DATE '2026-08-02');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (3,  1, DATE '2026-08-05');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (4,  3, DATE '2026-08-06');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (5,  4, DATE '2026-08-07');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (6,  2, DATE '2026-08-10');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (7,  5, DATE '2026-08-11');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (8,  1, DATE '2026-08-14');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (9,  3, DATE '2026-08-15');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (10, 4, DATE '2026-08-18');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (11, 5, DATE '2026-08-20');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (12, 2, DATE '2026-08-22');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (13, 3, DATE '2026-08-25');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (14, 1, DATE '2026-08-28');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (15, 5, DATE '2026-08-30');

-- Order Items (25, across the 15 orders)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (1,  1, 1, 3);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (2,  1, 4, 2);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (3,  2, 2, 1);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (4,  2, 5, 1);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (5,  3, 7, 4);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (6,  3, 3, 2);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (7,  4, 6, 3);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (8,  4, 1, 2);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (9,  5, 8, 2);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (10, 5, 4, 1);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (11, 6, 2, 2);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (12, 6, 7, 3);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (13, 7, 5, 1);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (14, 7, 3, 4);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (15, 8, 1, 5);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (16, 8, 6, 2);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (17, 9, 4, 3);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (18, 9, 8, 1);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (19, 10, 2, 2);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (20, 10, 7, 1);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (21, 11, 3, 3);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (22, 11, 5, 2);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (23, 12, 1, 1);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (24, 13, 6, 4);
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES (25, 14, 8, 2);

COMMIT;
