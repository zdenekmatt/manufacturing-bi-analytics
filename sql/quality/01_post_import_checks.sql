-- Check after CSV import into PostgreSQL.
-- Summary only: does not give away business conclusions or ticket answers.
SELECT 'mis.customers' AS table_name, count(*) AS row_count FROM mis.customers
UNION ALL SELECT 'mis.sales_orders',count(*) FROM mis.sales_orders
UNION ALL SELECT 'mis.sales_order_lines',count(*) FROM mis.sales_order_lines
UNION ALL SELECT 'mis.production_orders',count(*) FROM mis.production_orders
UNION ALL SELECT 'mis.production_operations',count(*) FROM mis.production_operations
UNION ALL SELECT 'mis.quality_events',count(*) FROM mis.quality_events
UNION ALL SELECT 'mis.shipments',count(*) FROM mis.shipments
UNION ALL SELECT 'mis.shipment_lines',count(*) FROM mis.shipment_lines
UNION ALL SELECT 'mis.purchase_order_lines',count(*) FROM mis.purchase_order_lines
UNION ALL SELECT 'mis.goods_receipts',count(*) FROM mis.goods_receipts
UNION ALL SELECT 'mis.inventory_transactions',count(*) FROM mis.inventory_transactions
UNION ALL SELECT 'raw_import.raw_goods_receipts_export',count(*) FROM raw_import.raw_goods_receipts_export
ORDER BY table_name;

DO $$
BEGIN
  IF (SELECT count(*) FROM mis.sales_orders) <> 8600
     THEN RAISE EXCEPTION 'sales_orders count does not match baseline'; END IF;
  IF (SELECT count(*) FROM mis.sales_order_lines) <> 14077
     THEN RAISE EXCEPTION 'sales_order_lines count does not match baseline'; END IF;
  IF (SELECT count(*) FROM mis.production_orders) <> 15287
     THEN RAISE EXCEPTION 'production_orders count does not match baseline'; END IF;
  IF (SELECT count(*) FROM mis.shipment_lines) <> 18930
     THEN RAISE EXCEPTION 'shipment_lines count does not match baseline'; END IF;
  IF EXISTS (
      SELECT 1 FROM mis.shipment_lines sl
      JOIN mis.shipments s ON s.shipment_id=sl.shipment_id
      JOIN mis.sales_order_lines ol ON ol.sales_order_line_id=sl.sales_order_line_id
      WHERE s.sales_order_id<>ol.sales_order_id
  ) THEN RAISE EXCEPTION 'shipment line references a different sales order'; END IF;
  IF EXISTS (
      SELECT 1 FROM mis.shipment_lines sl JOIN mis.shipments s ON s.shipment_id=sl.shipment_id
      JOIN mis.sales_order_lines ol ON ol.sales_order_line_id=sl.sales_order_line_id
      JOIN mis.sales_orders so ON so.sales_order_id=ol.sales_order_id
      WHERE s.ship_date<so.order_date
  ) THEN RAISE EXCEPTION 'shipments preceding order'; END IF;
  IF EXISTS (
      SELECT 1 FROM mis.sales_order_lines ol
      LEFT JOIN (SELECT sales_order_line_id, sum(shipped_qty) shipped FROM mis.shipment_lines GROUP BY 1) x USING(sales_order_line_id)
      WHERE coalesce(x.shipped,0)>ol.ordered_qty
  ) THEN RAISE EXCEPTION 'shipped quantity exceeds ordered quantity'; END IF;
  IF EXISTS (
      SELECT 1 FROM mis.sales_order_lines ol
      LEFT JOIN (SELECT sales_order_line_id,sum(planned_qty) qty FROM mis.production_orders GROUP BY 1) x USING(sales_order_line_id)
      WHERE coalesce(x.qty,0)<>ol.ordered_qty
  ) THEN RAISE EXCEPTION 'production allocations do not match order line quantity'; END IF;
  IF EXISTS (
      SELECT 1 FROM mis.purchase_order_lines pol
      LEFT JOIN (SELECT purchase_order_line_id,sum(accepted_qty) accepted FROM mis.goods_receipts GROUP BY 1) x USING(purchase_order_line_id)
      WHERE abs(coalesce(x.accepted,0)-pol.ordered_qty)>0.005
  ) THEN RAISE EXCEPTION 'PO receipts do not reconcile'; END IF;
  IF EXISTS (
      SELECT 1 FROM mis.production_orders p
      LEFT JOIN (SELECT production_order_id,sum(defective_qty) defective FROM mis.quality_events GROUP BY 1) q USING(production_order_id)
      WHERE p.status='Completed' AND p.produced_qty-p.good_qty<>coalesce(q.defective,0)
  ) THEN RAISE EXCEPTION 'production vs quality does not reconcile'; END IF;
  IF EXISTS (
      SELECT 1 FROM mis.goods_receipts gr
      LEFT JOIN mis.inventory_transactions it ON it.goods_receipt_id=gr.goods_receipt_id
      GROUP BY gr.goods_receipt_id, gr.accepted_qty
      HAVING count(it.inventory_txn_id)<>1 OR abs(sum(it.qty_delta)-gr.accepted_qty)>0.005
  ) THEN RAISE EXCEPTION 'inventory material receipt flow does not reconcile'; END IF;
END $$;
SELECT 'PASS: import baseline and business-key integrity assertions' AS qa_status;

-- Raw import issues are expected and intentional; do not enforce uniqueness here.
SELECT count(*) AS raw_rows, count(DISTINCT receipt_reference) AS raw_unique_receipt_refs,
       count(*) - count(DISTINCT receipt_reference) AS repeated_raw_references
FROM raw_import.raw_goods_receipts_export;
