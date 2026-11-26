# MIS-005 — Production Quality Data Exploration: Findings

**Project:** Manufacturing BI Analyst Simulation — Moravia Industrial Systems  
**Ticket:** MIS-005  
**Status:** Ready for final local SQL verification  
**Data:** Synthetic manufacturing dataset v1.0.0  
**Database:** PostgreSQL 18, schema `mis`  
**Actual work time:** Approximately **80 minutes** (learner's estimate)

## Goal

I explored quality inspection data. I checked how many products were inspected and how many defective pieces were recorded. I also compared results across six production lines.

This is an exploratory analysis, not an official quality KPI report.

## Task 5.1 — First Look at Quality Inspections

One row in `mis.quality_events` represents one quality inspection event related to a production order.

- `quality_event_id`: a unique ID for the inspection event.
- `production_order_id`: the related production order.
- `inspection_date`: the date of inspection.
- `inspected_qty`: the number of inspected pieces.
- `defective_qty`: the number of defective pieces.
- `inspection_result`: the recorded inspection result.

## Task 5.2 — Counts and Dates

| Measure | Result |
|---|---:|
| Quality inspection events | 15,210 |
| Different production orders with an inspection | 15,210 |
| All production orders (for context) | 15,287 |
| Earliest inspection date | 2024-10-10 |
| Latest inspection date | 2026-10-27 |

The number of inspections equals the number of different production orders in the inspection table. Each order **represented in this table** has one inspection event. This does not independently prove that all inspected orders have the status `Completed`.

## Task 5.3 — Inspection Results

| Inspection result | Events |
|---|---:|
| Pass | 12,479 |
| Defect Found | 2,731 |
| **Total** | **15,210** |

`Pass` and `Defect Found` are **event labels**. They are not numbers of defective pieces.

## Task 5.4 — Inspected and Defective Quantities

| Measure | Pieces |
|---|---:|
| Total inspected quantity | 1,920,612 |
| Total defective quantity | 11,165 |
| Exploratory defective-piece share | 0.58% |

We inspected 1,920,612 pieces and found 11,165 defective pieces. The exploratory defective-piece share was 0.58%.

## Task 5.5 — Events with Defects

The original task asks for counts of events with `defective_qty > 0` and `defective_qty = 0`.

During review, I also checked whether any `Pass` inspection had a positive defective quantity. **The check returned no rows.** This verifies one specific consistency rule, not every possible rule.

The full positive-versus-zero event count has been added to the SQL file for the **final local check**. The inspection labels from Task 5.3 were `Defect Found = 2,731` and `Pass = 12,479`, but matching these labels to both quantity categories must not be assumed without that check.

A count of inspection events with defects is not the same as the number of defective pieces. An event can include several defective pieces.

## Task 5.6 — Inspection Quantities by Production Line

| Production line | Inspection events | Inspected pieces | Defective pieces |
|---|---:|---:|---:|
| LN-02 | 2,695 | 340,120 | 2,055 |
| LN-01 | 2,813 | 355,092 | 1,930 |
| LN-03 | 2,447 | 311,163 | 1,906 |
| LN-04 | 2,345 | 289,948 | 1,871 |
| LN-05 | 2,538 | 320,058 | 1,750 |
| LN-06 | 2,372 | 304,231 | 1,653 |
| **Total** | **15,210** | **1,920,612** | **11,165** |

LN-02 has the **highest count of defective pieces**: 2,055. This does not mean it has the highest percentage.

## Task 5.7 — Exploratory Defective-Piece Share by Line

**Calculation:** defective pieces / inspected pieces × 100.

| Production line | Inspected pieces | Defective pieces | Defective-piece share |
|---|---:|---:|---:|
| LN-04 | 289,948 | 1,871 | 0.65% |
| LN-03 | 311,163 | 1,906 | 0.61% |
| LN-02 | 340,120 | 2,055 | 0.60% |
| LN-05 | 320,058 | 1,750 | 0.55% |
| LN-06 | 304,231 | 1,653 | 0.54% |
| LN-01 | 355,092 | 1,930 | 0.54% |

LN-04 has the highest **percentage** of defective pieces (0.65%). LN-02 has the highest **count**. These are different measures because the lines have different inspected quantities. The percentages are exploratory and are **not approved quality KPIs**.

## Task 5.8 — Basic Validation

- The quantity check found **no missing or negative values**, and no events where `defective_qty > inspected_qty`.
- After joining the inspection, production order and production line tables, `COUNT(*) = 15,210` and `COUNT(DISTINCT quality_event_id) = 15,210`.
- The six production-line totals reconcile to the source totals: **15,210 events**, **1,920,612 inspected pieces** and **11,165 defective pieces**.

These checks do not prove that the entire dataset is free of every possible data issue.

## Task 5.9 — Three Key Findings

1. **Quality inspection data:** We found **11,165 defective pieces** in the inspection records.
2. **Overall share:** We inspected **1,920,612 pieces**. Of these, **0.58%** were defective.
3. **Line comparison:** **LN-02** had the highest number of defective pieces (**2,055**), but **LN-04** had the highest defective-piece percentage (**0.65%**).

### Question for Future Analysis

**Can we find out why some production lines have a higher percentage of defective pieces?**

This question needs further investigation. The current data does not explain the reasons for defects.

## Method and Limitations

- Inspection events, production orders and inspected pieces are different units of analysis.
- The data comes from a fictional manufacturing simulation.
- The percentage is a descriptive share of defective pieces among inspected pieces, not an approved business KPI.
- No evidence here identifies the root causes of defects or shows that quality caused production delays.
- The SQL file was reconstructed from queries shared during mentoring; it was **not independently executed on the learner's local PostgreSQL** after the final edits.
- Task 5.5 includes a short prepared event-count query that remains to be run during final review.

## Review Status

All nine tasks were **reviewed during the mentorship** and the original learner-reported checks were discussed. Portfolio artifacts are **Ready for final review** until the edited SQL file (including the prepared Task 5.5 event count) is run locally and confirmed.
