# Data engineering QA — version 1.0.0

**Status:** PASS — synthetic CSV data and structural SQL/CSV import contract have been validated locally.

**Verification environment:** Python 3.13.5, standard library; local file system. **No PostgreSQL server or `psql` client available** in the validation environment. SQL execution, client import and Power BI connectivity must be confirmed on the learner’s own machine.

## Baseline data volume

| Table / export | Rows |
|---|---:|
| `customers` | 80 |
| `products` | 50 |
| `production_lines` | 6 |
| `sales_orders` | 8,600 |
| `sales_order_lines` | 14,077 |
| `shipments` | 18,495 |
| `shipment_lines` | 18,930 |
| `production_orders` | 15,287 |
| `production_operations` | 45,630 |
| `downtime_events` | 10,397 |
| `quality_events` | 15,210 |
| `materials` | 90 |
| `suppliers` | 30 |
| `bom_components` | 164 |
| `purchase_order_lines` | 5,247 |
| `goods_receipts` | 7,476 |
| `inventory_transactions` | 91,718 |
| `material_cost_history` | 720 |
| `product_standard_cost_history` | 400 |
| `manufacturing_cost_rates` | 144 |
| `exchange_rates` | 1,522 |
| `raw_goods_receipts_export` | 7,573 |
| **TOTAL** | **261,846** |

## Executed checks

| Check | Result |
|---|---|
| sha256 manifest | PASS |
| static postgres import contract | PASS |
| primary keys | PASS |
| foreign keys | PASS |
| quantity allocation | PASS |
| business event chronology | PASS |
| sales shipping reconciliation | PASS |
| procurement receipt reconciliation | PASS |
| production quality reconciliation | PASS |
| inventory movements | PASS |
| nonnegative end of day stock | PASS |
| effective dated costs | PASS |
| foreign exchange coverage | PASS |
| raw export reconciliation | PASS |

## Controlled anomalies in the untrusted WMS export

The raw goods-receipts export intentionally contains repeated business receipt references, optional blanks, mixed date formats and comma/dot decimal conventions. These exceptions are kept in `raw_import`; the canonical receipt and warehouse movement records remain reconciled. Counts and row identities are not used as advance business-ticket hints.

## Repeatability and limitations

- The dataset was regenerated twice from the same fixed seed; its file SHA-256 manifest was identical across runs.
- All expected core foreign keys, line-level quantity allocations, shipment-to-order matches, receipt quantities, quality quantities, effective cost coverage, FX availability and day-end stock balances were checked.
- SQL table/column order was statically compared to the generated CSV headers, and each `psql` copy command was matched to an existing manifest path.
- **Not verified here:** real PostgreSQL DDL execution, physical CSV loading by `psql`, server-side constraint enforcement, local Windows performance, Power BI import, final KPI correctness, or a business root-cause hypothesis.
- The upcoming local SQL check file is `sql/quality/01_post_import_checks.sql`.
- Each business KPI and analytical view remains to be specified and independently reviewed.
