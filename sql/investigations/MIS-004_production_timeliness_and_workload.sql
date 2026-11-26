-- MIS-004 — Production Timeliness & Workload Exploration
-- Moravia Industrial Systems | PostgreSQL 18 | schema: mis
-- Status: Ready for final review (run this edited file on the local database)
-- Original analytical approach by the learner; formatting and minor aliases edited.
-- Data: synthetic manufacturing dataset v1.0.0

-- ============================================================
-- Task 4.1 — First Look at Planned and Actual Dates
-- One row in production_orders represents one production order.
-- ============================================================
SELECT
    por.production_order_id,
    por.line_id,
    por.status,
    por.planned_end_date,
    por.actual_completion_date
FROM mis.production_orders AS por
LIMIT 5;


-- ============================================================
-- Task 4.2 — Late vs. Not Late Completed Orders
-- Only Completed orders enter the result. The 'Open' branch
-- is retained from the learner's exploratory CASE expression;
-- under the validated data it does not appear in this result.
-- ============================================================
SELECT
    status_groups.completion_date_status,
    COUNT(*) AS order_count
FROM (
    SELECT
        CASE
            WHEN por.actual_completion_date IS NULL THEN 'Open'
            WHEN por.actual_completion_date <= por.planned_end_date THEN 'Not Late'
            ELSE 'Late'
        END AS completion_date_status
    FROM mis.production_orders AS por
    WHERE por.status = 'Completed'
) AS status_groups
GROUP BY status_groups.completion_date_status
ORDER BY status_groups.completion_date_status;


-- ============================================================
-- Task 4.3 — Delay Days
-- Calendar-day delay, measured among late completed orders only.
-- ============================================================
SELECT
    COUNT(*) AS late_orders,
    MAX(delays.delay_days) AS max_delay_days,
    ROUND(AVG(delays.delay_days), 2) AS avg_delay_days
FROM (
    SELECT
        CASE
            WHEN por.actual_completion_date IS NULL THEN 'Open'
            WHEN por.actual_completion_date <= por.planned_end_date THEN 'Not Late'
            ELSE 'Late'
        END AS completion_date_status,
        (por.actual_completion_date - por.planned_end_date) AS delay_days
    FROM mis.production_orders AS por
    WHERE por.status = 'Completed'
) AS delays
WHERE delays.completion_date_status = 'Late';


-- ============================================================
-- Task 4.4 — Late Orders by Production Line
-- FILTER counts orders meeting different conditions.
-- ============================================================
SELECT
    pl.line_code,
    COUNT(*) AS completed_orders,
    COUNT(*) FILTER (
        WHERE por.actual_completion_date > por.planned_end_date
    ) AS late_orders,
    COUNT(*) FILTER (
        WHERE por.actual_completion_date <= por.planned_end_date
    ) AS not_late_orders
FROM mis.production_lines AS pl
JOIN mis.production_orders AS por
    ON pl.line_id = por.line_id
WHERE por.status = 'Completed'
GROUP BY pl.line_code
ORDER BY pl.line_code;


-- ============================================================
-- Task 4.5 — Late Share by Production Line
-- Denominator: completed orders on each line (not all orders).
-- 100.0 gives decimal division; NULLIF protects division by zero.
-- ============================================================
SELECT
    line_counts.line_code,
    line_counts.completed_orders,
    line_counts.late_orders,
    ROUND(
        (line_counts.late_orders * 100.0)
        / NULLIF(line_counts.completed_orders, 0),
        2
    ) AS late_share_pct
FROM (
    SELECT
        pl.line_code,
        COUNT(*) AS completed_orders,
        COUNT(*) FILTER (
            WHERE por.actual_completion_date > por.planned_end_date
        ) AS late_orders
    FROM mis.production_lines AS pl
    JOIN mis.production_orders AS por
        ON pl.line_id = por.line_id
    WHERE por.status = 'Completed'
    GROUP BY pl.line_code
) AS line_counts
ORDER BY late_share_pct DESC;


-- ============================================================
-- Task 4.6 — Recorded Labor Hours per Completed Order
-- Aggregate operation-level records to one row per order.
-- ============================================================
SELECT
    pop.production_order_id,
    por.line_id,
    por.planned_end_date,
    por.actual_completion_date,
    SUM(pop.labor_hours) AS total_labor_hours
FROM mis.production_orders AS por
JOIN mis.production_operations AS pop
    ON por.production_order_id = pop.production_order_id
WHERE por.status = 'Completed'
GROUP BY
    pop.production_order_id,
    por.line_id,
    por.planned_end_date,
    por.actual_completion_date;


-- ============================================================
-- Task 4.7 — Labor Hours: Late vs. Not Late
-- First SUM per order, then AVG across orders in each category.
-- ============================================================
WITH labor_summary AS (
    SELECT
        pop.production_order_id,
        SUM(pop.labor_hours) AS total_labor_hours
    FROM mis.production_operations AS pop
    GROUP BY pop.production_order_id
),
order_status AS (
    SELECT
        por.production_order_id,
        ls.total_labor_hours,
        CASE
            WHEN por.actual_completion_date > por.planned_end_date THEN 'Late'
            ELSE 'Not Late'
        END AS completion_status
    FROM mis.production_orders AS por
    JOIN labor_summary AS ls
        ON por.production_order_id = ls.production_order_id
    WHERE por.status = 'Completed'
)
SELECT
    completion_status,
    COUNT(production_order_id) AS order_count,
    ROUND(AVG(total_labor_hours), 2) AS avg_labor_hours
FROM order_status
GROUP BY completion_status
ORDER BY completion_status;


-- ============================================================
-- Task 4.8 — Basic Validation
-- Counts must match: total_rows = unique_orders = 15,210.
-- Together with Task 4.7's category counts, this checks
-- the comparison covers all completed orders without duplicates.
-- ============================================================
WITH labor_summary AS (
    SELECT
        pop.production_order_id,
        SUM(pop.labor_hours) AS total_labor_hours
    FROM mis.production_operations AS pop
    GROUP BY pop.production_order_id
),
order_status AS (
    SELECT
        por.production_order_id,
        ls.total_labor_hours,
        CASE
            WHEN por.actual_completion_date > por.planned_end_date THEN 'Late'
            ELSE 'Not Late'
        END AS completion_status
    FROM mis.production_orders AS por
    JOIN labor_summary AS ls
        ON por.production_order_id = ls.production_order_id
    WHERE por.status = 'Completed'
)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT production_order_id) AS unique_orders
FROM order_status;

-- Task 4.9 — Initial Findings: see docs/MIS-004_findings.md.
