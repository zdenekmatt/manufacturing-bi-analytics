# MIS-001 — Business Data Exploration: Findings

**Project:** Manufacturing Operations & BI Analytics  
**Company:** Moravia Industrial Systems (fictional)  
**Ticket:** MIS-001  
**Status:** Approved
**Source:** PostgreSQL, synthetic dataset v1.0.0

## Goal

The goal was to learn about our customers, sales orders and production orders. I used simple SQL queries to explore the tables and check the data.

## Task 1.1 — First Look

I explored three tables:

- **`mis.customers`** — one row is one customer. It shows the customer name and market.
- **`mis.sales_orders`** — one row is one sales order. It shows the customer, order date and currency.
- **`mis.production_orders`** — one row is one production order. It shows production dates, quantities and status.

These tables help me understand how customer orders and production work.

## Task 1.2 — Record Counts

| Table | Rows |
|---|---:|
| `mis.customers` | 80 |
| `mis.sales_orders` | 8,600 |
| `mis.production_orders` | 15,287 |

These counts match the source data.

## Task 1.3 — Main Columns

| Table | Primary key | Useful columns |
|---|---|---|
| `customers` | `customer_id` | `customer_code`, `customer_name`, `market` |
| `sales_orders` | `sales_order_id` | `customer_id`, `order_date`, `order_currency` |
| `production_orders` | `production_order_id` | `status`, planned and actual dates, produced and good quantities |

The market helps us group customers. Order dates help us study changes over time. Production dates and quantities help us look at production work.

**Extra check:** I found 2,731 production orders where `produced_qty` is higher than `good_qty`. This is the number of production orders, not the number of bad units. It is not an official defect rate.

## Task 1.4 — Customers by Market

| Market | Customers |
|---|---:|
| AT | 17 |
| HU | 16 |
| CZ | 15 |
| DE | 12 |
| SK | 11 |
| PL | 9 |
| **Total** | **80** |

Austria (AT) has the highest number of customers: **17**. Poland (PL) has the lowest number: **9**.

The `market` field shows a customer market. It does not prove the delivery country.

## Task 1.5 — Sales Order History

- **First order date:** 2024-10-01
- **Last order date:** 2026-09-18

| Year | Sales orders |
|---|---:|
| 2024 | 1,077 |
| 2025 | 4,301 |
| 2026 | 3,222 |
| **Total** | **8,600** |

Only **2025** is a full calendar year in this data. We should not compare these yearly totals as if all three years were complete. A monthly analysis could help us understand the trend.

## Task 1.6 — Production Order Status

| Status | Production orders |
|---|---:|
| Completed | 15,210 |
| Open | 77 |
| **Total** | **15,287** |

There are **77 open production orders**. We do not yet know why they are open.

## Task 1.7 — Sales Orders by Customer Market

| Market | Sales orders |
|---|---:|
| AT | 1,867 |
| HU | 1,698 |
| CZ | 1,657 |
| DE | 1,259 |
| SK | 1,138 |
| PL | 981 |
| **Total** | **8,600** |

Austria (AT) also has the highest number of sales orders: **1,867**.

Here I counted **sales orders**, not customers. One customer can place many orders.

## Task 1.8 — Order Structure

| Order lines in one order | Number of orders |
|---|---:|
| 1 | 4,073 |
| 2 | 3,577 |
| 3 | 950 |
| **Total orders** | **8,600** |

The highest number of lines in one sales order is **3**. Most orders have two or three lines.

**Check:** 4,073 × 1 + 3,577 × 2 + 950 × 3 = **14,077 order lines**. This matches the `sales_order_lines` table.

**Important:** Order lines are **not** shipments. One order line may be sent in more than one shipment.

## Task 1.9 — Initial Business Observations

### Three key findings

1. We have **80 customers in six markets**. Austria has the most customers and sales orders.
2. We have **8,600 sales orders** between October 2024 and September 2026. Only 2025 is a full year, so we need care when comparing years.
3. We have **15,287 production orders**, and **77 are still open**. We can study these open orders later.

### Extra finding — Order currencies

Sales orders use **EUR, CZK and USD**. I also checked the number of orders by market and currency. Currency is important when we compare sales values, but an order currency does not tell us the delivery country.

### Question for future analysis

**Why are 77 production orders still open?** I would like to look at their planned dates and production results. We need more data before we can explain the reason.

## Basic Checks and Limits

- The market counts add up to **80 customers**.
- The yearly and market order counts both add up to **8,600 sales orders**.
- The production status counts add up to **15,287 production orders**.
- The order line check gives **14,077 lines**.
- These are first findings from the synthetic data. They do not prove why a business problem happens.

## SQL File

`sql/investigations/MIS-001_business_exploration.sql`

---

*This is a learning project with a fictional company and synthetic data. It is not real company work.*
