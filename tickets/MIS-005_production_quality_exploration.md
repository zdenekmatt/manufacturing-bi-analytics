# MIS-005 — Production Quality Data Exploration

**Ticket ID:** MIS-005  
**Type:** Standard Task / Data Exploration  
**Requestor:** Quality Manager (simulated)  
**Priority:** Medium  
**Status:** Ready for Final Review  
**Difficulty:** Beginner → Junior  
**Estimated work time:** 120–180 minutes (guide only, not a deadline)  
**Actual work time:** Approximately 80 minutes (learner estimate)

## Business Context

You are a Junior BI Analyst at Moravia Industrial Systems, a fictional manufacturing company.

We have already explored production orders, operation hours and production delays. The Quality Manager now wants a first look at quality inspection records. We want to understand what was inspected, how many defective pieces were recorded and how these quantities differ across production lines.

This is **exploratory work**. Do not create an official quality KPI or claim to know why defects occur.

## Objective

Explore production quality inspections with PostgreSQL, understand the record grain, compare recorded quantities by production line, validate basic results and write short business findings in B1 English.

## Core Requirements

### Level 1 — Explore the Quality Data

**Task 5.1 — First Look at Quality Inspections**  
Show five rows from `mis.quality_events` with `quality_event_id`, `production_order_id`, `inspection_date`, `inspected_qty`, `defective_qty` and `inspection_result`. Write **one simple English sentence** explaining what one row represents.

**Task 5.2 — Record Counts and Dates**  
Find the number of inspection events, the number of distinct `production_order_id` values found in the inspection table and the earliest/latest `inspection_date`. Do not assume yet that every production order has an inspection event.

**Task 5.3 — Inspection Results**  
Show each `inspection_result` and its number of events. Sort by the largest number of events first. Describe what the categories mean in the context of the table, without inventing additional quality rules.

### Level 2 — Understand Inspected and Defective Quantities

**Task 5.4 — Total Inspected and Defective Quantities**  
Find the total `inspected_qty` and the total `defective_qty` across inspection events. Both columns measure **pieces**, not numbers of orders or events.

**Task 5.5 — Events with Defects**  
Count inspection **events** with `defective_qty > 0` and those with `defective_qty = 0`. Explain why the number of events with defects is not the same as the number of defective pieces.

### Level 3 — Compare Production Lines

**Task 5.6 — Inspection Quantities by Line**  
Connect `mis.quality_events`, `mis.production_orders` and `mis.production_lines`. For each `line_code`, show the number of inspection events, total inspected quantity and total defective quantity. Sort by total defective quantity, highest first. Be careful about the grain of the joined result.

**Task 5.7 — Exploratory Defective-Piece Share by Line**  
For each production line, calculate `total defective pieces / total inspected pieces × 100` and show the result as a percentage with two decimal places. Sort from the highest percentage to the lowest. Explain in **one English sentence** why a number of defective pieces and a percentage can tell different stories.

This percentage is **exploratory**, not an approved Defect Rate KPI. Use quantities as the numerator and denominator, not numbers of inspection events.

### Level 4 — Validate and Communicate

**Task 5.8 — Basic Validation**  
Perform these checks, keeping the SQL simple:
- Check whether any inspection event has a missing or negative `inspected_qty` / `defective_qty`, or has `defective_qty > inspected_qty`.
- Check that the **unrounded** totals across production lines from Task 5.6 reconcile to the source totals from Task 5.4.
- Check whether each quality event remains a single event after joining the related production and line tables. Report any unexpected duplication or missing matches.

**Task 5.9 — Initial Findings**  
Write **three short findings** using actual SQL results and **one question for future analysis**, in simple English (B1). Distinguish observations from possible explanations.

## Required Checks and Interpretation

- Grain: one row of `mis.quality_events` represents **one finished-order inspection event**. Do not assume the number of events always equals the number of production orders.
- `inspected_qty` and `defective_qty` are **pieces**. `inspection_result` is a label, not a quantity.
- `defective_qty` is a subset of `inspected_qty` for an event; check the relationship before interpreting totals.
- A production line with more defective pieces is not necessarily the line with the highest defective-piece percentage.
- Keep counts of events, counts of distinct production orders and counts of defective pieces separate.
- Do not claim that a quality event caused production delays, reduced efficiency or affected customer shipments unless there is additional evidence.
- No further QA steps may be made mandatory during review without discussing a change of scope.

## Optional Challenge — Not Required for Approval

Use production-order dates to compare an inspection measure between **Late** and **Not Late** completed orders. First choose and state the measure and denominator; avoid claiming a causal relationship. Keep this optional analysis separate from the nine core tasks.

## Expected Deliverables

- **Ticket:** `tickets/MIS-005_production_quality_exploration.md`
- **SQL:** `sql/investigations/MIS-005_production_quality_exploration.sql`
- **Findings:** `docs/MIS-005_findings.md`

Create the SQL and Findings files as you work through the tasks. You do not need to prepare the final portfolio formatting before code review.

## Acceptance Criteria

- Tasks 5.1–5.9 completed and reviewed.
- SQL runs in PostgreSQL 18, is readable and answers the questions at the correct grain.
- Counts and quantity totals are validated; JOINs do not silently duplicate or drop inspection events.
- Exploratory percentages use the correct quantity denominator.
- Three short, evidence-based B1-English findings and one future question are recorded.
- No unsupported quality KPI, causality or performance claims.

## Review

**Current status:** Ready for Final Review — tasks 5.1–5.9 reviewed; learner submitted queries and results.  
**Actual work time:** Approximately **80 minutes** (learner estimate; below initial 120–180 minute guide).  
**Evidence:** 15,210 inspection events and distinct inspected orders; 1,920,612 inspected pieces; 11,165 defective pieces; line totals reconciled; quantity and JOIN grain checks passed according to learner's SQL outputs.  
**Portfolio edits:** SQL was reconstructed from the conversation, formatted, and adjusted to show requested `line_code` and all required output columns. Task 5.5's original event-count query was added for completeness; the learner's `Pass` versus positive-defective-quantity check is retained separately.  
**Remaining for final approval:** Run the packaged SQL locally and confirm the added Task 5.5 event counts; the mentor cannot directly execute SQL against the learner's PostgreSQL database.  
**Next ticket:** Do not start MIS-006 without explicit learner approval.

---

*Fictional BI learning assignment based on synthetic data. Not a task from a real employer.*
