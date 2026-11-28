# MIS-008 — Supplier Procurement & Goods Receipts Exploration

**Ticket ID:** MIS-008  
**Type:** Standard Task / Investigation  
**Requestor:** Procurement & Supply Chain Manager (simulated)  
**Priority:** Medium  
**Status:** Approved — 9/9 tasks reviewed  
**Difficulty:** Beginner → Junior (one more challenging CTE analysis)  
**Estimated work time:** 120–180 minutes, flexible; record actual time at the end  
**Database:** `manufacturing_bi` — PostgreSQL 18, schema `mis`  
**Dataset:** Synthetic manufacturing baseline v1.0.0

## Business Context

You are a Junior BI Analyst at Moravia Industrial Systems, a fictional manufacturing company.

In MIS-007, we explored inventory movements. Now the Procurement & Supply Chain Manager wants to understand **material purchasing and supplier goods receipts**.

We want to learn who supplies materials, how purchase-order lines are recorded, whether materials arrive in one or several receipts, and how actual receipt dates compare with supplier-confirmed dates.

This is exploratory work. **Do not** claim that a late supplier receipt caused a production delay or a material shortage. Do not define an official supplier on-time delivery KPI in this ticket.

## Data Sources and Grain

| Table | Grain | Main columns |
| --- | --- | --- |
| `mis.suppliers` | One fictional supplier | `supplier_id`, `supplier_code`, `supplier_name`, `supplier_country` |
| `mis.purchase_order_lines` | One supplier-material purchase-order line | `purchase_order_line_id`, `supplier_id`, `material_id`, `order_date`, `confirmed_date`, `ordered_qty`, `currency` |
| `mis.goods_receipts` | One recorded receipt event against a purchase-order line | `goods_receipt_id`, `purchase_order_line_id`, `receipt_date`, `accepted_qty`, `rejected_qty` |

Relationships:
- `suppliers.supplier_id` → `purchase_order_lines.supplier_id` (one-to-many).
- `purchase_order_lines.purchase_order_line_id` → `goods_receipts.purchase_order_line_id` (one-to-many).

**Important:** A purchase-order line may have **more than one receipt event**. Joining receipts directly to order lines may repeat `ordered_qty` and inflate totals. `accepted_qty` and `rejected_qty` are different quantities. A supplier's `confirmed_date` is not the same as a `receipt_date`.

## Core Requirements

### Level 1 — Explore

**Task 8.1 — First Look at Procurement Data**  
Show five rows from each of these three tables:
- `mis.suppliers`: `supplier_id`, `supplier_code`, `supplier_name`, `supplier_country`.
- `mis.purchase_order_lines`: `purchase_order_line_id`, `supplier_id`, `material_id`, `order_date`, `confirmed_date`, `ordered_qty`.
- `mis.goods_receipts`: `goods_receipt_id`, `purchase_order_line_id`, `receipt_date`, `accepted_qty`, `rejected_qty`.

Write one short English sentence (B1) for each table to explain what one row means.

**Task 8.2 — Counts and Date Coverage**  
Find the number of suppliers, purchase-order lines, and goods-receipt events. Find the earliest and latest `order_date` in `mis.purchase_order_lines` and `receipt_date` in `mis.goods_receipts`. Use simple SELECT queries. Do not assume that one receipt means one purchase-order line.

### Level 2 — Understand Procurement

**Task 8.3 — Suppliers by Country**  
Show `supplier_country` and the number of suppliers in each country. Sort by supplier count, highest first. Explain which country has the most supplier records. This is supplier location, not the delivery destination.

**Task 8.4 — Purchase-Order Lines by Currency**  
For each `currency`, show the number of purchase-order lines and the total `ordered_qty`. Sort by line count, highest first. **Do not sum `unit_price` as total spending** and do not mix monetary values across currencies. Summed quantities across different materials describe volume, not the stock balance of a material.

**Task 8.5 — Goods Receipts and Partial Deliveries**  
First, find the number of goods-receipt events and the total `accepted_qty` and `rejected_qty`. Next, group receipts by `purchase_order_line_id` and find how many purchase-order lines have **more than one receipt event**. Explain why receipt count and purchase-order-line count can differ. Keep the required output simple.

### Level 3 — Connect and Analyze

**Task 8.6 — Purchase Orders by Supplier**  
Join `mis.suppliers` to `mis.purchase_order_lines`. For each `supplier_code`, show the number of purchase-order lines and the total ordered quantity. List the five suppliers with the largest number of order lines. Sort by line count, highest first. **Do not join receipts for this task**; this avoids multiplying ordered quantities across partial receipts. Do not interpret total pieces as financial spending.

