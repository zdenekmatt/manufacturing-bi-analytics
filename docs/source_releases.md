# Simulated source releases

The folder names simulate the cadence of independent company exports. The files are all synthetic and all delivered in the starter ZIP **for technical onboarding and integrity checks**. Business assignments will specify which source/release to inspect; the existence of files does not imply they should all be loaded into a single Power BI fact table.

| Release | Simulated department(s) | Files |
|---|---|---|
| `01_core` | ERP sales + logistics | `production_lines`, `customers`, `products`, `sales_orders`, `sales_order_lines`, `shipments`, `shipment_lines` |
| `02_operations` | MES + QMS | `production_orders`, `production_operations`, `downtime_events`, `quality_events` |
| `03_supply_chain_finance` | Procurement + WMS + finance | `suppliers`, `materials`, `bom_components`, `purchase_order_lines`, `goods_receipts`, `inventory_transactions`, `material_cost_history`, `product_standard_cost_history`, `manufacturing_cost_rates`, `exchange_rates`, `raw_goods_receipts_export` |

The `raw_goods_receipts_export` is an **additional raw representation** of the events in `goods_receipts`, not additional received goods. Count it as a separate raw-import dataset, but **never** add its quantities to the canonical receipts.

**Event dates:** historic sales orders cover 2024-10-01–2026-09-30; supplier POs can predate the first sale month; production, receipts and shipments can continue into 2026-10-31. The original opening stock date is 2024-09-30.

## Key business-grain distinctions

1. Customer order header (`sales_orders`) is not the same grain as customer order line (`sales_order_lines`).
2. One sales-order line may split into two `production_orders`; one production order produces three `production_operations` when completed.
3. One sales-order line may be fulfilled through multiple `shipment_lines` on separate dates. Each `shipments` header belongs to one sales order, but an order may have many shipments.
4. One `purchase_order_lines` record may have multiple `goods_receipts`.
5. `inventory_transactions` is a signed stock-movement ledger and should not be aggregated as "inventory on hand" without a date boundary and starting balance.
6. Price/rate histories are effective dated, not fact tables to be joined by the business ID alone.
