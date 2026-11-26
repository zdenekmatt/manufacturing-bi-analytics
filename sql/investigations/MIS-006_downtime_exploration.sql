-- ============================================================================
-- MIS-006 — Production Downtime Exploration
-- Moravia Industrial Systems | PostgreSQL 18 | schema: mis
-- Review status: 9/9 tasks reviewed; final local SQL verification pending
-- Actual work time: approximately 80 minutes (learner's estimate)
--
-- Based on the learner's SQL submitted during interactive mentoring.
-- Editorial changes: comments, formatting, explicit Task 6.1 columns,
-- Task 6.5 sorting, and a robust zero-minute fallback in Task 6.7.
-- Downtime minutes are reported event durations, NOT production lead time.
-- The findings are exploratory and do not establish root causes or OEE.
-- ============================================================================

-- Task 6.1 — First look at downtime events
-- One row represents one downtime event linked to a production operation.
SELECT
    de.downtime_id,
    de.operation_id,
    de.event_date,
    de.duration_minutes,
    de.downtime_category,
    de.is_planned
FROM mis.downtime_events AS de
LIMIT 5;


-- Task 6.2 — Event counts and date coverage
-- COUNT(*) = events; COUNT(DISTINCT operation_id) = operations with events.
SELECT
    COUNT(*) AS count_downtime_events,
    COUNT(DISTINCT de.operation_id) AS count_distinct_operations,
    MIN(de.event_date) AS earliest_event_date,
    MAX(de.event_date) AS latest_event_date
FROM mis.downtime_events AS de;


-- Task 6.3 — Downtime categories: event count and total reported minutes
SELECT
    de.downtime_category,
    COUNT(*) AS event_count,
    SUM(de.duration_minutes) AS total_downtime_minutes
FROM mis.downtime_events AS de
GROUP BY de.downtime_category
ORDER BY total_downtime_minutes DESC;


-- Task 6.4 — Planned vs. unplanned downtime
-- is_planned: TRUE = planned; FALSE = unplanned.
SELECT
    de.is_planned,
    COUNT(*) AS event_count,
    SUM(de.duration_minutes) AS total_downtime_minutes
FROM mis.downtime_events AS de
GROUP BY de.is_planned
ORDER BY de.is_planned;


-- Task 6.5 — Downtime by operation type
-- Rows after JOIN represent downtime events, not distinct operations.
SELECT
    pop.operation_type,
    COUNT(*) AS event_count,
    SUM(de.duration_minutes) AS total_downtime_minutes
FROM mis.production_operations AS pop
JOIN mis.downtime_events AS de
    ON pop.operation_id = de.operation_id
GROUP BY pop.operation_type
ORDER BY total_downtime_minutes DESC;


-- Task 6.6 — Downtime by production line
-- Three JOINs link a downtime event to the line of its production order.
SELECT
    pl.line_code,
    COUNT(*) AS event_count,
    SUM(de.duration_minutes) AS total_downtime_minutes
FROM mis.production_lines AS pl
JOIN mis.production_orders AS por
    ON pl.line_id = por.line_id
JOIN mis.production_operations AS pop
    ON por.production_order_id = pop.production_order_id
JOIN mis.downtime_events AS de
    ON pop.operation_id = de.operation_id
GROUP BY pl.line_code
ORDER BY total_downtime_minutes DESC;


-- Task 6.7 — Downtime and completion timeliness
-- Step 1: sum downtime EVENT minutes per production order.
-- Step 2: retain ALL completed orders and label Late / Not Late.
-- Orders with no reported downtime contribute 0, not NULL, to AVG.
-- The outer COALESCE is a small robustness improvement to the learner's query.
WITH downtime_production_orders AS (
    SELECT
        pop.production_order_id,
        COALESCE(SUM(de.duration_minutes), 0) AS total_downtime_minutes
    FROM mis.production_operations AS pop
    LEFT JOIN mis.downtime_events AS de
        ON pop.operation_id = de.operation_id
    GROUP BY pop.production_order_id
)
SELECT
    CASE
        WHEN por.actual_completion_date <= por.planned_end_date THEN 'Not Late'
        ELSE 'Late'
    END AS completion_status,
    COUNT(*) AS order_count,
    ROUND(AVG(COALESCE(dpo.total_downtime_minutes, 0)), 2)
        AS avg_downtime_minutes
FROM mis.production_orders AS por
LEFT JOIN downtime_production_orders AS dpo
    ON por.production_order_id = dpo.production_order_id
WHERE por.status = 'Completed'
GROUP BY completion_status
ORDER BY completion_status;


-- Task 6.8 A — Original downtime-event counts and minutes
SELECT
    COUNT(*) AS event_count,
    COUNT(DISTINCT downtime_id) AS unique_events,
    SUM(duration_minutes) AS total_downtime_minutes
FROM mis.downtime_events;


-- Task 6.8 B — Reconciliation after the JOINs from Task 6.6
-- Expected: 10,397 events; 10,397 unique events; 938,540 minutes.
SELECT
    COUNT(*) AS event_count,
    COUNT(DISTINCT de.downtime_id) AS unique_events,
    SUM(de.duration_minutes) AS total_downtime_minutes
FROM mis.downtime_events AS de
JOIN mis.production_operations AS pop
    ON de.operation_id = pop.operation_id
JOIN mis.production_orders AS por
    ON pop.production_order_id = por.production_order_id
JOIN mis.production_lines AS pl
    ON por.line_id = pl.line_id;


-- Task 6.8 C — Find missing, zero or negative downtime durations
-- Expected: no rows; this was confirmed during mentoring.
SELECT
    de.downtime_id,
    de.duration_minutes
FROM mis.downtime_events AS de
WHERE de.duration_minutes IS NULL
   OR de.duration_minutes <= 0;


-- Task 6.9 — Initial Findings
-- See: docs/MIS-006_findings.md
