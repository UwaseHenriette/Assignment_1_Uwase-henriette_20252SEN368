# PLSQL Assignment One — Sunrise Supermarket

**Name:** Uwase Henriette
**Student ID:** 20252SEN368
**Group:** I
**DBMS used:** Oracle 10g

## Summary

This project builds a relational schema for Sunrise Supermarket's customers,
products, orders, and order items, populates it with sample data, and answers
management's questions about customers, purchases, and sales trends using
JOINs, a CTE, and window functions.

## How to run it

1. Connect to Oracle: `sqlplus username/password@database_name`
2. Run the schema + data script: `@01_schema_and_data.sql`
3. Run the queries script: `@02_queries.sql`

## Business scenario

Sunrise Supermarket sells products to customers who place orders containing
one or more items. Management wants to understand who their customers are,
what they buy, and how sales are trending over time.

- **customers** — 6 customers (one, Patrick Niyonzima, has no orders — kept deliberately to demonstrate the LEFT JOIN)
- **products** — 8 products across 3 categories (Bakery, Groceries, Grains)
- **orders** — 15 orders
- **order_items** — 25 order items, spread across August 2026

## Queries, explanations, and business interpretation

### JOIN queries

**1. Every order with customer name, city, and order date (INNER JOIN)**
```sql
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;
```
*Explanation:* Joins `orders` to `customers` on `customer_id` so each order shows the customer who placed it, instead of just a raw ID.

*Results (15 rows):*

| order_id | customer_name | city | order_date |
|---|---|---|---|
| 1 | Uwase Henriette | Kigali | 2026-08-01 |
| 2 | Jean Bosco | Musanze | 2026-08-02 |
| 3 | Uwase Henriette | Kigali | 2026-08-05 |
| 4 | Aline Umutoni | Kigali | 2026-08-06 |
| 5 | Eric Habimana | Huye | 2026-08-07 |
| 6 | Jean Bosco | Musanze | 2026-08-10 |
| 7 | Grace Mukamana | Rubavu | 2026-08-11 |
| 8 | Uwase Henriette | Kigali | 2026-08-14 |
| 9 | Aline Umutoni | Kigali | 2026-08-15 |
| 10 | Eric Habimana | Huye | 2026-08-18 |
| 11 | Grace Mukamana | Rubavu | 2026-08-20 |
| 12 | Jean Bosco | Musanze | 2026-08-22 |
| 13 | Aline Umutoni | Kigali | 2026-08-25 |
| 14 | Uwase Henriette | Kigali | 2026-08-28 |
| 15 | Grace Mukamana | Rubavu | 2026-08-30 |

*Business interpretation:* Gives management a readable order log — who ordered what, from where, and when — without having to look up customer IDs separately.

**2. Every order item with product name, category, price, and quantity (JOIN)**
```sql
SELECT
    oi.order_item_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id, oi.order_item_id;
```
*Explanation:* Joins `order_items` to `products` on `product_id` to show exactly what was in each order line.

*Results (25 rows, first 10 shown — full 25 shown when you run it yourself):*

| order_item_id | product_name | category | price | quantity |
|---|---|---|---|---|
| 1 | Cake | Bakery | 5.00 | 3 |
| 2 | Cooking Oil | Groceries | 4.20 | 2 |
| 3 | Bread | Bakery | 1.50 | 1 |
| 4 | Sugar | Groceries | 1.00 | 1 |
| 5 | Beans | Grains | 1.80 | 4 |
| 6 | Croissant | Bakery | 1.10 | 2 |
| 7 | Salt | Groceries | 0.50 | 3 |
| 8 | Cake | Bakery | 5.00 | 2 |
| 9 | Rice | Grains | 2.30 | 2 |
| 10 | Cooking Oil | Groceries | 4.20 | 1 |

*Business interpretation:* Useful for inventory tracking and understanding which product categories sell the most (Bakery and Groceries appear most frequently in this data).

**3. All customers and their orders, including customers with no orders (LEFT JOIN)**
```sql
SELECT c.customer_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name;
```
*Explanation:* A LEFT JOIN keeps every row from `customers` even when there's no matching row in `orders`, unlike an INNER JOIN which would drop customers with zero orders.

