-- ================================================================
-- MIS-007 — Inventory Movements & Material Flow Exploration
-- Moravia Industrial Systems (fictional) | PostgreSQL 18
-- Database: manufacturing_bi | Schema: mis | Dataset: v1.0.0
-- Status: Approved (9/9 tasks reviewed)
-- SQL author: Junior BI Analyst; mentor edited formatting and QA.
-- Review date: 2026-11-26
--
-- Rows in inventory_transactions represent individual movements.
-- qty_delta: positive = inbound; negative = outbound.
-- The task 7.8 shipment-type spelling was fixed during final review.
-- The final assembled SQL was not executed against the user's local
-- PostgreSQL instance. QA was independently checked against the
-- synthetic dataset's original CSV release (v1.0.0).
-- ================================================================

-- Task 7.1 — First Look at Inventory Movements
-- Grain: one record = one inventory transaction.
SELECT
    it.inventory_txn_id,
    it.txn_date,
    it.material_id,
    it.product_id,
    it.movement_type,
    it.qty_delta
FROM mis.inventory_transactions AS it
LIMIT 5;


-- Task 7.2 — Counts and Date Coverage
SELECT
    COUNT(*) AS transaction_count,
    MIN(it.txn_date) AS earliest_date,
    MAX(it.txn_date) AS latest_date,
    COUNT(DISTINCT it.movement_type) AS movement_types
FROM mis.inventory_transactions AS it;


-- Task 7.3 — Movement Types
-- Signed quantities across different SKUs are movement totals,
-- not the stock balance of any individual item.
SELECT
    it.movement_type,
    COUNT(*) AS transaction_count,
    SUM(it.qty_delta) AS total_qty_delta
FROM mis.inventory_transactions AS it
GROUP BY it.movement_type
ORDER BY transaction_count DESC;


-- Task 7.4 — Materials vs. Finished Goods
-- This classification relies on the validated source rule:
-- exactly one of material_id or product_id is populated.
SELECT
    classified.inventory_group,
    COUNT(*) AS transaction_count
FROM (
    SELECT
        CASE
            WHEN it.product_id IS NULL THEN 'Material'
            ELSE 'Finished Goods'
        END AS inventory_group
    FROM mis.inventory_transactions AS it
) AS classified
GROUP BY classified.inventory_group
ORDER BY classified.inventory_group;


-- Task 7.5 — Raw-Material Inflow and Outflow
-- Opening balances describe starting recorded stock, not receipts.
SELECT
    it.movement_type,
    COUNT(*) AS transaction_count,
    SUM(it.qty_delta) AS total_qty_delta
FROM mis.inventory_transactions AS it
WHERE it.material_id IS NOT NULL
GROUP BY it.movement_type
ORDER BY it.movement_type;


-- Task 7.6 — Most Issued Materials
-- Filter issues only; all their qty_delta values should be negative.
SELECT
    ma.material_code,
    ma.material_name,
    COUNT(*) AS issue_count,
    ABS(SUM(it.qty_delta)) AS issued_quantity
FROM mis.materials AS ma
JOIN mis.inventory_transactions AS it
    ON ma.material_id = it.material_id
WHERE it.movement_type = 'material_issue'
GROUP BY ma.material_code, ma.material_name
ORDER BY issued_quantity DESC
LIMIT 5;


-- Task 7.7 — Ledger-Derived Material Balances
-- All available movements incl. opening balances, receipts, issues.
-- This is NOT a verified physical warehouse stock count.
SELECT
    ma.material_code,
    ma.material_name,
    SUM(it.qty_delta) AS ledger_balance
FROM mis.materials AS ma
JOIN mis.inventory_transactions AS it
    ON ma.material_id = it.material_id
GROUP BY ma.material_code, ma.material_name
ORDER BY ledger_balance DESC
LIMIT 5;


-- Task 7.8 A — Duplicate Transaction IDs
-- event_count should equal distinct inventory_txn_id count.
SELECT
    COUNT(*) AS count_inventory,
    COUNT(DISTINCT it.inventory_txn_id) AS unique_inventory
FROM mis.inventory_transactions AS it;


-- Task 7.8 B — Missing / Conflicting Item IDs and Invalid Quantity
-- Expected: zero rows.
SELECT
    it.inventory_txn_id,
    it.material_id,
    it.product_id,
    it.qty_delta
FROM mis.inventory_transactions AS it
WHERE (it.material_id IS NULL AND it.product_id IS NULL)
   OR (it.material_id IS NOT NULL AND it.product_id IS NOT NULL)
   OR it.qty_delta IS NULL
   OR it.qty_delta = 0;


-- Task 7.8 C — Incorrect Direction / Quantity Sign
-- Expected: zero rows. Covers ALL five recorded movement types.
-- Mentor correction: 'finished_goods_shipment' is singular.
SELECT
    it.inventory_txn_id,
    it.movement_type,
    it.qty_delta
FROM mis.inventory_transactions AS it
WHERE (
    it.movement_type IN (
        'opening_balance',
        'material_receipt',
        'finished_goods_receipt'
    ) AND it.qty_delta <= 0
)
OR (
    it.movement_type IN (
        'material_issue',
        'finished_goods_shipment'
    ) AND it.qty_delta >= 0
);

-- Task 7.9 — Three findings and one future question are in:
-- docs/MIS-007_findings.md
