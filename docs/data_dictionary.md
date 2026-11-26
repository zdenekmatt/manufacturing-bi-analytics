# Data dictionary — synthetic Manufacturing BI dataset v1.0.0

This dictionary describes **physical source tables and raw export fields**, not final KPI calculations. All identifiers and business names are fictional.

**Grain** is the individual record represented by a single row. Historical cost and FX records have effective-date semantics; join by both business identifier and date, not identifier alone.

## Source table overview

| PostgreSQL table | Simulated source | Row grain | Primary key |
|---|---|---|---|
| `mis.production_lines` | Production master | One fictional manufacturing line | `line_id` |
| `mis.customers` | ERP customer master | One anonymized fictional customer account | `customer_id` |
| `mis.products` | ERP product master | One finished-goods SKU | `product_id` |
| `mis.materials` | ERP material master | One raw-material SKU | `material_id` |
| `mis.suppliers` | Procurement supplier master | One fictional supplier | `supplier_id` |
| `mis.bom_components` | Engineering BOM | One material component required by a product at an effective date | `bom_component_id` |
| `mis.sales_orders` | ERP sales | One customer sales-order header | `sales_order_id` |
| `mis.sales_order_lines` | ERP sales | One SKU line on a customer sales order | `sales_order_line_id` |
| `mis.production_orders` | MES | One manufacturing order allocated to exactly one sales-order line | `production_order_id` |
| `mis.production_operations` | MES | One sequenced operation of a manufacturing order | `operation_id` |
| `mis.downtime_events` | MES | One reported production downtime event for an operation | `downtime_id` |
| `mis.quality_events` | QMS | One finished-order quality inspection event | `quality_event_id` |
| `mis.purchase_order_lines` | Procurement ERP | One supplier-material purchase-order line | `purchase_order_line_id` |
| `mis.goods_receipts` | WMS | One accepted goods-receipt event, potentially partial against a PO line | `goods_receipt_id` |
| `mis.shipments` | Logistics | One dispatch header for exactly one customer sales order on a given date | `shipment_id` |
| `mis.shipment_lines` | Logistics | One dispatched quantity of one sales-order line in a shipment | `shipment_line_id` |
| `mis.inventory_transactions` | WMS | One signed goods movement of a material or finished SKU | `inventory_txn_id` |
| `mis.material_cost_history` | Finance | One material standard-cost version for a non-overlapping validity interval | `material_cost_id` |
| `mis.product_standard_cost_history` | Finance | One finished-product standard-cost version for an effective interval | `product_cost_id` |
| `mis.manufacturing_cost_rates` | Controlling | One cost-rate set for a production line and effective month | `rate_id` |
| `mis.exchange_rates` | Finance | One foreign currency exchange rate per calendar date | `fx_rate_id` |
| `raw_import.raw_goods_receipts_export` | Raw WMS export | One incoming export row; source receipt reference may repeat | `raw_row_id` |

## Column-level definitions

All `*_id` fields are local synthetic integer surrogate keys, never real source-system identifiers. Date fields are calendar dates. Mandatory referential relationships are defined in `sql/setup/00_create_schema.sql`.

### `mis.production_lines`

**Grain:** One fictional manufacturing line.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `line_id` | `integer` | Assigned manufacturing line; same line ID refers to production_lines. |
| `line_code` | `text` | Line identifier shown to business users. |
| `line_name` | `text` | Synthetic work cell label. |

### `mis.customers`

**Grain:** One anonymized fictional customer account.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `customer_id` | `integer` | Fictional customer account identifier. |
| `customer_code` | `text` | Fictional customer code. |
| `customer_name` | `text` | Fictional account name; contains no real personally identifiable details. |
| `market` | `char(2)` | Two-letter sales market code. |

### `mis.products`

**Grain:** One finished-goods SKU.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `product_id` | `integer` | Finished-goods SKU identifier. |
| `sku` | `text` | Finished-goods stock keeping unit code. |
| `product_family` | `text` | Classification of finished product. |
| `line_id` | `integer` | Assigned manufacturing line; same line ID refers to production_lines. FK to `mis.production_lines.line_id`. |
| `unit_of_measure` | `text` | Finished-goods sales quantity unit: pieces. |

### `mis.materials`

**Grain:** One raw-material SKU.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `material_id` | `integer` | Raw-material SKU identifier (not a finished product). |
| `material_code` | `text` | Raw-material stock-keeping code. |
| `material_name` | `text` | Synthetic engineering material label. |
| `base_unit` | `text` | Material quantity unit: pieces. |

### `mis.suppliers`

