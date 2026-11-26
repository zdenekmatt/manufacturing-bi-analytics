# MIS-003 — Production Hours & Workload Exploration

**Type:** Standard Task / Data Exploration  
**Requestor:** Production Planning Manager (simulated)  
**Priority:** Medium  
**Status:** Ready for final review  
**Estimated work time:** 90–150 minutes (guide only)

## Business Context

You work as a Junior BI Analyst at Moravia Industrial Systems.

We know the number of production orders and operations. Now the production team wants to understand the recorded working hours. We have labor hours and machine hours for each production operation. We need a simple analysis before we build production reports.

## Objective

Explore recorded labor and machine hours with SQL. Compare operation types and production lines. Check the results and write simple business findings. This is an exploratory analysis, not an approved efficiency or cost KPI.

## Core Requirements

### Level 1 — Explore the Hours

**Task 3.1 — First Look at Working Hours**  
Show five rows from `mis.production_operations` with `operation_id`, `production_order_id`, `operation_type`, `labor_hours` and `machine_hours`. In your own words, explain what one row represents and what the two hour columns measure.

**Task 3.2 — Total Recorded Hours**  
Find the total recorded `labor_hours` and total recorded `machine_hours` across all production operations. Give the results clear column names.

**Task 3.3 — Hours by Operation Type**  
For each `operation_type`, show the number of operations, total labor hours, total machine hours and average labor hours per operation. Sort by total labor hours, highest first.

### Level 2 — Understand Production Workload

**Task 3.4 — Hours per Production Order**  
Calculate total labor hours and total machine hours for each `production_order_id`. Show the five orders with the highest recorded labor hours.

**Task 3.5 — Workload by Production Line**  
Connect `mis.production_operations`, `mis.production_orders` and `mis.production_lines`. Show each `line_code`, the number of operation records and the total labor and machine hours. Sort by total labor hours, highest first.

**Task 3.6 — Average Labor Hours per Production Order by Line**  
For each production line, find the average total labor hours **per production order with recorded operations**. Do not confuse the average per operation with the average per order. You may use a subquery or CTE if it helps.

### Level 3 — Practice and Validate

**Task 3.7 — Orders with Higher Recorded Labor Hours**  
Count how many production orders have **more than 15 total labor hours**, using the summed hours across their operations. This is an exploratory threshold, not a business target. Try a CTE or a subquery.

**Task 3.8 — Basic Validation**  
Check whether there are any missing or negative labor or machine hour values. Verify that sums of hours by operation type and by production line match the overall totals from Task 3.2.

### Level 4 — Communicate Findings

**Task 3.9 — Initial Findings**  
Write three short findings in simple English (B1), based on your SQL results, and one question for future analysis.

## Required Checks

- Keep the right grain: an operation is not a production order.
- Do not add labor hours and machine hours together and call the result elapsed production time. These are different measures and may overlap.
- When joining production orders and operations, confirm that grouped totals reconcile with the operation-level totals.
- Describe recorded workload, not employee productivity, line efficiency, costs or causes of delays without further evidence.
- Use real SQL output for all reported totals and findings.

## Optional Challenge

For one of your grouped analyses, compare your original subquery with a CTE and explain which version you find easier to read. This is not required for approval.

## Expected Deliverables

- **SQL:** `sql/investigations/MIS-003_production_hours_exploration.sql`
- **Findings:** `docs/MIS-003_findings.md`
- **Ticket:** `tickets/MIS-003_production_hours_exploration.md`

## Acceptance Criteria

- Tasks 3.1–3.9 completed and reviewed.
- SQL is correct, readable and reproducible.
- Grain and summed hours are validated.
- Three short B1-English findings and one future question are supported by SQL results.
- No unsupported efficiency, cost or delay claims.

## Review

**Mentoring review:** Tasks 3.1–3.9 were completed and reviewed in the conversation. The learner independently developed the SQL, including a two-stage CTE for averages per production order and a `HAVING` solution for the 15-hour threshold. The findings were edited into clear B1 English.

**Quality checks:** No NULL or negative labor/machine hours were reported. The unrounded source totals and totals after joining orders and lines matched. The grouped breakdowns are shown in Tasks 3.3 and 3.5.

**Next step:** Run the final edited SQL file on the local PostgreSQL database. After successful verification, mark MIS-003 Approved and update `PROJECT_CONTEXT.md`. Do not start MIS-004 until the learner agrees.

---

*Fictional BI learning assignment based on synthetic data. Not a task from a real employer.*
