-- ============================================================================
-- MIS-005 — Production Quality Data Exploration
-- Moravia Industrial Systems | PostgreSQL 18 | schema: mis
-- Status: Ready for final local SQL verification
-- Actual work time: approximately 80 minutes
--
-- Based on the learner's SQL submitted during the ticket review.
-- Changes: formatting, required line_code/columns, and grouped query aliases.
-- NOTE: Task 5.5's event split is added to match the ORIGINAL ticket scope.
--       Run this new check locally before final approval.
-- The source data is synthetic; percentages are exploratory, not official KPIs.
-- ============================================================================

-- Task 5.1 — First look at inspection events
-- One row represents one quality inspection event for a production order.
SELECT
    qe.quality_event_id,
    qe.production_order_id,
    qe.inspection_date,
    qe.inspected_qty,
    qe.defective_qty,
    qe.inspection_result
FROM mis.quality_events AS qe
LIMIT 5;


-- Task 5.2 — Record counts and inspection dates
SELECT
    COUNT(*) AS inspection_events,
    COUNT(DISTINCT qe.production_order_id) AS distinct_inspected_orders,
    MIN(qe.inspection_date) AS min_inspection_date,
    MAX(qe.inspection_date) AS max_inspection_date
FROM mis.quality_events AS qe;

-- Additional context from the learner's exploration: all production orders.
SELECT
    COUNT(*) AS total_production_orders
FROM mis.production_orders;


-- Task 5.3 — Inspection results (number of EVENTS, not defective pieces)
SELECT
    qe.inspection_result,
    COUNT(*) AS event_count
FROM mis.quality_events AS qe
GROUP BY qe.inspection_result
ORDER BY event_count DESC;


-- Task 5.4 — Total inspected and defective PIECES
SELECT
    SUM(qe.inspected_qty) AS total_inspected_qty,
    SUM(qe.defective_qty) AS total_defective_qty
FROM mis.quality_events AS qe;

-- Learner's supplemental exploration: overall defective-piece percentage.
-- This ratio is exploratory, not an approved quality KPI.
SELECT
    totals.total_inspected_qty,
    totals.total_defective_qty,
    ROUND(
        totals.total_defective_qty * 100.0
        / NULLIF(totals.total_inspected_qty, 0),
        2
    ) AS defective_piece_share_pct
FROM (
    SELECT
        SUM(qe.inspected_qty) AS total_inspected_qty,
        SUM(qe.defective_qty) AS total_defective_qty
    FROM mis.quality_events AS qe
) AS totals;


-- Task 5.5 — Events with and without defective pieces
-- Added to align with the original ticket; pending local re-run.
SELECT
    COUNT(*) FILTER (WHERE qe.defective_qty > 0) AS events_with_defects,
    COUNT(*) FILTER (WHERE qe.defective_qty = 0) AS events_without_defects
FROM mis.quality_events AS qe;

-- Learner's own extra consistency check (returned zero rows locally):
-- A 'Pass' inspection must not have a positive defective quantity.
SELECT
    qe.inspection_result,
    qe.defective_qty
FROM mis.quality_events AS qe
WHERE qe.inspection_result = 'Pass'
  AND qe.defective_qty > 0;


-- Task 5.6 — Inspection and defective quantities by production line
-- INNER JOIN chain: quality_events -> production_orders -> production_lines.
SELECT
    pl.line_code,
    COUNT(*) AS inspection_count,
    SUM(qe.inspected_qty) AS total_inspected_qty,
    SUM(qe.defective_qty) AS total_defective_qty
FROM mis.quality_events AS qe
JOIN mis.production_orders AS por
    ON qe.production_order_id = por.production_order_id
JOIN mis.production_lines AS pl
    ON por.line_id = pl.line_id
GROUP BY pl.line_code
ORDER BY total_defective_qty DESC;


-- Task 5.7 — Exploratory defective-piece percentage by production line
-- Outer query displays all four requested columns.
SELECT
    totals.line_code,
    totals.total_inspected_qty,
    totals.total_defective_qty,
    ROUND(
        totals.total_defective_qty * 100.0
        / NULLIF(totals.total_inspected_qty, 0),
        2
    ) AS defective_piece_share_pct
FROM (
    SELECT
        pl.line_code,
        SUM(qe.inspected_qty) AS total_inspected_qty,
        SUM(qe.defective_qty) AS total_defective_qty
    FROM mis.quality_events AS qe
    JOIN mis.production_orders AS por
        ON qe.production_order_id = por.production_order_id
    JOIN mis.production_lines AS pl
        ON por.line_id = pl.line_id
    GROUP BY pl.line_code
) AS totals
ORDER BY defective_piece_share_pct DESC;


-- Task 5.8A — Basic quantity validation
-- No rows returned in the learner's local run.
SELECT
    qe.quality_event_id,
    qe.defective_qty,
    qe.inspected_qty
FROM mis.quality_events AS qe
WHERE qe.defective_qty IS NULL
   OR qe.inspected_qty IS NULL
   OR qe.defective_qty < 0
   OR qe.inspected_qty < 0
   OR qe.defective_qty > qe.inspected_qty;

-- Task 5.8B — Join grain check
-- Expected and previously observed: total_rows = unique_events = 15,210.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT qe.quality_event_id) AS unique_events
FROM mis.quality_events AS qe
JOIN mis.production_orders AS por
    ON qe.production_order_id = por.production_order_id
JOIN mis.production_lines AS pl
    ON por.line_id = pl.line_id;

-- Task 5.8C — Reconciliation evidence
-- Compare Task 5.6's six group totals to Task 5.4's source totals.
-- The learner's previously submitted results reconcile:
-- inspection events = 15,210; inspected pieces = 1,920,612;
-- defective pieces = 11,165.

-- Task 5.9 — Initial findings are documented in docs/MIS-005_findings.md.
