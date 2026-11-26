# MIS-007 — Inventory Movements & Material Flow Exploration

**Ticket ID:** MIS-007  
**Type:** Standard Task / Investigation  
**Requestor:** Warehouse & Supply Chain Manager (simulated)  
**Priority:** Medium  
**Status:** Approved — all nine tasks reviewed  
**Difficulty:** Beginner → Junior  
**Estimated work time:** 120–180 minutes, flexible  
**Actual work time:** Not yet recorded by the learner  
**Database:** `manufacturing_bi` — PostgreSQL 18, schema `mis`  
**Dataset:** Synthetic manufacturing baseline v1.0.0

## Business Context

You are a Junior BI Analyst at Moravia Industrial Systems, a fictional manufacturer.

The production team has already explored production orders, working hours, delays, quality and downtime. The warehouse manager now wants a first overview of **inventory movements**: what enters and leaves stock, which movement types are common, and how recorded material balances can be explored.

This is an exploratory ticket. Do **not** define official stock availability, inventory coverage, stockout, or inventory-value KPIs. A movement is a recorded quantity change; it is not a customer order, goods-receipt document, or physical stock count.

## Data Sources and Grain

- `mis.inventory_transactions`: **one row = one signed inventory movement** for a raw material or a finished product. Relevant fields: `inventory_txn_id`, `txn_date`, `material_id`, `product_id`, `movement_type`, `qty_delta`.
- `mis.materials`: **one row = one raw-material SKU**. Fields include `material_id`, `material_code`, `material_name`, `base_unit`.
- Optional context only, not necessary for initial tasks: `mis.products` (finished products).

`qty_delta` is measured in pieces (`pcs`): **positive** means an inbound quantity and **negative** means an outbound quantity. In `inventory_transactions`, either `material_id` or `product_id` is populated, but not both. The dataset includes `opening_balance`, `material_receipt`, `material_issue`, `finished_goods_receipt` and `finished_goods_shipment` movement types. Verify their actual frequencies from SQL rather than assuming every type has the same volume.

**Important:** Do not interpret a sum of signed quantities across *different SKUs* as the physical balance of one item. When calculating a per-material ledger balance, include opening-balance events and the full available transaction history, and explain that the result is **ledger-derived**, not a verified physical stock count.

## Core Requirements

### Level 1 — Explore

**Task 7.1 — First Look at Inventory Movements**  
Show five rows from `mis.inventory_transactions` with `inventory_txn_id`, `txn_date`, `material_id`, `product_id`, `movement_type` and `qty_delta`. Write one short English sentence explaining what one row represents. Note how a material movement differs from a finished-goods movement.

**Task 7.2 — Counts and Date Coverage**  
Find the number of inventory transactions, the earliest and latest `txn_date`, and the number of distinct `movement_type` values. Do not infer business trends from the date range alone.

### Level 2 — Understand Movements

**Task 7.3 — Movement Types**  
For each `movement_type`, show the number of transactions and the sum of signed `qty_delta`. Sort by transaction count, highest first. Explain what a positive or negative sum means for the movement type. Do **not** call a cross-SKU sum an inventory balance.

**Task 7.4 — Materials vs. Finished Goods**  
Classify transaction rows as `Material` or `Finished Goods` according to whether `material_id` or `product_id` is present. Show the number of transactions for each group. Check that the groups add up to the total transaction count. One simple `CASE` expression is enough.

**Task 7.5 — Raw-Material Inflow and Outflow**  
Focus on records with a non-null `material_id`. For each material-related `movement_type`, show the number of transactions and the signed sum of `qty_delta`. In a short English sentence, distinguish receipts from issues. Opening balances are not newly received stock during the period.

### Level 3 — Connect and Analyze

**Task 7.6 — Most Issued Materials**  
Connect `mis.inventory_transactions` to `mis.materials`. For `material_issue` transactions, show the five materials with the largest **outgoing quantity**, including `material_code`, `material_name`, the number of issue transactions, and issued quantity as a **positive** number for easy comparison. Sort by issued quantity, highest first. Do not interpret the result as monetary cost.