*Results (16 rows):*

| customer_name | order_id | order_date |
|---|---|---|
| Aline Umutoni | 4 | 2026-08-06 |
| Aline Umutoni | 9 | 2026-08-15 |
| Aline Umutoni | 13 | 2026-08-25 |
| Eric Habimana | 5 | 2026-08-07 |
| Eric Habimana | 10 | 2026-08-18 |
| Grace Mukamana | 7 | 2026-08-11 |
| Grace Mukamana | 11 | 2026-08-20 |
| Grace Mukamana | 15 | 2026-08-30 |
| Jean Bosco | 2 | 2026-08-02 |
| Jean Bosco | 6 | 2026-08-10 |
| Jean Bosco | 12 | 2026-08-22 |
| **Patrick Niyonzima** | **NULL** | **NULL** |
| Uwase Henriette | 1 | 2026-08-01 |
| Uwase Henriette | 3 | 2026-08-05 |
| Uwase Henriette | 8 | 2026-08-14 |
| Uwase Henriette | 14 | 2026-08-28 |

*Business interpretation:* Surfaces customers who have never placed an order (Patrick Niyonzima, in this case) — useful for targeted marketing or re-engagement campaigns.

### CTE query

**1. Customers above average spend**
```sql
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
```
*Explanation:* The CTE (`customer_totals`) computes each customer's total spend first — quantity × price, summed across all their order items. The outer query then filters down to only the customers spending above the average of everyone's totals (average across all 5 spending customers is about 26.4).

*Results (2 rows):*

| customer_id | customer_name | total_spend |
|---|---|---|
| 1 | Uwase Henriette | 63.40 |
| 3 | Aline Umutoni | 28.40 |

*Business interpretation:* Identifies the store's higher-value customers (Uwase Henriette and Aline Umutoni), useful for loyalty programs or VIP treatment.

### Window-function queries

**1. Rank customers by total amount spent**
```sql
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
```
*Explanation:* Reuses the same spend-totals logic as the CTE query, then applies `RANK()` to give every customer a position based on how much they've spent, highest first.

*Results (5 rows):*

| customer_id | customer_name | total_spent | spend_rank |
|---|---|---|---|
| 1 | Uwase Henriette | 63.40 | 1 |
| 3 | Aline Umutoni | 28.40 | 2 |
| 2 | Jean Bosco | 15.90 | 3 |
| 4 | Eric Habimana | 13.60 | 4 |
| 5 | Grace Mukamana | 10.70 | 5 |

*Business interpretation:* A straightforward leaderboard of top spenders that management can use to prioritize outreach or rewards.

**2. Number each customer's orders in the order placed**
```sql
SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_sequence
FROM orders
ORDER BY customer_id, order_sequence;
```
*Explanation:* `ROW_NUMBER()` numbers each customer's own orders 1, 2, 3... in chronological order. `PARTITION BY customer_id` makes the numbering restart for every customer instead of continuing across the whole table.

*Results (15 rows):*

| customer_id | order_id | order_date | order_sequence |
|---|---|---|---|
| 1 | 1 | 2026-08-01 | 1 |
| 1 | 3 | 2026-08-05 | 2 |
| 1 | 8 | 2026-08-14 | 3 |
| 1 | 14 | 2026-08-28 | 4 |
| 2 | 2 | 2026-08-02 | 1 |
| 2 | 6 | 2026-08-10 | 2 |
| 2 | 12 | 2026-08-22 | 3 |
| 3 | 4 | 2026-08-06 | 1 |
| 3 | 9 | 2026-08-15 | 2 |
| 3 | 13 | 2026-08-25 | 3 |
| 4 | 5 | 2026-08-07 | 1 |
| 4 | 10 | 2026-08-18 | 2 |
| 5 | 7 | 2026-08-11 | 1 |
| 5 | 11 | 2026-08-20 | 2 |
| 5 | 15 | 2026-08-30 | 3 |

