#!/usr/bin/env python3
"""Business-consistency QA over generated CSV files, without PostgreSQL.
Run from repository root: python data/generator/validate.py
Requires only Python stdlib; verifies local CSV, not server import.
"""
import csv
import hashlib
import json
from collections import Counter, defaultdict
from datetime import date
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
manifest=json.loads((ROOT/'data/manifest.json').read_text(encoding='utf-8'))
tables={}
def assert_ok(condition, explanation):
    if not condition: raise AssertionError(explanation)

def d(x):
    return date.fromisoformat(x)

def f(x):
    return float(x)

for table,meta in manifest['files'].items():
    fp=ROOT/meta['path']
    assert_ok(fp.is_file(),f'Missing {fp}')
    assert_ok(hashlib.sha256(fp.read_bytes()).hexdigest()==meta['sha256'],f'Checksum changed: {table}')
    with fp.open(newline='',encoding='utf-8') as source:
        data=list(csv.DictReader(source))
    assert_ok(len(data)==meta['row_count'],f'Unexpected count: {table}')
    tables[table]=data
assert_ok(sum(map(len,tables.values()))==manifest['total_rows'],'Total record count not matching manifest')

PKS={'customers':'customer_id','products':'product_id','production_lines':'line_id',
'sales_orders':'sales_order_id','sales_order_lines':'sales_order_line_id','shipments':'shipment_id',
'shipment_lines':'shipment_line_id','production_orders':'production_order_id',
'production_operations':'operation_id','downtime_events':'downtime_id','quality_events':'quality_event_id',
'materials':'material_id','suppliers':'supplier_id','bom_components':'bom_component_id',
'purchase_order_lines':'purchase_order_line_id','goods_receipts':'goods_receipt_id',
'inventory_transactions':'inventory_txn_id','material_cost_history':'material_cost_id',
'product_standard_cost_history':'product_cost_id','manufacturing_cost_rates':'rate_id',
'exchange_rates':'fx_rate_id','raw_goods_receipts_export':'raw_row_id'}
idx={}
for tbl,field in PKS.items():
    keys=[r[field] for r in tables[tbl]]
    assert_ok(all(keys),f'Missing PK: {tbl}')
    assert_ok(len(set(keys))==len(keys),f'Duplicate PK: {tbl}')
    idx[tbl]={r[field]:r for r in tables[tbl]}

FKS=[('products','line_id','production_lines'),('sales_orders','customer_id','customers'),
 ('sales_order_lines','sales_order_id','sales_orders'),('sales_order_lines','product_id','products'),
 ('bom_components','material_id','materials'),('bom_components','product_id','products'),
 ('production_orders','sales_order_line_id','sales_order_lines'),('production_orders','line_id','production_lines'),
 ('production_operations','production_order_id','production_orders'),
 ('downtime_events','operation_id','production_operations'),('quality_events','production_order_id','production_orders'),
 ('purchase_order_lines','material_id','materials'),('purchase_order_lines','supplier_id','suppliers'),
 ('goods_receipts','purchase_order_line_id','purchase_order_lines'),
 ('shipments','sales_order_id','sales_orders'),('shipment_lines','shipment_id','shipments'),
 ('shipment_lines','sales_order_line_id','sales_order_lines'),
 ('inventory_transactions','material_id','materials'),('inventory_transactions','product_id','products'),
 ('inventory_transactions','goods_receipt_id','goods_receipts'),
 ('inventory_transactions','production_order_id','production_orders'),
 ('inventory_transactions','shipment_line_id','shipment_lines'),
 ('material_cost_history','material_id','materials'),('product_standard_cost_history','product_id','products'),
 ('manufacturing_cost_rates','line_id','production_lines')]
for child,key,parent in FKS:
    assert_ok(all(row[key] in idx[parent] for row in tables[child] if row[key]),f'Broken FK: {child}.{key} -> {parent}')