**Task 7.7 — Ledger-Derived Material Balances**  
For each raw material, calculate the signed sum of **all** available material inventory movements, including opening balances, receipts and issues. Join to `mis.materials`, then show the five raw materials with the highest calculated balances, with material code and balance in pieces. One `SUM(qty_delta)` per material is the core idea; a CTE is optional. State that this is a ledger-derived balance at the end of the available history, not a warehouse physical-count confirmation or a reorder recommendation.

### Level 4 — Validate and Communicate

**Task 7.8 — Basic Validation**  
Check whether `inventory_txn_id` is unexpectedly duplicated; whether a movement has both `material_id` and `product_id` filled (or neither); whether any `qty_delta` is zero or null; and whether the sign of `qty_delta` matches movement direction (`opening_balance`, `material_receipt`, `finished_goods_receipt` are inbound; `material_issue`, `finished_goods_shipment` are outbound). Present row counts or a short exception query. Do not add additional mandatory tests.

**Task 7.9 — Initial Findings**  
Write **three** short findings in English (B1) supported by your actual SQL results. Add **one** question for future analysis. Separate observed movements and ledger-derived balances from unverified explanations about shortages, cost or on-time delivery.

## Required Validation and Interpretation

- Distinguish transaction count from quantity movement, and raw materials from finished products.
- Use the correct grain for each query. A sum across multiple materials is not a stock balance for an individual SKU.
- Negative `qty_delta` is expected for outbound movements: do not flag all negatives as invalid.
- Material issues, receipts and opening balances describe different business events and must not be confused.
- Do not claim actual physical stock on hand, stockouts, purchase cost or supplier delivery issues without appropriate additional evidence.
- Do not introduce more required QA or new KPIs during review without agreeing on a scope change.

## Optional Challenge — Not Required for Approval

For one material of your choice, show its inventory movements in date order and calculate a **running ledger balance** over time. This introduces a window function and is **entirely optional**. If unfamiliar, skip it without penalty.

## Expected Deliverables

- **Ticket:** `tickets/MIS-007_inventory_movements_exploration.md`
- **SQL:** `sql/investigations/MIS-007_inventory_movements_exploration.sql`
- **Findings:** `docs/MIS-007_findings.md`

The learner writes their SQL and findings during the work. Portfolio formatting follows review, preserving the learner's own queries and marking any mentor-provided examples.

## Acceptance Criteria

- Tasks 7.1–7.9 reviewed, with agreed fixes completed.
- SQL valid for PostgreSQL 18, using the correct transaction/material grain.
- Counts reconcile to the transaction total; signs and material/product exclusivity are checked.
- Ledger-derived balances clearly distinguished from physical stock counts.
- Three B1-English findings and one future question supported by observed results.

## Review / Handoff

**Final status:** **Approved — Tasks 7.1–7.9 reviewed and completed** (2026-11-26).  
**Time:** Original flexible estimate 120–180 minutes; actual work time not yet provided.  
**Portfolio files:** `sql/investigations/MIS-007_inventory_movements_exploration.sql`, `docs/MIS-007_findings.md`, and this ticket.  

**Review outcomes:**

- Tasks 7.1–7.5: basic source exploration, grouping and transaction-type interpretation reviewed.
- Task 7.6: the original query summed all movement types; learner corrected it to filter `material_issue` and report positive issued quantities.
- Task 7.7: per-material ledger balances are computed as signed sums over all available material movements, including opening balances.
- Task 7.8: 91,718 events with 91,718 distinct IDs; item-reference and quantity checks showed no exceptions. During final SQL review, the mentor corrected `finished_goods_shipments` to `finished_goods_shipment` in the outbound-sign query; this corrected check was verified on the synthetic v1.0.0 CSV and showed zero sign exceptions for all five types.
- Task 7.9: three evidence-based B1 findings and the learner's future question — “Do we have enough materials for our production?” — approved.

**SQL execution note:** The mentor used learner-provided PostgreSQL results and independently checked the corrected sign validation and key inventory summaries against the original synthetic CSV release. The compiled, formatted final SQL file has not been run end-to-end on the learner's local PostgreSQL installation. Approval is based on completed task review and the recorded dataset verification; do not claim a local final re-run was performed.

**Preceding ticket:** MIS-006 — Production Downtime Exploration (Approved).  
**Next ticket:** Do not start MIS-008 without explicit learner agreement.

---

*Fictional BI learning assignment based on synthetic data. Not a task from a real employer.*
