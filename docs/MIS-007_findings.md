# MIS-007 — Inventory Movements & Material Flow: Findings

**Project:** Manufacturing Operations & BI Analytics  
**Company:** Moravia Industrial Systems (fictional)  
**Role:** Junior BI Analyst  
**Status:** Approved — 9/9 tasks reviewed  
**Dataset:** Synthetic release v1.0.0, PostgreSQL 18, `mis` schema  
**Review date:** 2026-11-26  
**Actual work time:** Not yet recorded by the learner  

## Business Goal

Explore recorded inventory movements, compare raw-material and finished-goods transactions, and calculate ledger-derived balances for individual raw materials. This is an initial investigation, not an official stock-availability analysis.

## Data and Grain

- `mis.inventory_transactions`: one row represents one signed inventory movement for a material or finished product.
- `mis.materials`: one row represents a raw material; joined on `material_id`.
- Positive `qty_delta` adds quantity to the ledger; negative `qty_delta` removes quantity.
- Quantity sums across different SKUs describe movement volumes, **not** a stock balance for one item.

## Task 7.1 — First Look

The first five rows are `opening_balance` records dated 2024-09-30. They have `material_id` populated, `product_id` empty, and positive `qty_delta`. They describe opening quantities for raw materials. A finished-goods movement uses `product_id` instead.

## Task 7.2 — Counts and Dates

| Metric | Result |
|---|---:|
| Total inventory transactions | 91,718 |
| Earliest date | 2024-09-30 |
| Latest date | 2026-10-31 |
| Distinct movement types | 5 |

## Task 7.3 — Movement Types

| Movement type | Transaction count | Total signed quantity (pcs) |
|---|---:|---:|
| `material_issue` | 50,012 | -24,861,101.250 |
| `finished_goods_shipment` | 18,930 | -1,878,156.000 |
| `finished_goods_receipt` | 15,210 | +1,909,447.000 |
| `material_receipt` | 7,476 | +27,611,874.276 |
| `opening_balance` | 90 | +51,181.205 |
| **Total transactions** | **91,718** | — |

Receipts increase recorded quantities. Issues and shipments decrease them. Opening balances are not new receipts in the analysis period.

## Task 7.4 — Materials vs. Finished Goods

| Inventory group | Transactions |
|---|---:|
| Material | 57,578 |
| Finished Goods | 34,140 |
| **Total** | **91,718** |

## Task 7.5 — Raw-Material Inflow and Outflow

| Movement type | Transactions | Signed quantity (pcs) |
|---|---:|---:|
| `opening_balance` | 90 | +51,181.205 |
| `material_receipt` | 7,476 | +27,611,874.276 |
| `material_issue` | 50,012 | -24,861,101.250 |

A material receipt adds stock to the warehouse. A material issue removes stock from the warehouse. There are more issue transactions than receipt transactions, but transaction count is not the same as quantity.

## Task 7.6 — Top Five Materials by Issued Quantity

| Material code | Material name | Issue transactions | Issued quantity (pcs) |
|---|---|---:|---:|
| MAT-0007 | Copper Parts - 007 | 1,505 | 1,118,577 |
| MAT-0006 | Copper Parts - 006 | 1,584 | 1,046,900 |
| MAT-0088 | Insulation - 088 | 1,148 | 968,642 |
| MAT-0064 | Connectors - 064 | 898 | 926,964 |
| MAT-0059 | Enclosures - 059 | 918 | 925,397 |

These are quantities issued, not monetary costs. The five material types have different transaction frequencies.

## Task 7.7 — Top Five Ledger-Derived Material Balances

| Material code | Material name | Calculated balance (pcs) |
|---|---|---:|
| MAT-0088 | Insulation - 088 | 126,361.191 |
| MAT-0006 | Copper Parts - 006 | 117,923.950 |
| MAT-0007 | Copper Parts - 007 | 104,616.803 |
| MAT-0059 | Enclosures - 059 | 101,482.871 |
| MAT-0064 | Connectors - 064 | 99,615.934 |

These balances are derived from **all available recorded movements**, including opening balances. They are **not** physically verified warehouse stock counts. We cannot decide material availability based on these totals alone.

## Task 7.8 — Basic Validation

| Check | Observed result |
|---|---|
| Transaction count vs distinct transaction IDs | 91,718 = 91,718 |
| Both item IDs empty, or both populated | 0 exceptions |
| Missing or zero `qty_delta` | 0 exceptions |
| Wrong sign for inbound movement types | 0 exceptions |
| Wrong sign for outbound movement types | 0 exceptions in the complete source CSV review |

**Verification note:** The learner reviewed the SQL query outputs. During final assembly, the mentor discovered the spelling `finished_goods_shipments` (plural) in the original outbound sign-check query. The correct value is `finished_goods_shipment` (singular). The corrected check covers all five types and was independently verified against the original synthetic CSV v1.0.0, with zero sign exceptions. The final assembled SQL script has **not** been executed end-to-end against the learner's local PostgreSQL instance. No other data quality property is claimed to have been tested.

## Task 7.9 — Three Key Findings (English B1)

1. **Most inventory transactions were related to raw materials:** 57,578 out of 91,718 transactions.
2. **Material issues were much more frequent than material receipts:** 50,012 issues compared to 7,476 receipts.
3. **MAT-0007 had the highest total issued quantity:** 1,118,577 pieces.

### Question for Future Analysis

**Do we have enough materials for our production?**

To answer this question, we would need to compare material availability with production requirements and timing. The current exploration does not prove material shortages, supplier issues, or production delays caused by stock levels.

## Interpretation and Limits

The transaction data records movements, not independent physical stock counts. Issued quantities do not equal purchase costs, a high balance does not prove adequate future supply, and none of these comparisons establishes a reason for late production or delivery. No official inventory availability KPI was defined.

## Mentoring and Reproducibility

The learner wrote the exploratory SQL, completed the initial analysis, detected and corrected a Task 7.6 business-logic problem, and wrote the initial findings and future question in English B1. The mentor reviewed SQL, corrected formatting and spelling, fixed the final outbound sign check, and polished the English while keeping the learner's conclusions. A local end-to-end execution of the final SQL file remains a sensible optional release check, not a new analysis task.