**Grain:** One fictional supplier.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `supplier_id` | `integer` | Fictional supplier identifier. |
| `supplier_code` | `text` | Fictional supplier reference. |
| `supplier_name` | `text` | Fictional supplier label. |
| `supplier_country` | `char(2)` | Two-character supplier-country code. |

### `mis.bom_components`

**Grain:** One material component required by a product at an effective date.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `bom_component_id` | `integer` | Foreign or surrogate identifier for bom component. |
| `product_id` | `integer` | Finished-goods SKU identifier. FK to `mis.products.product_id`. |
| `material_id` | `integer` | Raw-material SKU identifier (not a finished product). FK to `mis.materials.material_id`. |
| `quantity_per_unit` | `numeric(14,3)` | Material pieces consumed per one good finished piece. |
| `effective_from` | `date` | Start date of validity, inclusive. |
| `effective_to` | `date` | End date of validity, exclusive; NULL means open-ended. Nullable. |

### `mis.sales_orders`

**Grain:** One customer sales-order header.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `sales_order_id` | `integer` | Customer order header identifier; a header may have several lines. |
| `customer_id` | `integer` | Fictional customer account identifier. FK to `mis.customers.customer_id`. |
| `order_date` | `date` | Calendar date when the purchase or customer order was registered (table-dependent). |
| `order_currency` | `char(3)` | Customer-order transaction currency; applies to sales_order_lines.unit_price. |

### `mis.sales_order_lines`

**Grain:** One SKU line on a customer sales order.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `sales_order_line_id` | `integer` | Customer order line identifier; may map to several production orders/dispatches. |
| `sales_order_id` | `integer` | Customer order header identifier; a header may have several lines. FK to `mis.sales_orders.sales_order_id`. |
| `product_id` | `integer` | Finished-goods SKU identifier. FK to `mis.products.product_id`. |
| `ordered_qty` | `integer` | Ordered unit quantity; integer pcs for customer lines, decimal pcs for material procurement. |
| `unit_price` | `numeric(14,2)` | Unit value in the header/order currency, NOT necessarily CZK. |
| `requested_date` | `date` | Customer-requested fulfillment date, not the committed date. |
| `promised_date` | `date` | Committed fulfillment date for a sales order line. |
| `line_status` | `text` | Fulfilled / Partially Shipped / Open as at 2026-10-31; derived snapshot field. |

### `mis.production_orders`

**Grain:** One manufacturing order allocated to exactly one sales-order line.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `production_order_id` | `integer` | Manufacturing order identifier; one order line may split over two manufacturing orders. |
| `sales_order_line_id` | `integer` | Customer order line identifier; may map to several production orders/dispatches. FK to `mis.sales_order_lines.sales_order_line_id`. |
| `line_id` | `integer` | Assigned manufacturing line; same line ID refers to production_lines. FK to `mis.production_lines.line_id`. |
| `planned_qty` | `integer` | Number of finished pieces allocated to a manufacturing order. |
| `planned_start_date` | `date` | Planned start of manufacturing order. |
| `planned_end_date` | `date` | Planned manufacturing completion. |
| `actual_start_date` | `date` | Observed start date; NULL if not yet started as of snapshot. Nullable. |
| `actual_completion_date` | `date` | Observed completion date, NULL if work remains open at the snapshot. Nullable. |
| `produced_qty` | `integer` | Gross number of manufactured units (good plus rejected). |
| `good_qty` | `integer` | Good pieces produced and posted to finished stock; zero for unfinished work. |
| `status` | `text` | Completed or Open manufacturing order as at snapshot. |

### `mis.production_operations`

**Grain:** One sequenced operation of a manufacturing order.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `operation_id` | `integer` | Manufacturing operation identifier. |
| `production_order_id` | `integer` | Manufacturing order identifier; one order line may split over two manufacturing orders. FK to `mis.production_orders.production_order_id`. |
| `operation_seq` | `smallint` | Order of operations within a manufacturing order, starts at one. |
| `operation_type` | `text` | Manufacturing step label (Preparation, Assembly, Testing). |
| `operation_date` | `date` | Calendar date on which this manufacturing operation was recorded. |
| `labor_hours` | `numeric(14,3)` | Recorded human work hours for this operation. |
| `machine_hours` | `numeric(14,3)` | Recorded machine operating hours for this operation. |

### `mis.downtime_events`

**Grain:** One reported production downtime event for an operation.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `downtime_id` | `integer` | Reported downtime event identifier. |
| `operation_id` | `integer` | Manufacturing operation identifier. FK to `mis.production_operations.operation_id`. |
| `event_date` | `date` | Date of downtime event, aligned to its operation. |
| `duration_minutes` | `integer` | Duration of one downtime event in whole minutes. |
| `downtime_category` | `text` | Reported reason category; descriptive, not proof of root cause. |
| `is_planned` | `boolean` | Whether the downtime was scheduled (true/false). |

