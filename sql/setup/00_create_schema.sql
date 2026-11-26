-- Manufacturing Operations & BI Analytics; fictional/synthetic records only.
-- Intended database: PostgreSQL 16+ (SQL is not applied automatically).
-- Run once against a new, empty database: psql -X -v ON_ERROR_STOP=1 -d manufacturing_bi -f sql/setup/00_create_schema.sql
BEGIN;
CREATE SCHEMA mis;
CREATE SCHEMA raw_import;

CREATE TABLE mis.production_lines (
    line_id integer PRIMARY KEY,
    line_code text NOT NULL UNIQUE,
    line_name text NOT NULL
);
CREATE TABLE mis.customers (
    customer_id integer PRIMARY KEY,
    customer_code text NOT NULL UNIQUE,
    customer_name text NOT NULL,
    market char(2) NOT NULL
);
CREATE TABLE mis.products (
    product_id integer PRIMARY KEY,
    sku text NOT NULL UNIQUE,
    product_family text NOT NULL,
    line_id integer NOT NULL REFERENCES mis.production_lines(line_id),
    unit_of_measure text NOT NULL CHECK (unit_of_measure='pcs')
);
CREATE TABLE mis.materials (
    material_id integer PRIMARY KEY,
    material_code text NOT NULL UNIQUE,
    material_name text NOT NULL,
    base_unit text NOT NULL CHECK (base_unit='pcs')
);
CREATE TABLE mis.suppliers (
    supplier_id integer PRIMARY KEY,
    supplier_code text NOT NULL UNIQUE,
    supplier_name text NOT NULL,
    supplier_country char(2) NOT NULL
);
CREATE TABLE mis.bom_components (
    bom_component_id integer PRIMARY KEY,
    product_id integer NOT NULL REFERENCES mis.products(product_id),
    material_id integer NOT NULL REFERENCES mis.materials(material_id),
    quantity_per_unit numeric(14,3) NOT NULL CHECK (quantity_per_unit>0),
    effective_from date NOT NULL,
    effective_to date,
    UNIQUE (product_id, material_id, effective_from),
    CHECK (effective_to IS NULL OR effective_to > effective_from)
);
CREATE TABLE mis.sales_orders (
    sales_order_id integer PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES mis.customers(customer_id),
    order_date date NOT NULL,
    order_currency char(3) NOT NULL CHECK (order_currency IN ('CZK','EUR','USD'))
);
CREATE TABLE mis.sales_order_lines (
    sales_order_line_id integer PRIMARY KEY,
    sales_order_id integer NOT NULL REFERENCES mis.sales_orders(sales_order_id),
    product_id integer NOT NULL REFERENCES mis.products(product_id),
    ordered_qty integer NOT NULL CHECK (ordered_qty>0),
    unit_price numeric(14,2) NOT NULL CHECK (unit_price>0),
    requested_date date NOT NULL,
    promised_date date NOT NULL,
    line_status text NOT NULL CHECK (line_status IN ('Open','Partially Shipped','Fulfilled'))
);
CREATE TABLE mis.production_orders (
    production_order_id integer PRIMARY KEY,
    sales_order_line_id integer NOT NULL REFERENCES mis.sales_order_lines(sales_order_line_id),
    line_id integer NOT NULL REFERENCES mis.production_lines(line_id),
    planned_qty integer NOT NULL CHECK (planned_qty>0),
    planned_start_date date NOT NULL,
    planned_end_date date NOT NULL,
    actual_start_date date,
    actual_completion_date date,
    produced_qty integer NOT NULL CHECK (produced_qty>=0),
    good_qty integer NOT NULL CHECK (good_qty>=0),
    status text NOT NULL CHECK (status IN ('Completed','Open')),
    CHECK (planned_end_date>=planned_start_date),
    CHECK (produced_qty>=good_qty),
    CHECK ((status='Completed' AND actual_completion_date IS NOT NULL AND good_qty>0)
        OR (status='Open' AND actual_completion_date IS NULL AND good_qty=0))
);
CREATE TABLE mis.production_operations (
    operation_id integer PRIMARY KEY,
    production_order_id integer NOT NULL REFERENCES mis.production_orders(production_order_id),
    operation_seq smallint NOT NULL CHECK (operation_seq>0),
    operation_type text NOT NULL,
    operation_date date NOT NULL,
    labor_hours numeric(14,3) NOT NULL CHECK (labor_hours>=0),
    machine_hours numeric(14,3) NOT NULL CHECK (machine_hours>=0),
    UNIQUE (production_order_id,operation_seq)
);
CREATE TABLE mis.downtime_events (
    downtime_id integer PRIMARY KEY,
    operation_id integer NOT NULL REFERENCES mis.production_operations(operation_id),
    event_date date NOT NULL,
    duration_minutes integer NOT NULL CHECK (duration_minutes>0),
    downtime_category text NOT NULL,
    is_planned boolean NOT NULL
);
CREATE TABLE mis.quality_events (
    quality_event_id integer PRIMARY KEY,
    production_order_id integer NOT NULL REFERENCES mis.production_orders(production_order_id),
    inspection_date date NOT NULL,
    inspected_qty integer NOT NULL CHECK (inspected_qty>0),
    defective_qty integer NOT NULL CHECK (defective_qty>=0 AND defective_qty<=inspected_qty),
    inspection_result text NOT NULL CHECK (inspection_result IN ('Pass','Defect Found'))
);
CREATE TABLE mis.purchase_order_lines (
    purchase_order_line_id integer PRIMARY KEY,
    supplier_id integer NOT NULL REFERENCES mis.suppliers(supplier_id),
    material_id integer NOT NULL REFERENCES mis.materials(material_id),
    order_date date NOT NULL,
    confirmed_date date NOT NULL,
    ordered_qty numeric(14,3) NOT NULL CHECK (ordered_qty>0),
    unit_price numeric(14,2) NOT NULL CHECK (unit_price>0),
    currency char(3) NOT NULL CHECK (currency IN ('CZK','EUR','USD')),
    CHECK (confirmed_date>=order_date)
);
CREATE TABLE mis.goods_receipts (
    goods_receipt_id integer PRIMARY KEY,
    purchase_order_line_id integer NOT NULL REFERENCES mis.purchase_order_lines(purchase_order_line_id),
    receipt_date date NOT NULL,
    accepted_qty numeric(14,3) NOT NULL CHECK (accepted_qty>0),
    rejected_qty numeric(14,3) NOT NULL CHECK (rejected_qty>=0),
    receipt_reference text NOT NULL UNIQUE
);
CREATE TABLE mis.shipments (
    shipment_id integer PRIMARY KEY,
    sales_order_id integer NOT NULL REFERENCES mis.sales_orders(sales_order_id),
    ship_date date NOT NULL,
    carrier_code text NOT NULL
);
CREATE TABLE mis.shipment_lines (
    shipment_line_id integer PRIMARY KEY,
    shipment_id integer NOT NULL REFERENCES mis.shipments(shipment_id),
    sales_order_line_id integer NOT NULL REFERENCES mis.sales_order_lines(sales_order_line_id),
    shipped_qty integer NOT NULL CHECK (shipped_qty>0),
    UNIQUE (shipment_id,sales_order_line_id)
);
CREATE TABLE mis.inventory_transactions (
    inventory_txn_id integer PRIMARY KEY,
    txn_date date NOT NULL,
    material_id integer REFERENCES mis.materials(material_id),
    product_id integer REFERENCES mis.products(product_id),
    movement_type text NOT NULL CHECK (movement_type IN ('opening_balance','material_receipt','material_issue',
                                         'finished_goods_receipt','finished_goods_shipment')),
    qty_delta numeric(14,3) NOT NULL CHECK (qty_delta<>0),
    goods_receipt_id integer REFERENCES mis.goods_receipts(goods_receipt_id),
    production_order_id integer REFERENCES mis.production_orders(production_order_id),
    shipment_line_id integer REFERENCES mis.shipment_lines(shipment_line_id),
    unit_cost_czk numeric(14,2),
    CHECK ((material_id IS NOT NULL AND product_id IS NULL) OR (material_id IS NULL AND product_id IS NOT NULL))
);
CREATE TABLE mis.material_cost_history (
    material_cost_id integer PRIMARY KEY,
    material_id integer NOT NULL REFERENCES mis.materials(material_id),
    effective_from date NOT NULL,
    effective_to date,
    standard_unit_cost_czk numeric(14,2) NOT NULL CHECK (standard_unit_cost_czk>0),
    UNIQUE (material_id,effective_from),
    CHECK (effective_to IS NULL OR effective_to>effective_from)
);
CREATE TABLE mis.product_standard_cost_history (
    product_cost_id integer PRIMARY KEY,
    product_id integer NOT NULL REFERENCES mis.products(product_id),
    effective_from date NOT NULL,
    effective_to date,
    standard_unit_cost_czk numeric(14,2) NOT NULL CHECK (standard_unit_cost_czk>0),
    UNIQUE (product_id,effective_from),
    CHECK (effective_to IS NULL OR effective_to>effective_from)
);
CREATE TABLE mis.manufacturing_cost_rates (
    rate_id integer PRIMARY KEY,
    line_id integer NOT NULL REFERENCES mis.production_lines(line_id),
    effective_from date NOT NULL,
    effective_to date,
    labor_czk_per_hour numeric(14,2) NOT NULL CHECK (labor_czk_per_hour>=0),
    machine_czk_per_hour numeric(14,2) NOT NULL CHECK (machine_czk_per_hour>=0),
    overhead_czk_per_hour numeric(14,2) NOT NULL CHECK (overhead_czk_per_hour>=0),
    UNIQUE (line_id,effective_from),
    CHECK (effective_to IS NULL OR effective_to>effective_from)
);
CREATE TABLE mis.exchange_rates (
    fx_rate_id integer PRIMARY KEY,
    rate_date date NOT NULL,
    currency char(3) NOT NULL CHECK (currency IN ('EUR','USD')),
    czk_per_unit numeric(12,4) NOT NULL CHECK (czk_per_unit>0),
    UNIQUE (rate_date,currency)
);
CREATE TABLE raw_import.raw_goods_receipts_export (
    raw_row_id integer PRIMARY KEY,
    receipt_reference text,
    po_line_reference text,
    received_date_text text,
    accepted_qty_text text,
    supplier_note text,
    import_batch text
);