orders=idx['sales_orders']; lines=idx['sales_order_lines']; prods=idx['production_orders']
shipments=idx['shipments']; ops=idx['production_operations']; quality=idx['quality_events'];
po_lines=idx['purchase_order_lines']; goods=idx['goods_receipts']
product_dim=idx['products']
plan=defaultdict(int); prod_finished=defaultdict(int); shipped=defaultdict(int)
finished_by_line=defaultdict(list); good_by_po={}
for p in prods.values():
    sl=lines[p['sales_order_line_id']]
    assert_ok(p['line_id']==product_dim[sl['product_id']]['line_id'],'Product production-line mismatch')
    plan[p['sales_order_line_id']]+=int(p['planned_qty'])
    assert_ok(d(p['planned_start_date'])<=d(p['planned_end_date']),'Bad planned chronology')
    assert_ok(int(p['produced_qty'])>=int(p['good_qty']),'Invalid production quantities')
    if p['status']=='Completed':
        assert_ok(bool(p['actual_completion_date']),'Completed production missing completion date')
        assert_ok(d(p['actual_start_date'])<=d(p['actual_completion_date']),'Production completion before start')
        prod_finished[p['sales_order_line_id']]+=int(p['good_qty'])
        finished_by_line[p['sales_order_line_id']].append(d(p['actual_completion_date']))
    else:
        assert_ok(p['status']=='Open' and not p['actual_completion_date'] and int(p['good_qty'])==0,'Bad open production')
    good_by_po[p['production_order_id']]=int(p['good_qty'])
assert_ok(all(plan[x['sales_order_line_id']]==int(x['ordered_qty']) for x in lines.values()),'Planned production and ordered units disagree')

for o in ops.values():
    p=prods[o['production_order_id']]
    assert_ok(p['status']=='Completed','Open production order has finalized operations')
    assert_ok(d(p['actual_start_date'])<=d(o['operation_date'])<=d(p['actual_completion_date']),'Operation chronology broken')
    assert_ok(f(o['labor_hours'])>=0 and f(o['machine_hours'])>=0,'Negative operation hours')
assert_ok(all(d(event['event_date'])==d(ops[event['operation_id']]['operation_date']) for event in tables['downtime_events']),'Downtime outside operation date')
q_by_po=defaultdict(list)
for q in quality.values():
    p=prods[q['production_order_id']]
    assert_ok(p['status']=='Completed','Inspection for unfinished production')
    assert_ok(d(q['inspection_date'])==d(p['actual_completion_date']),'Quality date mismatch')
    assert_ok(int(q['defective_qty'])<=int(q['inspected_qty']),'Impossible quality quantity')
    q_by_po[q['production_order_id']].append(q)
for p in prods.values():
    q=q_by_po[p['production_order_id']]
    assert_ok(len(q)==(1 if p['status']=='Completed' else 0),'Quality inspection count mismatch')
    if q:
        assert_ok(int(q[0]['defective_qty'])==int(p['produced_qty'])-int(p['good_qty']),'Production defect count not reconciled')

shipment_groups=defaultdict(list)
for row in tables['shipment_lines']:
    sid=row['shipment_id'];lid=row['sales_order_line_id']
    s=shipments[sid];sl=lines[lid]
    assert_ok(s['sales_order_id']==sl['sales_order_id'],'Shipment contains line from other sales order')
    assert_ok(d(s['ship_date'])>=d(orders[s['sales_order_id']]['order_date']),'Shipment before sales order')
    assert_ok(finished_by_line[lid] and d(s['ship_date'])>max(finished_by_line[lid]),'Shipment without production')
    assert_ok(int(row['shipped_qty'])>0,'Nonpositive shipped quantity')
    shipped[lid]+=int(row['shipped_qty'])
    shipment_groups[sid].append(lid)
for sl in lines.values():
    lid=sl['sales_order_line_id']
    qty=int(sl['ordered_qty']);actual=shipped[lid]
    assert_ok(actual<=qty and actual<=prod_finished[lid],'Over-shipped line vs orders or production')
    expected='Fulfilled' if actual==qty else ('Partially Shipped' if actual else 'Open')
    assert_ok(sl['line_status']==expected,'Line shipment status inconsistent')
    assert_ok(d(sl['requested_date'])>=d(orders[sl['sales_order_id']]['order_date']),'Requested date before order')
assert_ok(all(len(set(lids))==len(lids) for lids in shipment_groups.values()),'Duplicate order line in same shipment')

accepted=defaultdict(float)
for gr in goods.values():
    pol=po_lines[gr['purchase_order_line_id']]
    assert_ok(d(gr['receipt_date'])>=d(pol['order_date']),'Goods received before PO placed')
    accepted[gr['purchase_order_line_id']]+=f(gr['accepted_qty'])
for pol in po_lines.values():
    assert_ok(abs(accepted[pol['purchase_order_line_id']]-f(pol['ordered_qty']))<.008,'PO partial receipts mismatch')