*Business interpretation:* Lets the business identify a customer's 1st, 2nd, 3rd order, etc. — useful for first-purchase promotions or loyalty milestones (e.g. "reward on your 3rd order").

**3. Running total of revenue over time**
```sql
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
```
*Explanation:* The CTE first calculates the revenue of each individual order. The outer query then adds a running `SUM()` ordered by date, so each row shows total revenue accumulated up to and including that order. (Order 15 has no line items in this sample data, so it doesn't appear here.)

*Results (14 rows):*

| order_id | order_date | order_revenue | running_total |
|---|---|---|---|
| 1 | 2026-08-01 | 23.40 | 23.40 |
| 2 | 2026-08-02 | 2.50 | 25.90 |
| 3 | 2026-08-05 | 9.40 | 35.30 |
| 4 | 2026-08-06 | 11.50 | 46.80 |
| 5 | 2026-08-07 | 8.80 | 55.60 |
| 6 | 2026-08-10 | 8.40 | 64.00 |
| 7 | 2026-08-11 | 5.40 | 69.40 |
| 8 | 2026-08-14 | 26.00 | 95.40 |
| 9 | 2026-08-15 | 14.90 | 110.30 |
| 10 | 2026-08-18 | 4.80 | 115.10 |
| 11 | 2026-08-20 | 5.30 | 120.40 |
| 12 | 2026-08-22 | 5.00 | 125.40 |
| 13 | 2026-08-25 | 2.00 | 127.40 |
| 14 | 2026-08-28 | 4.60 | 132.00 |

*Business interpretation:* Shows cumulative revenue growth over the period covered by the data — a simple sales trend view for management to track performance over time. Total revenue for the month reaches 132.00.

**4. Days between each customer's current and previous order**
```sql
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
```
*Explanation:* `LAG()` pulls each customer's previous order date into the same row as their current order. Subtracting two DATE values in Oracle returns the number of days between them directly. Customers with only one order are automatically excluded, since their `previous_order_date` is `NULL` and gets filtered out by the `WHERE` clause.

*Results (10 rows):*

| customer_id | order_id | order_date | previous_order_date | days_since_previous_order |
|---|---|---|---|---|
| 1 | 3 | 2026-08-05 | 2026-08-01 | 4 |
| 1 | 8 | 2026-08-14 | 2026-08-05 | 9 |
| 1 | 14 | 2026-08-28 | 2026-08-14 | 14 |
| 2 | 6 | 2026-08-10 | 2026-08-02 | 8 |
| 2 | 12 | 2026-08-22 | 2026-08-10 | 12 |
| 3 | 9 | 2026-08-15 | 2026-08-06 | 9 |
| 3 | 13 | 2026-08-25 | 2026-08-15 | 10 |
| 4 | 10 | 2026-08-18 | 2026-08-07 | 11 |
| 5 | 11 | 2026-08-20 | 2026-08-11 | 9 |
| 5 | 15 | 2026-08-30 | 2026-08-20 | 10 |

*Business interpretation:* Measures purchase frequency per customer — helps flag customers who are ordering less often than usual (a possible churn signal) or identify a typical reorder cycle. Most customers here reorder roughly every 8–14 days.

## Challenges and resolutions

- **Demonstrating the LEFT JOIN meaningfully:** all customers initially ended up with at least one order, which would have made the LEFT JOIN look identical to an INNER JOIN. Resolved by keeping one customer (Patrick Niyonzima) with zero orders on purpose, so the query genuinely proves it preserves unmatched rows.
- **Date arithmetic for the days-between-orders query:** confirmed that in Oracle, subtracting one `DATE` from another (`order_date - previous_order_date`) returns a plain number representing days, so no extra conversion function was needed.
- **Excluding customers with only one order from the LAG query:** rather than adding a separate count check, filtering on `WHERE previous_order_date IS NOT NULL` was enough — a customer's first order always has a `NULL` previous date, so single-order customers are naturally excluded.

## Files

- `01_schema_and_data.sql` — table creation + sample data
- `02_queries.sql` — all required JOIN / CTE / window-function queries
- `README.md` — this file
