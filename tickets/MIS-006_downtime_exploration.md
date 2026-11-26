# MIS-006 — Production Downtime Exploration

**Ticket ID:** MIS-006  
**Type:** Standard Task / Investigation  
**Requestor:** Production Planning Manager (simulated)  
**Priority:** Medium  
**Status:** Ready for Final Review — 9/9 tasks reviewed  
**Difficulty:** Beginner → Junior (one more challenging analysis near the end)  
**Estimated work time:** 120–180 minutes, flexible (not a deadline)  
**Actual work time:** Approximately 80 minutes (learner estimate)

## Business Context

You are a Junior BI Analyst at Moravia Industrial Systems, a fictional manufacturer.

Previous tickets explored production operations, working hours, completion delays, and quality inspections. The Production Planning Manager now wants an initial overview of **recorded production downtime**.

We want to understand how many downtime events were reported, how long they lasted, how they differ by event category and production line, and whether late completed orders show different recorded downtime than orders completed on time or early.

**This is exploratory work.** Downtime is not automatically the reason for late production. Do not define an official availability, OEE, or downtime-cost KPI in this ticket.

## Data Sources and Grain

- `mis.downtime_events`: one row = one reported downtime event linked to a production **operation**. Fields include `downtime_id`, `operation_id`, `event_date`, `duration_minutes`, `downtime_category`, `is_planned`.
- `mis.production_operations`: one row = one production operation; connects `operation_id` to `production_order_id` and `operation_type`.
- `mis.production_orders`: one row = one production order, with its assigned `line_id`, `status`, `planned_end_date` and `actual_completion_date`.
- `mis.production_lines`: one row = one production line, with `line_code`.

A downtime **event**, an **operation**, and a production **order** are different grains. Some operations or orders may have no downtime events. `duration_minutes` is an event's reported duration, not necessarily the entire elapsed time of an operation or order.

## Core Requirements

### Level 1 — Explore

**Task 6.1 — First Look at Downtime Events**  
Show five rows from `mis.downtime_events` with these six columns: `downtime_id`, `operation_id`, `event_date`, `duration_minutes`, `downtime_category`, `is_planned`. In one short English sentence, explain what one row represents.

**Task 6.2 — Event Counts and Dates**  
Find the total number of downtime events, the number of distinct operations with a downtime event, and the earliest and latest event dates. Report the results, without assuming that every operation has downtime.

### Level 2 — Understand Duration and Categories

**Task 6.3 — Downtime Categories**  
Show each `downtime_category`, its number of events, and the total recorded downtime minutes. Sort by total minutes, highest first. Name the category with the highest total, without claiming that it is the proven root cause of a business problem.

**Task 6.4 — Planned vs. Unplanned Downtime**  
Compare records where `is_planned` is true versus false. Show event counts and total downtime minutes for both groups. Explain the difference between the number of events and total minutes.

### Level 3 — Connect Production Data

**Task 6.5 — Downtime by Operation Type**  
Connect downtime events to production operations. For each `operation_type`, show the number of downtime events and total reported downtime minutes. Sort by total minutes, highest first. Keep the event grain in mind.

**Task 6.6 — Downtime by Production Line**  
Connect downtime events to production operations, production orders, and production lines. For each `line_code`, show the number of downtime events and total downtime minutes. Sort by total minutes, highest first. Do not label the line with the most minutes as the least efficient without further evidence.

**Task 6.7 — Downtime and Completion Timeliness**  
Compare **completed production orders** in the `Late` and `Not Late` categories. Show the number of completed production orders and the **average total downtime minutes per completed production order** in each category. Orders with no reported downtime must contribute **zero minutes** to the average, not disappear from the comparison. This task is more challenging: you may use a CTE or subquery. Report differences as associations, not proven causes.

### Level 4 — Validate and Communicate

**Task 6.8 — Basic Validation**  
Check that downtime event counts and total *unrounded* minutes agree before and after the required joins for Task 6.6. Check that event IDs are not unexpectedly duplicated. Identify any missing, zero, or negative `duration_minutes` values. Do not add extra mandatory tests beyond these checks.

**Task 6.9 — Initial Findings**  
Write **three short, evidence-based findings** in simple English (B1), using your actual SQL results. Add **one question for future analysis**. Clearly distinguish what the data shows from what would need further investigation.

## Required Validation and Interpretation

- Always state whether a count means events, distinct operations, or production orders.
- `SUM(duration_minutes)` is a sum of **reported event durations**. Do not call it actual production lead time or machine availability.
- `is_planned` is a recorded boolean flag; do not infer that a category is always planned or always unplanned.
- In Task 6.7, **include completed orders with zero downtime events**. An `INNER JOIN` directly from orders to downtime would exclude them.
- Do not confuse aggregate minutes per line with a fair, normalized performance comparison. Lines may have different production volumes.
- The results do not establish that downtime caused late completion or quality defects.
- Do not introduce extra required analysis during code review without agreeing on a scope change.

## Optional Challenge — Not Required for Approval

Convert total recorded downtime minutes to hours for each production line and compare whether the ranking changes. Explain why or why not. Keep this separate from the nine core tasks.

## Expected Deliverables

- **Ticket:** `tickets/MIS-006_downtime_exploration.md`
- **SQL:** `sql/investigations/MIS-006_downtime_exploration.sql`
- **Findings:** `docs/MIS-006_findings.md`

You will write the SQL and findings during the exercises. Portfolio formatting comes after review, using the learner's own queries.

## Acceptance Criteria

- Tasks 6.1–6.9 reviewed, with any requested fixes completed.
- SQL is valid for PostgreSQL 18 and results are at the requested grain.
- Unrounded event counts and minutes reconcile through the relevant joins.
- The Late / Not Late comparison uses **all completed orders**, including orders with zero recorded downtime.
- Three clear B1-English findings and one future question are supported by observed results.
- Exploratory analysis is not presented as a confirmed cause or an approved official business KPI.

## Review / Handoff

**Current status:** Ready for Final Review — all nine tasks were reviewed during mentoring.  
**Actual work time:** Approximately **80 minutes** (learner estimate), against the flexible 120–180-minute planning range.  
**SQL portfolio note:** SQL was assembled from the learner's submitted queries. The Task 6.8 validation queries were provided by the mentor and successfully run by the learner. Minor editorial corrections include Task 6.1's explicit columns, Task 6.5 sorting and an outer `COALESCE` in Task 6.7 to include zero-minute orders robustly.  
**Observed checks:** 10,397 original downtime events; 10,397 unique events after joins; 938,540 total downtime minutes before and after joins; zero rows with missing, zero or negative downtime duration.  
**Outstanding approval step:** Run the compiled SQL file locally in PostgreSQL 18 and confirm that all statements work as expected. The assembled final file has not yet been verified end-to-end after formatting.  
**Preceding ticket:** MIS-005 — 9/9 tasks reviewed; packaged SQL remains Ready for Final Review unless the learner confirms the final local execution.  
**Next ticket:** Do not start MIS-007 without the learner's approval.

---

*Fictional BI learning assignment based on synthetic data. Not a task from a real employer.*