bom_by_product=defaultdict(dict)
for b in tables['bom_components']:
    assert_ok(d(b['effective_from'])<=d(orders['1']['order_date']), 'BOM coverage starts after first order')
    bom_by_product[b['product_id']][b['material_id']]=f(b['quantity_per_unit'])

# Inventory movement reconciliation and nonnegative daily book stock.
receipt_tx=defaultdict(list); issue_tx=defaultdict(list); fg_tx=defaultdict(list); ship_tx=defaultdict(list)
ledger=defaultdict(lambda:defaultdict(float))
opening=Counter()
for tx in tables['inventory_transactions']:
    m=tx['material_id'];p=tx['product_id'];q=f(tx['qty_delta']);ty=tx['movement_type']
    assert_ok(bool(m)!=bool(p),'Inventory transaction must refer to exactly one item')
    obj=('material',m) if m else ('product',p)
    ledger[obj][d(tx['txn_date'])]+=q
    if ty=='opening_balance':
        assert_ok(bool(m) and q>0,'Opening transaction must hold positive raw stock')
        opening[m]+=1
    elif ty=='material_receipt':
        assert_ok(m and q>0 and tx['goods_receipt_id'],'Invalid material receipt movement')
        receipt_tx[tx['goods_receipt_id']].append(q)
    elif ty=='material_issue':
        assert_ok(m and q<0 and tx['production_order_id'],'Invalid material issue movement')
        issue_tx[(tx['production_order_id'],m)].append(q)
    elif ty=='finished_goods_receipt':
        assert_ok(p and q>0 and tx['production_order_id'],'Invalid FG production movement')
        fg_tx[tx['production_order_id']].append(q)
    elif ty=='finished_goods_shipment':
        assert_ok(p and q<0 and tx['shipment_line_id'],'Invalid FG shipment movement')
        ship_tx[tx['shipment_line_id']].append(q)
    else: raise AssertionError('Unrecognized stock movement')
assert_ok(len(opening)==len(idx['materials']) and set(opening.values())=={1},'Wrong opening balance count')
for obj,by_date in ledger.items():
    qty=0
    for day,amt in sorted(by_date.items()):
        qty+=amt
        assert_ok(qty>=-.01,f'Negative end-of-day stock: {obj} {day}, qty={qty}')
for gr in goods.values():
    t=receipt_tx[gr['goods_receipt_id']]
    assert_ok(len(t)==1 and abs(t[0]-f(gr['accepted_qty']))<.005,'Goods receipt inventory mismatch')
for p in prods.values():
    pid=p['production_order_id']
    completed=p['status']=='Completed'
    assert_ok(len(fg_tx[pid])==(1 if completed else 0),'Finished receipt missing / unexpected')
    if completed:
        assert_ok(abs(fg_tx[pid][0]-int(p['good_qty']))<.005,'FG produced units mismatch')
        product=lines[p['sales_order_line_id']]['product_id']
        for mid,per_unit in bom_by_product[product].items():
            t=issue_tx[(pid,mid)]
            assert_ok(len(t)==1 and abs(t[0]+int(p['good_qty'])*per_unit)<.006,'BOM material consumption mismatch')
for sh in tables['shipment_lines']:
    out=ship_tx[sh['shipment_line_id']]
    assert_ok(len(out)==1 and abs(out[0]+int(sh['shipped_qty']))<.006,'Shipped finished goods stock mismatch')

# Effective date windows have exact coverage (no overlaps) for relevant activities.
material_cost=defaultdict(list); prod_cost=defaultdict(list); manufacturing_rates=defaultdict(list)
for rec in tables['material_cost_history']: material_cost[rec['material_id']].append(rec)
for rec in tables['product_standard_cost_history']:prod_cost[rec['product_id']].append(rec)
for rec in tables['manufacturing_cost_rates']:manufacturing_rates[rec['line_id']].append(rec)

def period_valid(rows,on):
    return sum(d(r['effective_from'])<=on and (not r['effective_to'] or on<d(r['effective_to'])) for r in rows)==1

for po in prods.values():
    if po['status']=='Completed':
        activity_date=d(po['actual_start_date'])
        prod=lines[po['sales_order_line_id']]['product_id']
        assert_ok(period_valid(prod_cost[prod],activity_date),'No product standard cost valid at activity date')
        for mid in bom_by_product[prod]:
            assert_ok(period_valid(material_cost[mid],activity_date),'No material cost valid at activity date')
for op in ops.values():
    p=prods[op['production_order_id']]
    assert_ok(period_valid(manufacturing_rates[p['line_id']],d(op['operation_date'])),'No manufacturing rate for operation date')
