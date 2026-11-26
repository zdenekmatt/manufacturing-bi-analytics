# MIS-004 — Production Timeliness & Workload Exploration

**Type:** Standard Task / Data Exploration  
**Requestor:** Production Planning Manager (simulated)  
**Priority:** Medium  
**Status:** Ready for final review  
**Difficulty:** Beginner → Junior  
**Estimated work time:** 120–180 minutes (guide only, not a deadline)  
**Actual work time:** Approximately 130 minutes (2 hours 10 minutes; learner-reported, within the estimate)

## Business Context

You work as a Junior BI Analyst at Moravia Industrial Systems.

We have explored production orders, production dates and recorded labor hours. The production team now wants to compare planned and actual completion dates. We also want to see whether orders completed later than planned have different recorded labor hours.

This is **exploratory analysis**. We are not defining an official production KPI, proving a cause of delay, or measuring customer delivery performance.

## Objective

Explore production timeliness in PostgreSQL, compare results across production lines and combine order-level dates with recorded operation-level hours. Explain findings in simple B1 English.

## Core Requirements

### Level 1 — Understand the Dates

**Task 4.1 — First Look at Planned and Actual Dates**  
Show five rows from `mis.production_orders` with `production_order_id`, `line_id`, `status`, `planned_end_date` and `actual_completion_date`. In one simple English sentence, explain what one row represents. Note which orders can be evaluated for completion timeliness.

**Task 4.2 — Late vs. Not Late Completed Orders**  
For production orders with `status = 'Completed'`, count how many were completed **later than** the planned end date and how many were completed **on or before** it. Report both counts and their total. Use calendar dates and classify the two groups clearly.

### Level 2 — Compare Production Lines

**Task 4.3 — Delay Days**  
For completed orders finished later than planned, calculate the delay in **calendar days**. Show the number of late orders, the largest delay and the average delay among **late orders only**.

**Task 4.4 — Late Orders by Production Line**  
Compare completed orders across the six production lines. Show `line_code`, the number of completed orders, the number of late completed orders and the number of completed orders that were not late.

**Task 4.5 — Late Share by Production Line**  
Calculate the percentage of completed production orders that were late for each line. Use **completed orders** as the denominator and sort from the highest percentage to the lowest. Treat this as an exploratory percentage, **not an approved KPI**. Explain in one sentence why a count and a percentage answer different questions.

### Level 3 — Relate Dates and Workload

**Task 4.6 — Recorded Labor Hours per Completed Order**  
Create an order-level result that includes `production_order_id`, `line_id`, planned and actual completion dates, and the **total recorded labor hours across operations**. Make sure one row means one production order.

**Task 4.7 — Compare Late and Not-Late Orders**  
Use the order-level results to compare the average total recorded labor hours for late and not-late completed production orders. Show the number of orders and the average labor hours in each group. Describe the difference without claiming that labor hours caused any delay.

### Level 4 — Validate and Communicate

**Task 4.8 — Basic Validation**  
Check that the late and not-late completed-order counts add up to the total number of completed production orders. Check that combining operation-level hours with orders does not duplicate order records in the final order-level result. Explain any missing records before using them in the comparison. Keep the checks short and relevant.

**Task 4.9 — Initial Findings**  
Write **three short findings** using real SQL results and **one question for future investigation**, in simple English (B1). Make clear when an observed difference is not evidence of a cause.

## Required Checks

- Use `planned_end_date` versus `actual_completion_date` for **completed production orders**.
- `actual_completion_date > planned_end_date` means late; equal dates are **not late**.
- Order-level results must have **one row per production order**. Operations are a separate one-to-many table.
- For any percentage, state the denominator explicitly.
- Validate the grouped counts against the completed-order total.
- Do not claim that late production orders necessarily caused late customer deliveries.
- Do not infer why an order was late from association with labor hours.

## Optional Challenge — Not Required for Approval

Find a clear way to make the two groups (`Late`, `Not Late`) easy to reuse across queries. Explain briefly whether a CTE makes your SQL easier to read. Do not build a permanent VIEW for this ticket unless there is a specific reuse need.

## Expected Deliverables

- **SQL:** `sql/investigations/MIS-004_production_timeliness_and_workload.sql`
- **Findings:** `docs/MIS-004_findings.md`
- **Ticket:** `tickets/MIS-004_production_timeliness_and_workload.md`

## Acceptance Criteria

- Tasks 4.1–4.9 reviewed and completed.
- SQL is correct, readable and reproducible in PostgreSQL.
- Order/operation grain and counts are consistent.
- Dates and exploratory percentages are interpreted correctly.
- Three short, evidence-based B1-English findings and one future question are included.
- No unsupported causal conclusions or invented KPI definitions.

## Review

**Mentoring review:** Tasks 4.1–4.9 were completed and reviewed during the conversation. The learner wrote the SQL independently, including conditional aggregation with `COUNT(*) FILTER (WHERE ...)`, a percentage calculation protected by `NULLIF`, and CTEs for order-level labor-hour comparison. The mentor suggested small corrections, checked grain and interpretation, and helped edit B1-English findings.

**Validated from learner-submitted SQL results:** 15,210 completed orders = 5,479 Late + 9,731 Not Late; mean delay among late orders 4.20 calendar days, maximum 10 days; LN-05 has the highest late share (38.30%), while LN-02 has the highest late count (1,030). Late orders average 8.21 recorded labor hours per order versus 8.34 for Not Late. The order-level comparison contains 15,210 rows and 15,210 distinct production order IDs.

**Actual work time:** Approximately **2 hours 10 minutes (130 minutes)**, reported by the learner. Initial estimate: 120–180 minutes.

**Status / next step:** **Ready for final review.** The final portfolio SQL has been reformatted and minor aliases corrected. The mentor has not executed the edited file on the learner's local PostgreSQL database. After a successful local re-run, MIS-004 may be marked **Approved** and `PROJECT_CONTEXT.md` updated. Do not open MIS-005 without the learner's agreement.

---

*Fictional BI learning assignment based on synthetic data. Not a task from a real employer.*
