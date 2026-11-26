-- =============================================================
-- Project: Manufacturing Operations & BI Analytics
-- Ticket: MIS-002 — Production Data Exploration
-- Purpose: Explore production lines, orders and operations
-- Source: Synthetic data, Moravia Industrial Systems
-- =============================================================

-- Task 2.1 — First Look
-- One row in production_lines = one production line.
-- One row in production_orders = one production order.
-- One row in production_operations = one operation record.

SELECT *
FROM mis.production_lines
LIMIT 5;

SELECT *
FROM mis.production_orders
LIMIT 5;

SELECT *
FROM mis.production_operations
LIMIT 5;


-- Task 2.2 — Record Counts

SELECT COUNT(*) AS production_line_count
FROM mis.production_lines;

SELECT COUNT(*) AS production_order_count
FROM mis.production_orders;

SELECT COUNT(*) AS production_operation_count
FROM mis.production_operations;


-- Task 2.3 — Operation Types
-- Count operation records for each type.

SELECT
    pop.operation_type,
    COUNT(*) AS operation_count
FROM mis.production_operations AS pop
GROUP BY pop.operation_type
ORDER BY pop.operation_type;


-- Task 2.4 — Production Dates
-- Planned start dates for all production orders.

SELECT
    MIN(po.planned_start_date) AS earliest_planned_start,
    MAX(po.planned_start_date) AS latest_planned_start
FROM mis.production_orders AS po;

-- Actual completion dates for completed production orders only.

SELECT
    MIN(po.actual_completion_date) AS earliest_completion_date,
    MAX(po.actual_completion_date) AS latest_completion_date
FROM mis.production_orders AS po
WHERE po.status = 'Completed';


-- Task 2.5 — Production Order Status
-- This query was completed during the ticket and added to the final file.

SELECT
    po.status,
    COUNT(*) AS status_count
FROM mis.production_orders AS po
GROUP BY po.status
ORDER BY status_count DESC;


-- Task 2.6 — Orders by Production Line

SELECT
    pl.line_code,
    COUNT(*) AS production_order_count
FROM mis.production_lines AS pl
JOIN mis.production_orders AS po
    ON pl.line_id = po.line_id
GROUP BY pl.line_code
ORDER BY production_order_count DESC;


-- Task 2.7 — Status by Production Line

SELECT
    pl.line_code,
    po.status,
    COUNT(*) AS status_count
FROM mis.production_lines AS pl
JOIN mis.production_orders AS po
    ON pl.line_id = po.line_id
GROUP BY pl.line_code, po.status
ORDER BY pl.line_code, po.status;


-- Task 2.8 — Operations per Production Order
-- Core task: show five production orders with the most operations.
-- If several orders have the same count, sort by ID as well.

SELECT
    pop.production_order_id,
    COUNT(*) AS operation_count
FROM mis.production_operations AS pop
GROUP BY pop.production_order_id
ORDER BY operation_count DESC, pop.production_order_id
LIMIT 5;

-- Extra check from the analyst:
-- Find production orders with operation records but not exactly three.
-- This check does not include orders with zero operation records.

SELECT
    pop.production_order_id,
    COUNT(*) AS operation_count
FROM mis.production_operations AS pop
GROUP BY pop.production_order_id
HAVING COUNT(*) <> 3
ORDER BY pop.production_order_id;


-- Task 2.9 — Completed After the Planned Date
-- Core task: five completed orders with the largest delay in calendar days.

SELECT
    po.production_order_id,
    po.planned_end_date,
    po.actual_completion_date,
    (po.actual_completion_date - po.planned_end_date) AS delay_days
FROM mis.production_orders AS po
WHERE po.status = 'Completed'
  AND po.actual_completion_date > po.planned_end_date
ORDER BY delay_days DESC, po.production_order_id
LIMIT 5;

-- Extra exploration from the analyst:
-- Count completed production orders for each number of delay days.

SELECT
    delayed.delay_days,
    COUNT(*) AS order_count
FROM (
    SELECT
        (po.actual_completion_date - po.planned_end_date) AS delay_days
    FROM mis.production_orders AS po
    WHERE po.status = 'Completed'
      AND po.actual_completion_date > po.planned_end_date
) AS delayed
GROUP BY delayed.delay_days
ORDER BY order_count DESC, delayed.delay_days;


-- Task 2.10 — Initial Findings
-- Read docs/MIS-002_findings.md for three findings and one follow-up question.