fx_by_date={(x['rate_date'],x['currency']) for x in tables['exchange_rates']}
for order in orders.values():
    if order['order_currency']!='CZK':
        assert_ok((order['order_date'],order['order_currency']) in fx_by_date,'FX missing for customer order')
for g in goods.values():
    po=po_lines[g['purchase_order_line_id']]
    if po['currency']!='CZK':assert_ok((g['receipt_date'],po['currency']) in fx_by_date,'FX missing for GR')

raw=tables['raw_goods_receipts_export']
raw_refs=Counter(r['receipt_reference'] for r in raw)
raw_duplicate_count=sum(count-1 for count in raw_refs.values())
assert_ok(raw_duplicate_count>0 and set(raw_refs)=={gr['receipt_reference'] for gr in goods.values()},'Raw event references do not reconcile')
assert_ok(any(not r['supplier_note'] for r in raw),'Expected optional fields missing not found')
assert_ok(any('/' in r['received_date_text'] for r in raw) and any('.' in r['received_date_text'] for r in raw),'Expected raw date format drift absent')
assert_ok(any(',' in r['accepted_qty_text'] for r in raw),'Expected raw decimal format drift absent')

# Static PostgreSQL schema / CSV header / psql import contract check.
# This cannot replace executing the SQL on PostgreSQL itself.
import re
schema_sql=(ROOT/'sql/setup/00_create_schema.sql').read_text(encoding='utf-8')
loader_sql=(ROOT/'sql/setup/01_load_data.psql').read_text(encoding='utf-8')
schema_tables={}
for m in re.finditer(r'CREATE TABLE (mis|raw_import)\.(\w+)\s*\(\n(.*?)\n\);',schema_sql,re.S):
    table=m.group(2)
    defs=m.group(3)
    columns=[]
    for line in defs.splitlines():
        col=re.match(r'\s*([a-z][\w]*)\s+(integer|smallint|text|date|boolean|char\(\d+\)|numeric\(\d+,\d+\))(?=\s|,|$)',line)
        if col: columns.append(col.group(1))
    schema_tables[table]=columns
assert_ok(set(schema_tables)==set(tables),'Postgres DDL tables do not correspond to generated CSV tables')
for table,columns in schema_tables.items():
    assert_ok(columns==list(tables[table][0]),f'SQL-CSV column mismatch: {table}')
imports=re.findall(r"^\\copy\s+(?:mis|raw_import)\.(\w+)\s+FROM\s+'([^']+)'",loader_sql,re.M)
assert_ok(len(imports)==len(tables),'psql importer missing table')
assert_ok({x[0] for x in imports}==set(tables),'psql importer table mismatch')
for name,path in imports:
    assert_ok(path==manifest['files'][name]['path'],f'Wrong CSV import path: {name}')

summary={
  'result':'PASS',
  'verification_scope':'Local CSV checksum, PK/FK, chronology, quantities, effective dates, inventory daily stock, controlled raw anomalies',
  'limitations':'PostgreSQL import and SQL checks must be run on a live local PostgreSQL server; this check does not verify the user PC.',
  'dataset_version':manifest['dataset_version'],'seed':manifest['seed'],
  'total_rows':manifest['total_rows'],'tables':len(tables),
  'business_records':{'sales_orders':len(orders),'sales_order_lines':len(lines),
  'production_orders':len(prods),'production_orders_open':sum(x['status']=='Open' for x in prods.values()),
  'shipment_lines':len(tables['shipment_lines']),'goods_receipts':len(goods),
  'inventory_transactions':len(tables['inventory_transactions'])},
  'raw_export_notes':{'deliberate_duplicate_references':raw_duplicate_count,
                      'raw_missing_optional_note_rows':sum(not r['supplier_note'] for r in raw)},
  'checks':{'sha256_manifest':'PASS','static_postgres_import_contract':'PASS','primary_keys':'PASS','foreign_keys':'PASS','quantity_allocation':'PASS',
            'business_event_chronology':'PASS','sales_shipping_reconciliation':'PASS',
            'procurement_receipt_reconciliation':'PASS','production_quality_reconciliation':'PASS',
            'inventory_movements':'PASS','nonnegative_end_of_day_stock':'PASS',
            'effective_dated_costs':'PASS','foreign_exchange_coverage':'PASS','raw_export_reconciliation':'PASS'}
}
(ROOT/'data'/'qa_summary.json').write_text(json.dumps(summary,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(summary,indent=2,ensure_ascii=False))
