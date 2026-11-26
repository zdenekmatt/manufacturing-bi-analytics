# MIS-001 — Business Data Exploration

**Type:** Standard Task / Data Exploration  
**Requestor:** Senior BI Analyst (simulated)  
**Priority:** Medium  
**Status:** Ready for final review  
**Estimated work time:** 60–120 minutes (flexible)

## Business Context

You have joined the BI team at Moravia Industrial Systems.

Before you start bigger reports, you need to learn about the company's data. You will look at some tables and find simple facts about customers, sales orders and production.

## Objective

Explore business data in PostgreSQL. Understand the main tables and share simple findings.

## Core Requirements

### Level 1 — Explore the Data

**Task 1.1 — First Look**  
Look at five rows from each table: `mis.customers`, `mis.sales_orders` and `mis.production_orders`. Explain what each table shows.

**Task 1.2 — Record Counts**  
Count the rows in each of the three tables.

**Task 1.3 — Main Columns**  
Find the primary key of each table. Describe at least three useful columns in each table.

### Level 2 — Basic Data Analysis

**Task 1.4 — Customer Markets**  
Count customers in each market. Find the market with the most customers.

**Task 1.5 — Sales Order History**  
Find the first and last sales order dates. Count sales orders by calendar year.

**Task 1.6 — Production Orders**  
Choose a useful status or category in `mis.production_orders`. Count production orders in each group.

### Level 3 — Connect the Data

**Task 1.7 — Orders by Customer Market**  
Connect customers and sales orders. Count sales orders for each customer market.

**Task 1.8 — Order Structure**  
Explore `mis.sales_order_lines`. Find five sales orders with the most order lines.

### Level 4 — Business Findings

**Task 1.9 — Initial Observations**  
Write three findings based on your SQL results. Add one question for a future analysis.

## Required Validation

- Count the correct type of record: customers, orders, order lines or production orders.
- Check that group totals match the table totals where possible.
- Do not give business causes without evidence.

## Optional Challenge

Find one extra interesting fact in the data and write a query for it. You can also explore how many orders have one, two or three lines. These extra tasks are not required to pass the ticket.

## Expected Deliverables

- **SQL:** `sql/investigations/MIS-001_business_exploration.sql`
- **Findings:** `docs/MIS-001_findings.md`

## Acceptance Criteria

- All core tasks are completed.
- SQL queries can be run again and are easy to read.
- Counts and table links are correct.
- Findings use real results from the synthetic dataset.
- The report is written in clear, simple English.

## Review

**Status:** Ready for final review. The final review and project status update are not yet complete.

---

*This ticket is part of a fictional BI learning project. All data is synthetic. It is not a task from a real employer.*
