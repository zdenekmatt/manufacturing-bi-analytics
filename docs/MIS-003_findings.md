# MIS-003 — Production Hours & Workload Exploration: Findings

**Project:** Manufacturing Operations & BI Analytics  
**Ticket:** MIS-003  
**Status:** Ready for final review (edited SQL not yet re-run locally)  
**Data:** Synthetic manufacturing data, version 1.0.0  
**Database:** PostgreSQL, schema `mis`

## Goal

I explored recorded labor hours and machine hours in production. I used SQL to compare operation types, production orders and production lines. I also checked the results.

## Task 3.1 — First Look at Working Hours

One row in `mis.production_operations` represents one operation for one production order.

- `operation_id` identifies an operation record.
- `production_order_id` links the operation to a production order.
- `operation_type` tells us the type: Preparation, Assembly or Testing.
- `labor_hours` contains recorded labor hours for an operation.
- `machine_hours` contains recorded machine hours for an operation.

These are different measures. They are not necessarily the total elapsed time of an operation.

## Task 3.2 — Total Recorded Hours

| Measure | Total recorded hours |
|---|---:|
| Labor hours | 126,143.213 |
| Machine hours | 111,723.607 |

The total recorded labor hours are higher than the total machine hours. This does not tell us why the hours are different.

## Task 3.3 — Hours by Operation Type

| Operation type | Operation records | Total labor hours | Average labor hours per operation | Total machine hours |
|---|---:|---:|---:|---:|
| Testing | 15,210 | 42,076.58 | 2.77 | 37,204.98 |
| Assembly | 15,210 | 42,052.75 | 2.76 | 37,208.76 |
| Preparation | 15,210 | 42,013.88 | 2.76 | 37,309.87 |
| **Total records** | **45,630** | | | |

Testing has the highest total labor hours, but the values are very close. All three types have the same number of operation records.

*Hours in this table are rounded to two decimals. The exact totals are in Task 3.2.*

## Task 3.4 — Hours per Production Order

Five production orders with the highest recorded labor hours:

| Production order ID | Total labor hours | Total machine hours |
|---|---:|---:|
| 11133 | 40.45 | 29.08 |
| 11201 | 38.68 | 28.39 |
| 6146 | 38.46 | 28.19 |
| 5496 | 38.24 | 24.96 |
| 14021 | 37.65 | 19.28 |

Production order **11133** has the highest recorded labor hours: **40.45 hours**. This is the sum of its operations, not necessarily its elapsed production time.

## Task 3.5 — Workload by Production Line

| Production line | Operation records | Total labor hours | Total machine hours |
|---|---:|---:|---:|
| LN-01 | 8,439 | 23,445.39 | 20,665.67 |
| LN-02 | 8,085 | 22,258.57 | 19,725.87 |
| LN-05 | 7,614 | 20,992.31 | 18,653.62 |
| LN-03 | 7,341 | 20,494.96 | 18,212.41 |
| LN-06 | 7,116 | 19,998.21 | 17,680.33 |
| LN-04 | 7,035 | 18,953.78 | 16,785.70 |
| **Total operation records** | **45,630** | | |

LN-01 has the highest total recorded labor hours. This is a measure of recorded workload, not proof that LN-01 is less efficient.

*The line-level hours are rounded to two decimals. Adding rounded numbers may give a small difference from the exact total.*

## Task 3.6 — Average Labor Hours per Production Order by Line

First, I summed labor hours for each production order. Next, I calculated the average of these totals for each production line using a CTE.

| Production line | Average labor hours per order |
|---|---:|
| LN-06 | 8.43 |
| LN-03 | 8.38 |
| LN-01 | 8.33 |
| LN-05 | 8.27 |
| LN-02 | 8.26 |
| LN-04 | 8.08 |

LN-06 has the highest average labor hours per production order **with recorded operations**. This is different from the highest *total* labor hours (LN-01).

## Task 3.7 — Orders with More Than 15 Labor Hours

| Check | Production orders |
|---|---:|
| More than 15 recorded labor hours | 2,164 |

This is about **14.2% of the 15,210 production orders represented in the operations table**.

The 15-hour threshold was used for exploration. It is not an official company target.

## Task 3.8 — Basic Validation

- The SQL checks returned **no missing or negative values** in `labor_hours` and `machine_hours`.
- The total hours calculated directly from `production_operations` matched the totals after joining `production_operations`, `production_orders` and `production_lines`.
- **Labor hours:** 126,143.213 in both queries.
- **Machine hours:** 111,723.607 in both queries.
- Tasks 3.3 and 3.5 also show the breakdown by operation type and production line. For a correct total comparison, I used the values **before rounding**.

These checks support the results for this exploration. They do not prove that all business records are complete or that the hours are measured correctly in real life.

## Task 3.9 — Initial Findings

### Three key findings

**1. Labor hours and machine hours**  
We recorded **126,143.213 labor hours** and **111,723.607 machine hours**. Labor hours are higher. I would like to understand why.

**2. Operation types**  
Preparation, Assembly and Testing have very similar total labor hours. Each type has about **42,000 labor hours** and **15,210 operation records**.

**3. Different hours for some orders**  
Some production orders have a large difference between labor hours and machine hours. For example, order **14021** has **37.65 labor hours** and **19.28 machine hours**.

### Question for future analysis

**Why do some production orders have a larger difference between labor hours and machine hours?**

I would like to compare the operation types and recorded hours in more detail.

## Checks and Limits

- An operation record is different from a production order.
- The three operation types have **45,630 records** in total.
- The six production lines have **45,630 joined operation records** in total.
- Average hours in Task 3.6 are **per production order with recorded operations**, not per operation.
- Labor hours and machine hours are separate measures and may overlap in time.
- The data alone does **not** prove employee productivity, machine efficiency, costs or reasons for delays.
- The edited SQL file should be run once more locally before the final approval of the saved portfolio files.

**SQL file:** `sql/investigations/MIS-003_production_hours_exploration.sql`

*This is a learning project with synthetic data. It is not work for a real company.*
