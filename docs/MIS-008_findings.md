# MIS-008 — Supplier Procurement & Goods Receipts: Findings

**Project:** Manufacturing Operations & BI Analytics  
**Company:** Moravia Industrial Systems (fictional)  
**Role:** Junior BI Analyst  
**Status:** Approved — 9/9 tasks reviewed  
**Dataset:** Synthetic data v1.0.0, PostgreSQL 18  
**Review date:** 2026-11-27  
**Actual work time:** About 60 minutes (learner estimate)

## Business goal

Explore our suppliers, purchase-order lines, and goods receipts. Compare the last receipt date with the supplier-confirmed date. This is an initial analysis, not an official supplier performance KPI.

## Tables and data level

- `mis.suppliers`: one row is one supplier.
- `mis.purchase_order_lines`: one row is one purchased material line.
- `mis.goods_receipts`: one row is one goods receipt event.

One purchase-order line can have several receipt events. Joining these tables without checking the data level can count the same ordered quantity more than once.

## Task 8.1 — First look

I explored the three tables and their main columns. `confirmed_date` is the date confirmed by the supplier. `receipt_date` is the date when the goods were received. Accepted and rejected quantities are different measures.

## Task 8.2 — Counts and date coverage

| Table | Rows | Earliest date | Latest date |
| --- | ---: | --- | --- |
| Suppliers | 30 | — | — |
| Purchase-order lines | 5,247 | 2024-09-05 | 2026-09-04 |
| Goods receipts | 7,476 | 2024-10-01 | 2026-09-29 |

The number of receipt events is higher than the number of purchase-order lines because one line can have more than one receipt.

## Task 8.3 — Suppliers by country

| Country | Supplier count |
| --- | ---: |
| CZ | 6 |
| PL | 6 |
| SK | 6 |
| DE | 6 |
| AT | 6 |
| **Total** | **30** |

All five countries have six suppliers each. This is the country of the supplier, not the delivery address.

## Task 8.4 — Purchase-order lines by currency

| Currency | Order lines | Total ordered quantity (pcs) |
| --- | ---: | ---: |
| EUR | 3,960 | 19,835,899.290 |
| CZK | 1,287 | 7,775,974.986 |
| **Total** | **5,247** | **27,611,874.276** |

Most purchase-order lines are in EUR. Ordered quantity is measured in pieces, not money. The sum contains different materials, so it is not a stock balance.

## Task 8.5 — Goods receipts and partial deliveries

| Measure | Value |
| --- | ---: |
| Goods receipt events | 7,476 |
| Total accepted quantity (pcs) | 27,611,874.276 |
| Total rejected quantity (pcs) | 32,126.048 |
| Purchase-order lines with more than one receipt event | 2,229 |

Some purchase-order lines were received in several parts. Rejected quantity is separate from accepted quantity and should not be counted as usable stock.

## Task 8.6 — Top five suppliers by purchase-order line count

| Supplier | Order lines | Ordered quantity (pcs) |
| --- | ---: | ---: |
| SUP-020 | 220 | 855,450.307 |
| SUP-008 | 216 | 1,105,596.307 |
| SUP-024 | 215 | 761,943.274 |
| SUP-009 | 215 | 621,291.279 |
| SUP-026 | 214 | 499,895.841 |

SUP-020 has the most purchase-order lines (220). It does not have the highest ordered quantity in this top-five group; SUP-008 does. Number of lines and quantity are different measures. The analysis does not show total spending.

## Task 8.7 — Last receipt compared with confirmed date

| Receipt status | Purchase-order lines |
| --- | ---: |
| Late | 2,995 |
| Not Late | 2,252 |
| No Receipt | 0 |
| **Total** | **5,247** |

For this investigation, **Late** means the **last** recorded receipt is after `confirmed_date`. **Not Late** means it is on or before that date. All 5,247 order lines were included using a `LEFT JOIN`. This is not an official on-time delivery rate, and it does not tell us the cause of late receipts.

## Task 8.8 — Basic validation

| Check | Result |
| --- | --- |
| Receipt events | 7,476 |
| Distinct receipt IDs | 7,476 |
| Receipt events after joining suppliers and order lines | 7,476 |
| Accepted quantity before and after joins | 27,611,874.276 (same) |
| Rejected quantity before and after joins | 32,126.048 (same) |
| Rows in purchase-order-line-level result | 5,247 |
| Distinct purchase-order lines in that result | 5,247 |

The learner ran the checks in PostgreSQL and reported matching results. The final formatted SQL file has not been run end-to-end after compilation.

## Task 8.9 — Initial findings (B1 English)

**1. Suppliers**  
The data shows that we have 30 suppliers.

**2. Supplier countries**  
Our suppliers are from five countries. Each country has six suppliers.

**3. Purchase-order currency**  
Most purchase-order lines are in EUR: 3,960 out of 5,247 lines.

### Question for future analysis

Why were the last receipts for 2,995 purchase-order lines recorded after the supplier-confirmed dates?

## Limits and next steps

- A late last receipt does not prove a material shortage or a production delay.
- A purchase-order line can have more than one receipt, so counts must use the correct data level.
- `ordered_qty`, `accepted_qty`, and `rejected_qty` must not be mixed without a clear question.
- Values and conclusions are from a fictional, synthetic dataset.

## Learning and AI support

I wrote and tested most SQL queries myself. I used ChatGPT as a mentor to review my work, explain mistakes, and improve this report in B1 English. The final SQL compilation includes minor formatting and technical fixes by the mentor. My work on this ticket took about one hour.
