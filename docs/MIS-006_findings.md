# MIS-006 — Production Downtime Exploration: Findings

**Project:** Manufacturing BI Analyst Simulation — Moravia Industrial Systems  
**Ticket:** MIS-006  
**Status:** Ready for final local SQL verification (9/9 tasks reviewed)  
**Data:** Synthetic manufacturing dataset v1.0.0  
**Database:** PostgreSQL 18, schema `mis`  
**Actual work time:** Approximately **80 minutes** (learner estimate)

## Goal

I explored recorded downtime events in production. I compared event counts and total minutes by category, operation type and production line. I also compared downtime for late and not-late completed production orders.

This is an exploratory analysis, not an official machine-availability, OEE or downtime-cost report.

## Task 6.1 — First Look at Downtime Events

One row in `mis.downtime_events` represents one reported downtime event linked to a production operation.

| Column | Meaning |
|---|---|
| `downtime_id` | Unique ID for a downtime event |
| `operation_id` | Related production operation ID |
| `event_date` | Date of the downtime event |
| `duration_minutes` | Reported length of the event in minutes |
| `downtime_category` | Recorded type of downtime |
| `is_planned` | TRUE if the downtime was planned; FALSE if not |

An event, a production operation and a production order are different units of analysis.

## Task 6.2 — Event Counts and Dates

| Measure | Result |
|---|---:|
| Downtime events | 10,397 |
| Different operations with downtime events | 9,510 |
| Earliest event date | 2024-10-04 |
| Latest event date | 2026-10-27 |

There are more downtime events than operations with downtime. Some operations therefore have more than one recorded downtime event.

## Task 6.3 — Downtime Categories

| Downtime category | Events | Total minutes |
|---|---:|---:|
| Maintenance | 2,106 | 192,423 |
| Setup | 2,106 | 190,561 |
| Tooling | 2,054 | 187,134 |
| Material Wait | 2,061 | 184,942 |
| Equipment Fault | 2,070 | 183,480 |
| **Total** | **10,397** | **938,540** |

**Maintenance** had the highest total downtime (192,423 minutes). The five categories had similar total minutes, but they did not have identical results.

The category with the most events does not always have the longest total duration. Event counts and total minutes answer different questions.

## Task 6.4 — Planned vs. Unplanned Downtime

| is_planned | Description | Events | Total minutes |
|---|---|---:|---:|
| FALSE | Unplanned downtime | 8,872 | 800,820 |
| TRUE | Planned downtime | 1,525 | 137,720 |
| **Total** | | **10,397** | **938,540** |

Most recorded downtime events were unplanned. Unplanned events also had higher total downtime minutes.

A large number of short events and a small number of long events can affect production in different ways. The current analysis does not measure these impacts.

## Task 6.5 — Downtime by Operation Type

| Operation type | Events | Total minutes |
|---|---:|---:|
| Testing | 3,530 | 321,440 |
| Preparation | 3,486 | 314,896 |
| Assembly | 3,381 | 302,204 |
| **Total** | **10,397** | **938,540** |

Testing had the highest number of downtime events and the highest total minutes. The data does not show why this happened.

## Task 6.6 — Downtime by Production Line

| Production line | Events | Total minutes |
|---|---:|---:|
| LN-01 | 1,912 | 172,833 |
| LN-02 | 1,857 | 165,822 |
| LN-05 | 1,720 | 155,467 |
| LN-03 | 1,659 | 150,361 |
| LN-06 | 1,639 | 148,378 |
| LN-04 | 1,610 | 145,679 |
| **Total** | **10,397** | **938,540** |

LN-01 had the highest total recorded downtime (172,833 minutes). This does **not** prove that LN-01 is the least efficient line. Production volumes and other context may differ between lines.

## Task 6.7 — Downtime and Completion Timeliness

We grouped downtime minutes by production order and then compared all **completed** production orders. Orders with no downtime events were included with **zero minutes**.

| Completion status | Completed orders | Average downtime minutes per order |
|---|---:|---:|
| Late | 5,479 | 62.61 |
| Not Late | 9,731 | 61.20 |
| **Total orders** | **15,210** | — |

Late orders had **1.41 more recorded downtime minutes per order on average** than orders completed on time or early. This difference is descriptive. It does **not** prove that downtime caused late completion.

## Task 6.8 — Basic Validation

The original downtime table and the result after joining to operations, orders and production lines gave the same results:

| Validation measure | Original events | After JOINs |
|---|---:|---:|
| Total rows / events | 10,397 | 10,397 |
| Unique `downtime_id` values | 10,397 | 10,397 |
| Total downtime minutes | 938,540 | 938,540 |

The invalid-duration check returned **no rows**. No missing, zero or negative `duration_minutes` values were found.

These checks support the joins and durations used in this analysis. They do not prove that every possible data-quality problem has been ruled out.

## Task 6.9 — Three Key Findings

**1. Total Production Downtime**  
We recorded **10,397 downtime events** with a total of **938,540 downtime minutes**.

**2. Unplanned Downtime**  
We found **8,872 unplanned downtime events** and **1,525 planned events**. Most downtime events were unplanned.

**3. Downtime Categories**  
The five downtime categories had similar total downtime minutes. **Maintenance** had the highest total, with **192,423 minutes**.

### Question for Future Analysis

**Why do we have so many downtime events, and why do some events last longer than others?**

We need more information before we can explain the reasons for these events.

## Method and Limitations

- `COUNT(*)` counts downtime **events** in the event-based queries; it does not count different operations or production orders.
- `SUM(duration_minutes)` measures **reported event minutes**, not the elapsed duration of an entire production order.
- Planned/unplanned is based on the recorded boolean field `is_planned`.
- Task 6.7 includes **all completed production orders**, including orders with no reported downtime.
- We did not calculate official OEE, downtime costs or machine availability.
- We cannot conclude that downtime caused delayed orders, or that a line with more total minutes is less efficient.
- The data is synthetic and intended for a learning portfolio.

## Review Status

All nine tasks were reviewed and approved during mentoring, and the learner confirmed the Task 6.8 validation outputs. The SQL file was assembled from the learner's shared queries and from the mentor-provided Task 6.8 checks. Minor presentation changes were made, including sorting, explicit columns and an additional `COALESCE` in Task 6.7 for robustness.

**Ready for Final Review:** The assembled final SQL file has not been independently executed against the learner's local PostgreSQL after these edits. Final local execution is needed before marking the portfolio files as **Approved**.