-- Query performance support, not precomputed analytical solutions.
CREATE INDEX ix_sales_orders_date ON mis.sales_orders(order_date);
CREATE INDEX ix_sales_lines_order ON mis.sales_order_lines(sales_order_id);
CREATE INDEX ix_sales_lines_promised ON mis.sales_order_lines(promised_date);
CREATE INDEX ix_production_line ON mis.production_orders(sales_order_line_id);
CREATE INDEX ix_operations_production_date ON mis.production_operations(production_order_id,operation_date);
CREATE INDEX ix_quality_production ON mis.quality_events(production_order_id);
CREATE INDEX ix_shipments_order_date ON mis.shipments(sales_order_id,ship_date);
CREATE INDEX ix_shipment_lines_line ON mis.shipment_lines(sales_order_line_id);
CREATE INDEX ix_po_material ON mis.purchase_order_lines(material_id,confirmed_date);
CREATE INDEX ix_receipts_pol ON mis.goods_receipts(purchase_order_line_id,receipt_date);
CREATE INDEX ix_inventory_material_date ON mis.inventory_transactions(material_id,txn_date);
CREATE INDEX ix_inventory_product_date ON mis.inventory_transactions(product_id,txn_date);
CREATE INDEX ix_mcost_lookup ON mis.material_cost_history(material_id,effective_from);
CREATE INDEX ix_pcost_lookup ON mis.product_standard_cost_history(product_id,effective_from);
CREATE INDEX ix_fx_lookup ON mis.exchange_rates(currency,rate_date);
COMMIT;
