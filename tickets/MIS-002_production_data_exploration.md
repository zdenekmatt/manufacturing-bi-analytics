# MIS-002 — Production Data Exploration

**Type:** Standard Task / Data Exploration  
**Requestor:** Production Planning Manager (simulated)  
**Priority:** Medium  
**Status:** Ready for final review  
**Estimated work time:** 90–150 minutes (guide only)

## Business Context

You work as a Junior BI Analyst at Moravia Industrial Systems.

The production team needs a simple overview of the production data. Before we build reports, we need to understand production lines, production orders and operations.

## Objective

Explore production data with SQL. Count records, group data, connect tables and find basic patterns. We are not looking for the causes of production problems yet.

## Core Requirements

### Level 1 — Explore the Data

**Task 2.1 — First Look**  
Show five rows from `mis.production_lines`, `mis.production_orders` and `mis.production_operations`. Write one simple sentence about one row in each table.

**Task 2.2 — Record Counts**  
Count the rows in these three tables. Use clear names for the results.

**Task 2.3 — Operation Types**  
List the operation types in `mis.production_operations`. Count the operation records for each type.

### Level 2 — Understand Production Orders

**Task 2.4 — Production Dates**  
Find the first and last `planned_start_date`. For completed orders, find the first and last `actual_completion_date`.

**Task 2.5 — Production Order Status**  
Count production orders by `status`. Say which status has the most orders.

### Level 3 — Connect and Analyze

**Task 2.6 — Orders by Production Line**  
Connect `mis.production_orders` and `mis.production_lines`. Show each `line_code` and its number of orders. Sort from the highest count to the lowest.

**Task 2.7 — Status by Production Line**  
Use the same tables. Count production orders for each `line_code` and `status`.

**Task 2.8 — Operations per Production Order**  
Count operations for each `production_order_id`. Show five production orders with the highest number of operations.

### Level 4 — Small Business Investigation

**Task 2.9 — Completed After the Planned Date**  
Find five completed production orders where `actual_completion_date` is later than `planned_end_date`. Show the order ID, both dates and the difference in calendar days. Sort from the largest delay to the smallest.

**Task 2.10 — Initial Findings**  
Write three short findings in simple English (B1). Add one question for future analysis.

## Required Checks

- Count the right type of record: production line, production order or operation.
- Make sure grouped counts match the table totals when needed.
- Use actual completion dates for completed production orders only.
- Do not say that production delays caused customer delivery delays without more data.

## Optional Challenge

Explore `produced_qty` and `good_qty` for completed production orders. Write one interesting finding. This is **not required** to complete the ticket.

## Expected Deliverables

- **SQL:** `sql/investigations/MIS-002_production_exploration.sql`
- **Findings:** `docs/MIS-002_findings.md`
- **Ticket:** `tickets/MIS-002_production_data_exploration.md`

## Acceptance Criteria

- Tasks 2.1–2.10 are complete.
- SQL queries are correct, clear and can be run again.
- Counts and links between tables are correct.
- Three findings and one future question use the SQL results.
- The findings use simple English.

## Review

**Current status:** Ready for final review. Work and results have been discussed during mentoring. The final edited SQL file has not yet been run on the learner's local PostgreSQL server.

---

*This is a fictional BI learning task with synthetic data. It is not work for a real employer.*