### `mis.quality_events`

**Grain:** One finished-order quality inspection event.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `quality_event_id` | `integer` | Finished production inspection event identifier. |
| `production_order_id` | `integer` | Manufacturing order identifier; one order line may split over two manufacturing orders. FK to `mis.production_orders.production_order_id`. |
| `inspection_date` | `date` | Quality inspection date. |
| `inspected_qty` | `integer` | Number of inspected finished pieces. |
| `defective_qty` | `integer` | Rejected pieces detected at this inspection; a subset of inspected units. |
| `inspection_result` | `text` | Quality inspection outcome label. |

### `mis.purchase_order_lines`

**Grain:** One supplier-material purchase-order line.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `purchase_order_line_id` | `integer` | Procurement PO line identifier; partial goods receipts may follow. |
| `supplier_id` | `integer` | Fictional supplier identifier. FK to `mis.suppliers.supplier_id`. |
| `material_id` | `integer` | Raw-material SKU identifier (not a finished product). FK to `mis.materials.material_id`. |
| `order_date` | `date` | Calendar date when the purchase or customer order was registered (table-dependent). |
| `confirmed_date` | `date` | Date promised/confirmed by supplier, not actual receipt date. |
| `ordered_qty` | `numeric(14,3)` | Ordered unit quantity; integer pcs for customer lines, decimal pcs for material procurement. |
| `unit_price` | `numeric(14,2)` | Unit value in the header/order currency, NOT necessarily CZK. |
| `currency` | `char(3)` | Transaction/rate currency, e.g. CZK, EUR or USD according to table. |

### `mis.goods_receipts`

**Grain:** One accepted goods-receipt event, potentially partial against a PO line.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `goods_receipt_id` | `integer` | Canonical unique receipt event identifier. |
| `purchase_order_line_id` | `integer` | Procurement PO line identifier; partial goods receipts may follow. FK to `mis.purchase_order_lines.purchase_order_line_id`. |
| `receipt_date` | `date` | Actual goods receipt event date. |
| `accepted_qty` | `numeric(14,3)` | Usable quantity accepted into stock; material pieces to three decimals. |
| `rejected_qty` | `numeric(14,3)` | Additional rejected quantity reported at receipt, not accepted into stock. |
| `receipt_reference` | `text` | Business receipt number; unique in canonical receipts, potentially repeated in raw. |

### `mis.shipments`

**Grain:** One dispatch header for exactly one customer sales order on a given date.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `shipment_id` | `integer` | Customer order shipment header identifier. |
| `sales_order_id` | `integer` | Customer order header identifier; a header may have several lines. FK to `mis.sales_orders.sales_order_id`. |
| `ship_date` | `date` | Actual dispatch date; not proof of customer arrival. |
| `carrier_code` | `text` | Simulated transport operator code. |

### `mis.shipment_lines`

**Grain:** One dispatched quantity of one sales-order line in a shipment.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `shipment_line_id` | `integer` | One shipping event line identifier. |
| `shipment_id` | `integer` | Customer order shipment header identifier. FK to `mis.shipments.shipment_id`. |
| `sales_order_line_id` | `integer` | Customer order line identifier; may map to several production orders/dispatches. FK to `mis.sales_order_lines.sales_order_line_id`. |
| `shipped_qty` | `integer` | Dispatched finished pieces in this single shipment line. |

### `mis.inventory_transactions`

**Grain:** One signed goods movement of a material or finished SKU.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `inventory_txn_id` | `integer` | Signed stock movement event identifier. |
| `txn_date` | `date` | Recorded calendar date of txn date. |
| `material_id` | `integer` | Raw-material SKU identifier (not a finished product). FK to `mis.materials.material_id`. Nullable. |
| `product_id` | `integer` | Finished-goods SKU identifier. FK to `mis.products.product_id`. Nullable. |
| `movement_type` | `text` | Stock movement kind (opening, receipt, issue, finished production, shipment). |
| `qty_delta` | `numeric(14,3)` | Signed movement quantity in pieces, positive = in, negative = out. |
| `goods_receipt_id` | `integer` | Canonical unique receipt event identifier. FK to `mis.goods_receipts.goods_receipt_id`. Nullable. |
| `production_order_id` | `integer` | Manufacturing order identifier; one order line may split over two manufacturing orders. FK to `mis.production_orders.production_order_id`. Nullable. |
| `shipment_line_id` | `integer` | One shipping event line identifier. FK to `mis.shipment_lines.shipment_line_id`. Nullable. |
| `unit_cost_czk` | `numeric(14,2)` | Illustrative inventory posting unit value in CZK; not a complete actual-cost accounting model. Nullable. |