**Task 8.7 — Receipt Timing vs. Confirmed Date**  
For each purchase-order line, find the **latest** `receipt_date` (the last recorded receipt for that line). Compare it with `confirmed_date`:
- `Late`: last receipt is **after** the confirmed date.
- `Not Late`: last receipt is **on or before** the confirmed date.
- `No Receipt`: no receipt was recorded for the line, if this occurs.

Show the number of **purchase-order lines** in each group. A CTE or subquery may help. Clearly state that this is an exploratory last-receipt-date comparison, not an official supplier performance KPI. Do not claim lateness caused production delays.

### Level 4 — Validate and Communicate

**Task 8.8 — Basic Validation**  
Check that `goods_receipt_id` values are not unexpectedly duplicated. Check that the number of goods-receipt events and total **unrounded** `accepted_qty` and `rejected_qty` do not change after joining receipts to purchase-order lines and suppliers. Verify that the purchase-order-line-level output in Task 8.7 contains one row per line before you group it into status categories. Do not add more mandatory tests.

**Task 8.9 — Initial Findings**  
Write **three short findings** in English (B1), each supported by your SQL results. Add **one question for future analysis**. Distinguish observed purchase orders and receipts from unverified explanations about shortages, supplier reliability, costs or production delays.

## Required Validation and Interpretation

- Distinguish suppliers, **purchase-order lines**, and **receipt events**.
- Never count a receipt event as a unique purchase-order line without checking its ID.
- Avoid multiplying `ordered_qty` by joining directly to multiple receipts.
- `confirmed_date` is a supplier-confirmed date; `receipt_date` is a recorded goods-receipt date.
- `accepted_qty` is received usable material; `rejected_qty` is separately rejected material and must not be added to accepted stock.
- Currency is recorded on purchase-order lines; no official procurement spending or foreign-exchange KPI is required.
- No official supplier OTD, material-shortage or purchasing-cost KPI will be defined in MIS-008.
- Scope is fixed to Tasks 8.1–8.9 plus the optional challenge. No surprise mandatory QA during mentoring.

## Optional Challenge — Not Required for Approval

For purchase-order lines with more than one receipt, compare the **first receipt date** with the **last receipt date** relative to `confirmed_date`. Explain why the definition of "on time" matters. This is optional and should not delay approval.

## Expected Deliverables

- **Ticket:** `tickets/MIS-008_supplier_procurement_exploration.md`
- **SQL (after review):** `sql/investigations/MIS-008_supplier_procurement_exploration.sql`
- **Findings (after review):** `docs/MIS-008_findings.md`

The Junior BI Analyst writes and tests SQL during the work. The mentor helps with focused explanations, code review and final B1 document formatting. The mentor must say when code is AI-provided rather than learner-written.

## Acceptance Criteria

- Tasks 8.1–8.9 reviewed; agreed fixes completed.
- Outputs use the correct supplier, purchase-order-line or receipt-event grain.
- Receipt totals reconcile through joins; the order-line timing result does not duplicate lines.
- Three evidence-based B1-English findings and a future analysis question are provided.
- No unsupported claim of supplier-caused production delays or material shortages.

## Review / Handoff

**Status:** **Approved — 9/9 tasks reviewed** during mentoring on 2026-11-27.  
**Actual work time:** Approximately **60 minutes (1 hour)**, reported by the learner; planned 120–180 minutes.  
**Deliverables:**
- `tickets/MIS-008_supplier_procurement_exploration.md`
- `sql/investigations/MIS-008_supplier_procurement_exploration.sql`
- `docs/MIS-008_findings.md`

**Key reviewed results:** 30 suppliers, 5,247 purchase-order lines and 7,476 goods receipt events; 2,229 lines with multiple receipts; 2,995 Late and 2,252 Not Late lines in the last-receipt-date comparison. No Receipt: zero lines in the observed dataset.  
**Validation:** Receipt IDs were unique; the counts and unrounded accepted/rejected quantities matched before and after joins. The last-receipt analysis kept 5,247 distinct lines in 5,247 rows. These checks were reported from the learner's PostgreSQL output.  
**Authorship and mentoring:** Most SQL and the three B1 findings were written by the learner. The mentor corrected English and explained JOIN grain and the need for `LEFT JOIN`. The compiled SQL also restores the previously submitted Task 8.5 overview, adds missing statement separators and explicit Task 8.1 columns, and standardizes formatting and aliases.  
**Final local verification:** **Not yet confirmed.** The assembled formatted SQL file has not been run end-to-end after these edits. Ticket approval refers to the reviewed tasks and reported results, not independent execution of the final package.  
**Next step:** Add the three files to GitHub. Do not start MIS-009 without explicit learner approval.

---

*Fictional training assignment using synthetic data. Not an internal task from any real company.*
