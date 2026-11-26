-- ==============================================================
-- Project: Manufacturing Operations & BI Analytics
-- Ticket: MIS-001 - Business Data Exploration
-- Database: manufacturing_bi (PostgreSQL 18)
-- Dataset: Synthetic data, version 1.0.0
-- Purpose: Learn about customers, sales orders and production
-- ==============================================================

-- Task 1.1 - First Look
-- Show five records from each table.

SELECT *
FROM mis.customers
ORDER BY customer_id
LIMIT 5;

SELECT *
FROM mis.sales_orders
ORDER BY sales_order_id
LIMIT 5;

SELECT *
FROM mis.production_orders
ORDER BY production_order_id
LIMIT 5;


-- Task 1.2 - Record Counts
-- Count the records in the three tables.

SELECT COUNT(*) AS customer_count
FROM mis.customers;

SELECT COUNT(*) AS sales_order_count
FROM mis.sales_orders;

SELECT COUNT(*) AS production_order_count
FROM mis.production_orders;


-- Task 1.3 - Understand the Columns
-- The primary keys and useful columns are described in the findings.
-- These extra queries show values found during the first look.

SELECT DISTINCT c.market
FROM mis.customers c
ORDER BY c.market;

SELECT DISTINCT po.status
FROM mis.production_orders po
ORDER BY po.status;

-- List customers who have at least one sales order.
SELECT DISTINCT so.customer_id
FROM mis.sales_orders so
ORDER BY so.customer_id;

-- Extra exploration: Count production orders with non-good output.
-- This counts PRODUCTION ORDERS, not the number of bad units.
SELECT COUNT(*) AS orders_with_non_good_output
FROM mis.production_orders po
WHERE po.produced_qty > po.good_qty;


-- Task 1.4 - Customer Markets
-- Count customers in each market.

SELECT
    c.market,
    COUNT(*) AS customer_count
FROM mis.customers c
GROUP BY c.market
ORDER BY customer_count DESC;


-- Task 1.5 - Sales Order History
-- Find the first and last order dates.

SELECT
    MIN(so.order_date) AS earliest_order_date,
    MAX(so.order_date) AS latest_order_date
FROM mis.sales_orders so;

-- Count orders by calendar year.
SELECT
    EXTRACT(YEAR FROM so.order_date) AS order_year,
    COUNT(*) AS order_count
FROM mis.sales_orders so
GROUP BY order_year
ORDER BY order_year;


-- Task 1.6 - Production Orders
-- Count production orders by status.

SELECT
    po.status,
    COUNT(*) AS status_count
FROM mis.production_orders po
GROUP BY po.status
ORDER BY po.status;


-- Task 1.7 - Sales Orders by Customer Market
-- Join customers and sales orders and count orders by market.
-- We count ORDERS here, not unique customers.

SELECT
    c.market,
    COUNT(*) AS order_count
FROM mis.customers c
JOIN mis.sales_orders so
    ON c.customer_id = so.customer_id
GROUP BY c.market
ORDER BY order_count DESC;


-- Task 1.8 - Order Structure
-- Find five orders with the highest number of order lines.
-- The second sorting column gives a stable result when counts are tied.

SELECT
    so.sales_order_id,
    COUNT(*) AS order_line_count
FROM mis.sales_orders so
JOIN mis.sales_order_lines sol
    ON so.sales_order_id = sol.sales_order_id
GROUP BY so.sales_order_id
ORDER BY order_line_count DESC, so.sales_order_id
LIMIT 5;

-- Count how many orders have 1, 2 or 3 lines.
SELECT
    order_line_count,
    COUNT(*) AS sales_order_count
FROM (
    SELECT
        so.sales_order_id,
        COUNT(*) AS order_line_count
    FROM mis.sales_orders so
    JOIN mis.sales_order_lines sol
        ON so.sales_order_id = sol.sales_order_id
    GROUP BY so.sales_order_id
) AS lines_per_order
GROUP BY order_line_count
ORDER BY order_line_count;


-- Task 1.9 - Initial Observations
-- Business findings are in docs/MIS-001_findings.md.
-- Extra exploration: Which currencies are used for sales orders?

SELECT DISTINCT so.order_currency
FROM mis.sales_orders so
ORDER BY so.order_currency;

-- Count sales orders by market and currency.
-- Currency does not tell us where a shipment was delivered.
SELECT
    c.market,
    so.order_currency,
    COUNT(*) AS order_count
FROM mis.customers c
JOIN mis.sales_orders so
    ON c.customer_id = so.customer_id
GROUP BY c.market, so.order_currency
ORDER BY c.market, so.order_currency;