### `mis.material_cost_history`

**Grain:** One material standard-cost version for a non-overlapping validity interval.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `material_cost_id` | `integer` | Foreign or surrogate identifier for material cost. |
| `material_id` | `integer` | Raw-material SKU identifier (not a finished product). FK to `mis.materials.material_id`. |
| `effective_from` | `date` | Start date of validity, inclusive. |
| `effective_to` | `date` | End date of validity, exclusive; NULL means open-ended. Nullable. |
| `standard_unit_cost_czk` | `numeric(14,2)` | Historic reference standard unit cost in CZK, not actual invoice cost. |

### `mis.product_standard_cost_history`

**Grain:** One finished-product standard-cost version for an effective interval.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `product_cost_id` | `integer` | Foreign or surrogate identifier for product cost. |
| `product_id` | `integer` | Finished-goods SKU identifier. FK to `mis.products.product_id`. |
| `effective_from` | `date` | Start date of validity, inclusive. |
| `effective_to` | `date` | End date of validity, exclusive; NULL means open-ended. Nullable. |
| `standard_unit_cost_czk` | `numeric(14,2)` | Historic reference standard unit cost in CZK, not actual invoice cost. |

### `mis.manufacturing_cost_rates`

**Grain:** One cost-rate set for a production line and effective month.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `rate_id` | `integer` | Foreign or surrogate identifier for rate. |
| `line_id` | `integer` | Assigned manufacturing line; same line ID refers to production_lines. FK to `mis.production_lines.line_id`. |
| `effective_from` | `date` | Start date of validity, inclusive. |
| `effective_to` | `date` | End date of validity, exclusive; NULL means open-ended. Nullable. |
| `labor_czk_per_hour` | `numeric(14,2)` | Standard hourly human labor rate, CZK per hour. |
| `machine_czk_per_hour` | `numeric(14,2)` | Standard hourly machine rate, CZK per hour. |
| `overhead_czk_per_hour` | `numeric(14,2)` | Standard hourly overhead reference rate, CZK per hour. |

### `mis.exchange_rates`

**Grain:** One foreign currency exchange rate per calendar date.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `fx_rate_id` | `integer` | Foreign or surrogate identifier for fx rate. |
| `rate_date` | `date` | Calendar date of published synthetic exchange rate. |
| `currency` | `char(3)` | Transaction/rate currency, e.g. CZK, EUR or USD according to table. |
| `czk_per_unit` | `numeric(12,4)` | CZK received for one unit of the specified foreign currency. |

### `raw_import.raw_goods_receipts_export`

**Grain:** One incoming export row; source receipt reference may repeat.

| Column | PostgreSQL type | Definition |
|---|---|---|
| `raw_row_id` | `integer` | Raw export ingestion row key, NOT a unique business receipt. |
| `receipt_reference` | `text` | Business receipt number; unique in canonical receipts, potentially repeated in raw. Nullable. |
| `po_line_reference` | `text` | Raw export purchase-order line reference in POL-xxxxxxx notation. Nullable. |
| `received_date_text` | `text` | Unparsed raw text for goods receipt date; source formats intentionally vary. Nullable. |
| `accepted_qty_text` | `text` | Unparsed raw accepted quantity; decimal separator may differ. Nullable. |
| `supplier_note` | `text` | Optional descriptive source note, potentially missing. Nullable. |
| `import_batch` | `text` | Simulated export batch label. Nullable. |

## Important cross-table logic

- The raw receipt export is a separate untrusted representation of canonical receipts and must not be unioned into accepted-stock flow.
- `inventory_transactions.material_id` and `.product_id` are mutually exclusive; source-event foreign keys identify the type of movement.
- The `raw_import` schema intentionally avoids business-key uniqueness constraints; other tables use PK/FK constraints.
- Open manufacturing orders have `actual_completion_date = NULL` and zero posted good units; the snapshot date is 2026-10-31.
- Shipment dispatch and customer receipt are different events; customer arrival is not modeled.
- The `effective_to` exclusive-end convention is uniform across BOM, standard costs and manufacturing rates.
- All material and finished-product stock quantities are in synthetic **pieces**, and there is no unit conversion in this initial version.
- Currency conversion must use `exchange_rates.czk_per_unit`, with CZK-to-CZK identity handled explicitly.
- Raw field format inconsistencies should be interpreted in the appropriate import locale without changing source rows.
