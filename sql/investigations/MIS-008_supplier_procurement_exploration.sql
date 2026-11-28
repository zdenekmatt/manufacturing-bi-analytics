-- MIS-008 — Supplier Procurement & Goods Receipts Exploration
-- Project: Manufacturing Operations & BI Analytics (fictional company)
-- Database: manufacturing_bi | PostgreSQL 18 | Schema: mis
-- Status: Approved — Tasks 8.1–8.9 reviewed during mentoring
-- Work time: approximately 60 minutes (learner estimate)
-- Author note: Queries come from the learner's work in the mentoring sessions.
-- The mentor formatted the SQL, added column names and missing semicolons,
-- and restored the Task 8.5 overview query submitted earlier in the chat.
-- The final compiled SQL file was not rerun end-to-end on the learner's local PostgreSQL.

-- Task 8.1 — First look at procurement data
-- Grain: one supplier / one purchase-order line / one receipt event.
-- Final output uses the six/five/four specified columns instead of SELECT *.
SELECT
    s.supplier_id,
    s.supplier_code,
    s.supplier_name,
    s.supplier_country
FROM mis.suppliers AS s
LIMIT 5;

SELECT
    pol.purchase_order_line_id,
    pol.supplier_id,
    pol.material_id,
    pol.order_date,
    pol.confirmed_date,
    pol.ordered_qty
FROM mis.purchase_order_lines AS pol
LIMIT 5;

SELECT
    gr.goods_receipt_id,
    gr.purchase_order_line_id,
    gr.receipt_date,
    gr.accepted_qty,
    gr.rejected_qty
FROM mis.goods_receipts AS gr
LIMIT 5;

-- Task 8.2 — Counts and date coverage
SELECT COUNT(*) AS supplier_count
FROM mis.suppliers;

SELECT
    COUNT(*) AS purchase_order_line_count,
    MIN(pol.order_date) AS earliest_order_date,
    MAX(pol.order_date) AS latest_order_date
FROM mis.purchase_order_lines AS pol;

SELECT
    COUNT(*) AS goods_receipt_count,
    MIN(gr.receipt_date) AS earliest_receipt_date,
    MAX(gr.receipt_date) AS latest_receipt_date
FROM mis.goods_receipts AS gr;

-- Task 8.3 — Suppliers by country
SELECT
    s.supplier_country,
    COUNT(*) AS supplier_count
FROM mis.suppliers AS s
GROUP BY s.supplier_country
ORDER BY supplier_count DESC, s.supplier_country;

-- Task 8.4 — Purchase-order lines by currency
-- ordered_qty is a quantity of pieces, not a monetary value.
SELECT
    pol.currency,
    COUNT(*) AS order_line_count,
    SUM(pol.ordered_qty) AS total_ordered_qty
FROM mis.purchase_order_lines AS pol
GROUP BY pol.currency
ORDER BY order_line_count DESC;

-- Task 8.5 A — Goods-receipt overview
-- Query submitted by the learner during review and restored to this compiled file.
SELECT
    COUNT(*) AS receipt_count,
    SUM(gr.accepted_qty) AS total_accepted_qty,
    SUM(gr.rejected_qty) AS total_rejected_qty
FROM mis.goods_receipts AS gr;

-- Task 8.5 B — Number of purchase-order lines with multiple receipt events
SELECT COUNT(*) AS order_lines_with_multiple_receipts
FROM (
    SELECT gr.purchase_order_line_id
    FROM mis.goods_receipts AS gr
    GROUP BY gr.purchase_order_line_id
    HAVING COUNT(*) > 1
) AS multi_receipt_lines;

-- Task 8.6 — Five suppliers with the most purchase-order lines
-- Do not join goods_receipts: repeated receipts would multiply ordered_qty.
SELECT
    s.supplier_code,
    COUNT(pol.purchase_order_line_id) AS order_line_count,
    SUM(pol.ordered_qty) AS total_ordered_qty
FROM mis.suppliers AS s
JOIN mis.purchase_order_lines AS pol
    ON s.supplier_id = pol.supplier_id
GROUP BY s.supplier_code
ORDER BY order_line_count DESC, s.supplier_code
LIMIT 5;

-- Task 8.7 — Last receipt date compared with supplier-confirmed date
-- The LEFT JOIN keeps purchase-order lines with no receipt (No Receipt).
WITH cte_last_receipt AS (
    SELECT
        gr.purchase_order_line_id,
        MAX(gr.receipt_date) AS last_receipt
    FROM mis.goods_receipts AS gr
    GROUP BY gr.purchase_order_line_id
)
SELECT
    CASE
        WHEN clr.last_receipt IS NULL THEN 'No Receipt'
        WHEN clr.last_receipt > pol.confirmed_date THEN 'Late'
        ELSE 'Not Late'
    END AS receipt_status,
    COUNT(*) AS order_line_count
FROM mis.purchase_order_lines AS pol
LEFT JOIN cte_last_receipt AS clr
    ON pol.purchase_order_line_id = clr.purchase_order_line_id
GROUP BY receipt_status
ORDER BY receipt_status;

-- Task 8.8 A — Compare receipt row count with unique receipt IDs
SELECT
    COUNT(*) AS receipt_count,
    COUNT(DISTINCT gr.goods_receipt_id) AS unique_receipt_ids
FROM mis.goods_receipts AS gr;

-- Task 8.8 B — Source totals (unrounded)
SELECT
    COUNT(*) AS receipt_count,
    SUM(gr.accepted_qty) AS total_accepted_quantity,
    SUM(gr.rejected_qty) AS total_rejected_quantity
FROM mis.goods_receipts AS gr;

-- Task 8.8 C — Totals after joining receipts to order lines and suppliers
SELECT
    COUNT(*) AS receipt_count,
    SUM(gr.accepted_qty) AS total_accepted_quantity,
    SUM(gr.rejected_qty) AS total_rejected_quantity
FROM mis.goods_receipts AS gr
JOIN mis.purchase_order_lines AS pol
    ON gr.purchase_order_line_id = pol.purchase_order_line_id
JOIN mis.suppliers AS s
    ON pol.supplier_id = s.supplier_id;

-- Task 8.8 D — One row for each purchase-order line after the LEFT JOIN
WITH cte_last_receipt AS (
    SELECT
        gr.purchase_order_line_id,
        MAX(gr.receipt_date) AS last_receipt
    FROM mis.goods_receipts AS gr
    GROUP BY gr.purchase_order_line_id
)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT pol.purchase_order_line_id) AS unique_order_lines
FROM mis.purchase_order_lines AS pol
LEFT JOIN cte_last_receipt AS clr
    ON pol.purchase_order_line_id = clr.purchase_order_line_id;

-- Task 8.9 — Written B1-English findings are in docs/MIS-008_findings.md.
