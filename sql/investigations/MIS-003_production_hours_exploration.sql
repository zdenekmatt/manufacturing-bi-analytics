-- MIS-003 — Production Hours & Workload Exploration
-- Project: Manufacturing BI Analyst Simulation (Moravia Industrial Systems)
-- Database: manufacturing_bi | Schema: mis | PostgreSQL
-- Author: Junior BI Analyst (learner)
-- Status: Ready for final local SQL check
-- Notes: Queries are based on the learner's submitted SQL.
--        Formatting, names and comments were standardized after mentoring review.
--        Labor and machine hours are separate recorded measures.


-- Task 3.1 — First look at working hours
-- Grain: one row = one production operation.
SELECT
    operation_id,
    production_order_id,
    operation_type,
    labor_hours,
    machine_hours
FROM mis.production_operations
LIMIT 5;


-- Task 3.2 — Total recorded hours
SELECT
    SUM(pop.labor_hours) AS total_labor_hours,
    SUM(pop.machine_hours) AS total_machine_hours
FROM mis.production_operations AS pop;


-- Task 3.3 — Hours by operation type
-- Average is per operation, not per production order.
SELECT
    pop.operation_type,
    COUNT(*) AS operation_count,
    ROUND(SUM(pop.labor_hours), 2) AS total_labor_hours,
    ROUND(AVG(pop.labor_hours), 2) AS avg_labor_hours,
    ROUND(SUM(pop.machine_hours), 2) AS total_machine_hours
FROM mis.production_operations AS pop
GROUP BY pop.operation_type
ORDER BY total_labor_hours DESC;


-- Task 3.4 — Five production orders with the highest labor hours
SELECT
    pop.production_order_id,
    ROUND(SUM(pop.labor_hours), 2) AS total_labor_hours,
    ROUND(SUM(pop.machine_hours), 2) AS total_machine_hours
FROM mis.production_operations AS pop
GROUP BY pop.production_order_id
ORDER BY total_labor_hours DESC
LIMIT 5;


-- Task 3.5 — Recorded workload by production line
-- One joined row represents one operation, not one unique production order.
SELECT
    pl.line_code,
    COUNT(pop.operation_seq) AS operation_count,
    ROUND(SUM(pop.labor_hours), 2) AS total_labor_hours,
    ROUND(SUM(pop.machine_hours), 2) AS total_machine_hours
FROM mis.production_lines AS pl
JOIN mis.production_orders AS por
    ON pl.line_id = por.line_id
JOIN mis.production_operations AS pop
    ON por.production_order_id = pop.production_order_id
GROUP BY pl.line_code
ORDER BY total_labor_hours DESC;


-- Task 3.6 — Average total labor hours per production order, by line
-- Step 1: sum operation hours for each order.
-- Step 2: average those per-order totals within each line.
WITH labor_hours_per_order AS (
    SELECT
        por.line_id,
        pop.production_order_id,
        SUM(pop.labor_hours) AS total_labor_hours
    FROM mis.production_operations AS pop
    JOIN mis.production_orders AS por
        ON pop.production_order_id = por.production_order_id
    GROUP BY
        por.line_id,
        pop.production_order_id
)
SELECT
    pl.line_code,
    ROUND(AVG(per_order.total_labor_hours), 2) AS avg_labor_hours_per_order
FROM mis.production_lines AS pl
JOIN labor_hours_per_order AS per_order
    ON pl.line_id = per_order.line_id
GROUP BY pl.line_code
ORDER BY avg_labor_hours_per_order DESC;


-- Task 3.7 — Number of production orders with more than 15 labor hours
-- The 15-hour threshold is exploratory, not a business target.
WITH sum_labor_hours_per_order AS (
    SELECT
        pop.production_order_id,
        SUM(pop.labor_hours) AS total_labor_hours
    FROM mis.production_operations AS pop
    GROUP BY pop.production_order_id
    HAVING SUM(pop.labor_hours) > 15
)
SELECT
    COUNT(*) AS order_count_over_15_hours
FROM sum_labor_hours_per_order AS per_order;


-- Task 3.8A — Data quality: missing or negative labor hours
-- Expected result from the learner's check: zero rows.
SELECT
    pop.labor_hours
FROM mis.production_operations AS pop
WHERE pop.labor_hours IS NULL
   OR pop.labor_hours < 0;


-- Task 3.8A — Data quality: missing or negative machine hours
-- Expected result from the learner's check: zero rows.
SELECT
    pop.machine_hours
FROM mis.production_operations AS pop
WHERE pop.machine_hours IS NULL
   OR pop.machine_hours < 0;


-- Task 3.8B — Reconciliation after joining orders and lines
-- Do not round before comparison with Task 3.2.
-- Grouped breakdowns are already shown in Tasks 3.3 and 3.5.
SELECT
    SUM(pop.labor_hours) AS total_labor_hours_joined,
    SUM(pop.machine_hours) AS total_machine_hours_joined
FROM mis.production_lines AS pl
JOIN mis.production_orders AS por
    ON pl.line_id = por.line_id
JOIN mis.production_operations AS pop
    ON por.production_order_id = pop.production_order_id;


-- Task 3.8B — Reconciliation: source operation-level totals
SELECT
    SUM(pop.labor_hours) AS total_labor_hours_source,
    SUM(pop.machine_hours) AS total_machine_hours_source
FROM mis.production_operations AS pop;


-- Task 3.9 — The three findings and the future question are in:
-- docs/MIS-003_findings.md
