# MIS-004 — Production Timeliness & Workload Exploration: Findings

**Project:** Manufacturing BI Analyst Simulation — Moravia Industrial Systems  
**Ticket:** MIS-004  
**Status:** Ready for final review (edited SQL not yet re-run locally)  
**Data:** Synthetic manufacturing dataset v1.0.0  
**Database:** PostgreSQL 18, schema `mis`  
**Actual work time:** Approximately 2 hours 10 minutes (130 minutes)

## Goal

I compared planned and actual completion dates for production orders. I also compared recorded labor hours for late and not-late completed orders. This is an exploratory analysis, not an official KPI report.

## Task 4.1 — First Look at Planned and Actual Dates

One row in `mis.production_orders` represents one production order with its production line, status, planned end date and actual completion date.

- `production_order_id` identifies the production order.
- `line_id` identifies the production line assigned to the order.
- `status` shows whether the order is Completed or Open.
- `planned_end_date` shows the planned completion date.
- `actual_completion_date` shows the actual completion date, when available.

## Task 4.2 — Late vs. Not Late Completed Orders

| Completion category | Orders |
|---|---:|
| Late | 5,479 |
| Not Late (on time or early) | 9,731 |
| **Total completed** | **15,210** |

There are 77 open production orders in the full `production_orders` table, but they are excluded from this completed-order comparison.

## Task 4.3 — Delay Days

| Measure | Result |
|---|---:|
| Late completed orders | 5,479 |
| Maximum delay | 10 calendar days |
| Average delay among late orders | 4.20 calendar days |

The average delay applies **only to late completed orders**, not to all completed production orders.

## Task 4.4 — Late Orders by Production Line

| Production line | Completed orders | Late orders | Not-late orders |
|---|---:|---:|---:|
| LN-01 | 2,813 | 973 | 1,840 |
| LN-02 | 2,695 | 1,030 | 1,665 |
| LN-03 | 2,447 | 834 | 1,613 |
| LN-04 | 2,345 | 833 | 1,512 |
| LN-05 | 2,538 | 972 | 1,566 |
| LN-06 | 2,372 | 837 | 1,535 |
| **Total** | **15,210** | **5,479** | **9,731** |

LN-02 has the highest **number** of late completed orders: 1,030.

## Task 4.5 — Late Share by Production Line

**Definition:** Late share = late completed orders / all completed orders on the same line × 100.

| Production line | Completed orders | Late orders | Late share |
|---|---:|---:|---:|
| LN-05 | 2,538 | 972 | 38.30% |
| LN-02 | 2,695 | 1,030 | 38.22% |
| LN-04 | 2,345 | 833 | 35.52% |
| LN-06 | 2,372 | 837 | 35.29% |
| LN-01 | 2,813 | 973 | 34.59% |
| LN-03 | 2,447 | 834 | 34.08% |

LN-05 has the highest **percentage** of late completed orders. LN-02 has the highest **count**. These measures answer different questions because the lines have different numbers of completed orders. The difference between LN-05 and LN-02 is only 0.08 percentage points.

The percentage is exploratory and is **not an approved production KPI**.

## Task 4.6 — Recorded Labor Hours per Completed Order

I joined `production_orders` with `production_operations` and summed `labor_hours` for each completed production order.

Examples from the SQL output:

| Production order ID | Total recorded labor hours |
|---|---:|
| 1 | 14.801 |
| 2 | 3.012 |
| 3 | 14.884 |
| 4 | 24.225 |
| 5 | 19.797 |

One result row represents one production order, not one operation. Labor hours are the sum of recorded operation hours, not necessarily the elapsed calendar time of production.

## Task 4.7 — Labor Hours: Late vs. Not Late

| Completion category | Production orders | Average recorded labor hours per order |
|---|---:|---:|
| Late | 5,479 | 8.21 |
| Not Late | 9,731 | 8.34 |

Late orders have an average of **0.13 fewer recorded labor hours** per production order than not-late orders (based on rounded averages). This small difference does not show what caused delays.

## Task 4.8 — Basic Validation

| Check | Result |
|---|---:|
| Rows in the final completed-order comparison | 15,210 |
| Distinct production order IDs | 15,210 |
| Late + Not Late | 15,210 |
| Known total completed production orders | 15,210 |

The final comparison has one row per completed production order. The category counts add up to the known completed-order total, and the results show no missing completed orders in this comparison.

These checks do not validate every possible data-quality issue in the wider database.

## Task 4.9 — Initial Findings

### Three key findings

**1. Completed production orders**  
We have **15,210 completed production orders**. Of these, **5,479** were completed late and **9,731** were completed on time or early.

**2. Delays across production lines**  
The average delay for late orders was **4.20 calendar days**. Production line **LN-05** had the highest percentage of late orders (**38.30%**), while **LN-02** had the highest number of late orders (**1,030**).

**3. Recorded labor hours**  
Late production orders had an average of **8.21 labor hours**, compared with **8.34 hours** for not-late orders. The difference is small and does not explain the cause of delays.

### Question for future analysis

**Is there a difference in recorded machine hours between late and not-late production orders?**

## Methods and Limits

- Only orders with `status = 'Completed'` are included in late/not-late comparisons.
- `actual_completion_date > planned_end_date` means Late; a date equal to or before the planned end date means Not Late.
- Delay is measured in calendar days, not working days.
- For labor-hour comparisons, operation hours are summed **per production order** before category averages are calculated.
- Counts and percentages are descriptive results from synthetic data. They do not establish causes, employee or machine efficiency, or customer delivery delays.
- Values and tables above come from the learner's SQL outputs discussed during mentoring. The final formatted SQL file still needs a local re-run before the ticket can be marked Approved.

## Review Summary

All Tasks 4.1–4.9 were completed and reviewed during mentoring. The learner independently used `COUNT(*) FILTER (WHERE ...)`, a percentage calculation with `NULLIF`, and two CTEs for the order-level labor-hour comparison. The mentor helped refine English B1 findings, interpreted the difference between counts and percentages, and edited formatting and aliases for the portfolio files.

**Next step:** Run the edited SQL file in PostgreSQL and confirm the results. No new task is required for this ticket.
