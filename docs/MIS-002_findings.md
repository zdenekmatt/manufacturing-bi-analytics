# MIS-002 — Production Data Exploration: Findings

**Project:** Manufacturing Operations & BI Analytics  
**Ticket:** MIS-002  
**Status:** Approved
**Data:** Synthetic manufacturing data (version 1.0.0)

## Goal

I explored production lines, production orders and production operations. I used SQL to learn how these tables work together.

## Task 2.1 — First Look

- **`production_lines`:** One row is one production line with a code and a name.
- **`production_orders`:** One row is one production order. It has dates, quantities, a line ID and a status.
- **`production_operations`:** One row is one operation. It has an operation type, a date, labor hours and machine hours.

## Task 2.2 — Record Counts

| Table | Records |
|---|---:|
| `production_lines` | 6 |
| `production_orders` | 15,287 |
| `production_operations` | 45,630 |

These tables have different types of records. One production order can have several operations.

## Task 2.3 — Operation Types

| Operation type | Records |
|---|---:|
| Preparation | 15,210 |
| Assembly | 15,210 |
| Testing | 15,210 |
| **Total** | **45,630** |

Each operation type appears 15,210 times.

## Task 2.4 — Production Dates

| Date | First | Last |
|---|---|---|
| Planned start date | 2024-10-03 | 2026-09-25 |
| Actual completion date (completed orders) | 2024-10-10 | 2026-10-27 |

The actual completion dates only include completed production orders.

## Task 2.5 — Production Order Status

| Status | Production orders |
|---|---:|
| Completed | 15,210 |
| Open | 77 |
| **Total** | **15,287** |

Most production orders are completed.

## Task 2.6 — Orders by Production Line

| Production line | Production orders |
|---|---:|
| LN-01 | 2,832 |
| LN-02 | 2,711 |
| LN-05 | 2,553 |
| LN-03 | 2,456 |
| LN-06 | 2,384 |
| LN-04 | 2,351 |
| **Total** | **15,287** |

Line LN-01 has the highest number of production orders. This count is not the number of products made.

## Task 2.7 — Status by Production Line

| Line | Completed | Open | Total |
|---|---:|---:|---:|
| LN-01 | 2,813 | 19 | 2,832 |
| LN-02 | 2,695 | 16 | 2,711 |
| LN-03 | 2,447 | 9 | 2,456 |
| LN-04 | 2,345 | 6 | 2,351 |
| LN-05 | 2,538 | 15 | 2,553 |
| LN-06 | 2,372 | 12 | 2,384 |
| **Total** | **15,210** | **77** | **15,287** |

LN-01 has the most open orders (19). LN-04 has the fewest (6).

## Task 2.8 — Operations per Production Order

Each production order **listed in the `production_operations` table** has three operation records. The extra SQL check found no order with a different number of operation records.

This check does not include production orders with no operation records.

## Task 2.9 — Completed After the Planned Date

Some production orders finished after the planned end date. The largest delay found was **10 calendar days**.

I also checked how often each delay appears:

| Delay in calendar days | Completed orders |
|---|---:|
| 1 | 2,016 |
| 2 | 370 |
| 3 | 394 |
| 4 | 360 |
| 5 | 362 |
| 6 | 397 |
| 7 | 391 |
| 8 | 395 |
| 9 | 399 |
| 10 | 395 |
| **Total** | **5,479** |

These are late production orders, not late customer deliveries. We do not know the reason for the delay yet.

## Task 2.10 — Initial Findings

### Three key findings

1. We have **6 production lines** and **15,287 production orders**. Line LN-01 has the highest number of orders (2,832).
2. We have **15,210 completed orders** and **77 open orders**. LN-01 has the most open orders (19).
3. Some completed orders were late. I found **5,479 completed orders** after their planned end date. The longest delay was **10 days**.

### Question for future analysis

**Why are some production orders completed late?** I would like to check machine hours and operation times in a future analysis.

## Checks and limits

- The line counts add up to **15,287 production orders**.
- The status counts add up to **15,287 production orders**.
- The operation type counts add up to **45,630 operation records**.
- The delay analysis includes **completed** production orders only.
- This work describes the data. It does **not** prove why production orders are late.

**SQL file:** `sql/investigations/MIS-002_production_exploration.sql`

*This is a learning project with synthetic data. It is not work for a real company.*
