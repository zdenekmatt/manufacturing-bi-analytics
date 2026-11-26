#!/usr/bin/env python3
"""Deterministic, synthetic manufacturing case data. Python standard library only.
Run from repository root: python data/generator/generate.py
No genuine business, customer, or personal information is used.
"""
from __future__ import annotations
import csv
import calendar
import math
import random
from collections import defaultdict
from datetime import date, timedelta
from pathlib import Path

SEED = 20261115
rng = random.Random(SEED)
ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'data' / 'releases'
START = date(2024, 10, 1)
END = date(2026, 9, 30)
AS_OF = date(2026, 10, 31)
OPENING = START - timedelta(days=1)
MONTHS = [(2024 + (9+i)//12, (9+i)%12+1) for i in range(24)]
# Sanity: 2024-10 -> 2026-09
assert MONTHS[0] == (2024,10) and MONTHS[-1] == (2026,9)

ROWS: dict[str, list[dict]] = defaultdict(list)
RELEASE = {
    'customers':'01_core','products':'01_core','production_lines':'01_core',
    'sales_orders':'01_core','sales_order_lines':'01_core',
    'shipments':'01_core','shipment_lines':'01_core',
    'production_orders':'02_operations','production_operations':'02_operations',
    'downtime_events':'02_operations','quality_events':'02_operations',
    'materials':'03_supply_chain_finance','suppliers':'03_supply_chain_finance',
    'bom_components':'03_supply_chain_finance','purchase_order_lines':'03_supply_chain_finance',
    'goods_receipts':'03_supply_chain_finance','inventory_transactions':'03_supply_chain_finance',
    'material_cost_history':'03_supply_chain_finance',
    'product_standard_cost_history':'03_supply_chain_finance',
    'manufacturing_cost_rates':'03_supply_chain_finance','exchange_rates':'03_supply_chain_finance',
    'raw_goods_receipts_export':'03_supply_chain_finance',
}
FIELDS = {
 'customers':'customer_id,customer_code,customer_name,market',
 'products':'product_id,sku,product_family,line_id,unit_of_measure',
 'production_lines':'line_id,line_code,line_name',
 'sales_orders':'sales_order_id,customer_id,order_date,order_currency',
 'sales_order_lines':'sales_order_line_id,sales_order_id,product_id,ordered_qty,unit_price,requested_date,promised_date,line_status',
 'shipments':'shipment_id,sales_order_id,ship_date,carrier_code',
 'shipment_lines':'shipment_line_id,shipment_id,sales_order_line_id,shipped_qty',
 'production_orders':'production_order_id,sales_order_line_id,line_id,planned_qty,planned_start_date,planned_end_date,actual_start_date,actual_completion_date,produced_qty,good_qty,status',
 'production_operations':'operation_id,production_order_id,operation_seq,operation_type,operation_date,labor_hours,machine_hours',
 'downtime_events':'downtime_id,operation_id,event_date,duration_minutes,downtime_category,is_planned',
 'quality_events':'quality_event_id,production_order_id,inspection_date,inspected_qty,defective_qty,inspection_result',
 'materials':'material_id,material_code,material_name,base_unit',
 'suppliers':'supplier_id,supplier_code,supplier_name,supplier_country',
 'bom_components':'bom_component_id,product_id,material_id,quantity_per_unit,effective_from,effective_to',
 'purchase_order_lines':'purchase_order_line_id,supplier_id,material_id,order_date,confirmed_date,ordered_qty,unit_price,currency',
 'goods_receipts':'goods_receipt_id,purchase_order_line_id,receipt_date,accepted_qty,rejected_qty,receipt_reference',
 'inventory_transactions':'inventory_txn_id,txn_date,material_id,product_id,movement_type,qty_delta,goods_receipt_id,production_order_id,shipment_line_id,unit_cost_czk',
 'material_cost_history':'material_cost_id,material_id,effective_from,effective_to,standard_unit_cost_czk',
 'product_standard_cost_history':'product_cost_id,product_id,effective_from,effective_to,standard_unit_cost_czk',
 'manufacturing_cost_rates':'rate_id,line_id,effective_from,effective_to,labor_czk_per_hour,machine_czk_per_hour,overhead_czk_per_hour',
 'exchange_rates':'fx_rate_id,rate_date,currency,czk_per_unit',
 'raw_goods_receipts_export':'raw_row_id,receipt_reference,po_line_reference,received_date_text,accepted_qty_text,supplier_note,import_batch',
}

def put(table, **kwargs):
    ROWS[table].append(kwargs)

def day_in_month(y, m):
    return date(y, m, rng.randint(1, calendar.monthrange(y,m)[1]))

def clamp(d, lower, upper):
    return min(upper,max(lower,d))

def fmt(n,dec=3):
    return f'{n:.{dec}f}'

def mon_index(d):
    return max(0, min(23, (d.year-2024)*12+d.month-10))

def next_month(y,m):
    return (y+1,1) if m == 12 else (y,m+1)

def round_qty(q):
    return round(q,3)

# Dimensions: deliberately fictional business labels.
for k in range(1,7):
    put('production_lines',line_id=k,line_code=f'LN-{k:02d}',line_name=f'Assembly Cell {k}')
for k in range(1,81):
    put('customers',customer_id=k,customer_code=f'CUST-{k:04d}',customer_name=f'Industrial Account {k:03d}',market=rng.choice(['CZ','DE','AT','PL','SK','HU']))
for k in range(1,51):
    family=['Power Modules','Relay Systems','Control Panels','Sensor Interfaces','Terminal Blocks'][((k-1)//10)]
    put('products',product_id=k,sku=f'MIS-P{k:04d}',product_family=family,line_id=(k-1)%6+1,unit_of_measure='pcs')
for k in range(1,91):
    cat=['Copper Parts','PCB Components','Fasteners','Enclosures','Connectors','Insulation'][((k-1)//15)]
    put('materials',material_id=k,material_code=f'MAT-{k:04d}',material_name=f'{cat} - {k:03d}',base_unit='pcs')
for k in range(1,31):
    put('suppliers',supplier_id=k,supplier_code=f'SUP-{k:03d}',supplier_name=f'Industrial Supplier {k:03d}',supplier_country=['CZ','DE','AT','PL','SK'][k%5])
# Product BOM 3-4 distinct material components. Constant BOM version valid for coverage.
bom = defaultdict(list)
for product in range(1,51):
    mats = rng.sample(range(1,91),rng.choice([3,3,4]))
    for mid in mats:
        qty=round(rng.choice([1,2,3,4,6,8,12,16]) * rng.choice([0.25,0.5,1,1.0]),3)
        bom[product].append((mid,qty))
        put('bom_components',bom_component_id=len(ROWS['bom_components'])+1,product_id=product,material_id=mid,
            quantity_per_unit=fmt(qty),effective_from=START,effective_to='')

# Historic dates / costs / FX: valid-from inclusive, valid-to exclusive.
material_base={m:rng.uniform(4.0,105.0) for m in range(1,91)}
product_base={p:rng.uniform(330.0,1900.0) for p in range(1,51)}
for i in range(8):
    y,m=MONTHS[i*3]
    eff=date(y,m,1)
    eff_end=date(*MONTHS[(i+1)*3],1) if i<7 else ''
    for mid in range(1,91):
        val=material_base[mid]*(1+0.012*i+0.011*math.sin((mid+i)*.7))
        put('material_cost_history',material_cost_id=len(ROWS['material_cost_history'])+1,material_id=mid,
            effective_from=eff,effective_to=eff_end,standard_unit_cost_czk=fmt(val,2))
    for pid in range(1,51):
        val=product_base[pid]*(1+0.010*i+0.02*math.sin((pid+i)*.37))
        put('product_standard_cost_history',product_cost_id=len(ROWS['product_standard_cost_history'])+1,product_id=pid,
            effective_from=eff,effective_to=eff_end,standard_unit_cost_czk=fmt(val,2))
for mi,(y,m) in enumerate(MONTHS):
    eff=date(y,m,1)
    eff_end=date(*next_month(y,m),1) if mi <23 else ''
    for lid in range(1,7):
        put('manufacturing_cost_rates',rate_id=len(ROWS['manufacturing_cost_rates'])+1,line_id=lid,
            effective_from=eff,effective_to=eff_end,labor_czk_per_hour=fmt(265+lid*16+mi*2.1,2),
            machine_czk_per_hour=fmt(205+lid*23+mi*3.3,2),overhead_czk_per_hour=fmt(110+mi*2.5,2))
fx_by_day={}
for dnum in range((AS_OF-START).days+1):
    d=START+timedelta(days=dnum)
    for cur in ['EUR','USD']:
        val=(24.45 if cur=='EUR' else 22.6)+(.35 if cur=='EUR' else .7)*math.sin(dnum/37+(0 if cur=='EUR' else 1))+(0.001*dnum if cur=='EUR' else -0.0002*dnum)
        fx_by_day[(d,cur)]=round(val,4)
        put('exchange_rates',fx_rate_id=len(ROWS['exchange_rates'])+1,rate_date=d,currency=cur,czk_per_unit=fmt(val,4))

# Sales orders -> sales order lines -> one or two make-to-order production orders.
# Month 0..23 order volume similar enough for season comparisons.
orders=[]
order_lines=[]
prod_plans=[]
for oid in range(1,8601):
    mi=(oid-1)%24
    y,m=MONTHS[mi]
    d=day_in_month(y,m)
    # Do not start orders on the final week of the snapshot month.
    if d>date(2026,9,18): d=date(2026,9,rng.randint(1,18))
    customer=rng.randint(1,80)
    currency=rng.choices(['EUR','CZK','USD'],[0.61,0.34,0.05])[0]
    put('sales_orders',sales_order_id=oid,customer_id=customer,order_date=d,order_currency=currency)
    nline=rng.choices([1,2,3],[0.47,0.42,0.11])[0]
    products=rng.sample(range(1,51),nline)
    for ln,pid in enumerate(products,1):
        lid=len(ROWS['sales_order_lines'])+1
        qty=rng.randint(12,160)*rng.choice([1,1,1,2,3])
        req=d+timedelta(days=rng.randint(14,32))
        promised=req+timedelta(days=rng.randint(-3,8))
        price_czk=product_base[pid]*rng.uniform(1.25,1.85)
        fx=1.0 if currency=='CZK' else fx_by_day[(d,currency)]
        put('sales_order_lines',sales_order_line_id=lid,sales_order_id=oid,product_id=pid,ordered_qty=qty,
            unit_price=fmt(price_czk/fx,2),requested_date=req,promised_date=promised,line_status='PENDING')
        nprod=2 if rng.random()<0.11 and qty>50 else 1
        qparts=[qty] if nprod==1 else [qty//2,qty-qty//2]
        for pi,part_qty in enumerate(qparts):
            poid=len(prod_plans)+1
            p_start=d+timedelta(days=rng.randint(2,7)+pi)
            p_end=max(p_start+timedelta(days=3),promised-timedelta(days=rng.randint(2,6)))
            prod_plans.append(dict(production_order_id=poid,sales_order_line_id=lid,
                product_id=pid,line_id=(pid-1)%6+1,planned_qty=part_qty,
                planned_start_date=p_start,planned_end_date=p_end,
                order_month=mon_index(d),promised_date=promised))

# Material purchase orders and partial goods receipts are driven by planned demand.
month_demand=defaultdict(float)
for po in prod_plans:
    month=min(23,mon_index(po['planned_start_date']))
    for mid, per_unit in bom[po['product_id']]:
        month_demand[(month,mid)]+=po['planned_qty']*per_unit

po_by_id={}
receipts_by_po=defaultdict(list)
late_supplier_ratio=defaultdict(list)
for mi,(y,m) in enumerate(MONTHS):
    monthstart=date(y,m,1)
    for material in range(1,91):
        monthly_need=month_demand[(mi,material)]
        if monthly_need<0.001: continue
        supplier=(material-1)%30+1
        nlines=rng.choice([2,3,3,4])
        weights=[rng.uniform(.7,1.3) for _ in range(nlines)]
        weights=[x/sum(weights) for x in weights]
        quantities=[round_qty(monthly_need*rng.uniform(1.02,1.19)*w) for w in weights]
        for j,needed in enumerate(quantities):
            pol_id=len(ROWS['purchase_order_lines'])+1
            ordered_date=monthstart-timedelta(days=rng.randint(12,26)) + timedelta(days=j*5)
            confirmed=ordered_date+timedelta(days=rng.randint(8,17))
            # Differences are embedded in observed dates; no diagnostic labels stored.
            prob_late=.12+.17*(mi>=13)+.06*(supplier%7==0)
            delay=rng.randint(2,12) if rng.random()<prob_late else rng.randint(-4,1)
            first_receipt=clamp(confirmed+timedelta(days=delay),START,AS_OF)
            currency='EUR' if supplier%4 else 'CZK'
            price_czk=material_base[material]*(1+0.007*mi)*rng.uniform(.96,1.04)
            rate=1 if currency=='CZK' else fx_by_day[(clamp(ordered_date,START,AS_OF),currency)]
            unit_price=round(price_czk/rate,2)
            put('purchase_order_lines',purchase_order_line_id=pol_id,supplier_id=supplier,material_id=material,
                order_date=ordered_date,confirmed_date=confirmed,ordered_qty=fmt(needed),
                unit_price=fmt(unit_price,2),currency=currency)
            po_by_id[pol_id]=ROWS['purchase_order_lines'][-1]
            late_supplier_ratio[(mi,material)].append(int(first_receipt>confirmed))
            two_receipts=rng.random()<.43 and needed>=2
            if two_receipts:
                q1=round_qty(needed*rng.uniform(.35,.75))
                accepted=[q1,round_qty(needed-q1)]
            else:
                accepted=[needed]
            for ri,good in enumerate(accepted):
                receipt_date=clamp(first_receipt+timedelta(days=ri*rng.randint(2,6)),START,AS_OF)
                bad=round_qty(rng.uniform(.005,.025)*good) if rng.random()<.08 else 0.0
                # accepted quantity is the usable goods; rejected goods are additional delivered units
                rid=len(ROWS['goods_receipts'])+1
                ref=f'GR-{rid:07d}'
                put('goods_receipts',goods_receipt_id=rid,purchase_order_line_id=pol_id,
                    receipt_date=receipt_date,accepted_qty=fmt(good),rejected_qty=fmt(bad),receipt_reference=ref)
                receipts_by_po[pol_id].append(rid)

material_pressure={key:sum(values)/len(values) for key,values in late_supplier_ratio.items()}
# Set up inventory movements with explicit source FKs (NULL=not applicable).
stock_movements=[]
def move(d,typ,qty,material='',product='',receipt='',production='',shipline='',unit_cost=''):
    stock_movements.append(dict(txn_date=d,material_id=material,product_id=product,
        movement_type=typ,qty_delta=round_qty(qty),goods_receipt_id=receipt,
        production_order_id=production,shipment_line_id=shipline,unit_cost_czk=unit_cost))

for gr in ROWS['goods_receipts']:
    pol=po_by_id[gr['purchase_order_line_id']]
    currency=pol['currency']
    rate=1 if currency=='CZK' else fx_by_day[(gr['receipt_date'],currency)]
    price=round(float(pol['unit_price'])*rate,2)
    move(gr['receipt_date'],'material_receipt',float(gr['accepted_qty']),
         material=pol['material_id'],receipt=gr['goods_receipt_id'],unit_cost=fmt(price,2))

# Operations, line downtime, quality inspections & receipts of finished goods.
prod_finished=defaultdict(list)
for po in prod_plans:
    p_id=po['production_order_id']
    lid=po['line_id']
    mi=po['order_month']
    product=po['product_id']
    supplier_signal=sum(material_pressure.get((mi,mid),0.15) for mid,_ in bom[product])/len(bom[product])
    # Preserve realistic variability; do not encode a definitive causal attribution.
    badness=.08+.13*(mi>=12)+.05*(lid in (2,5))+.17*supplier_signal
    lag=(rng.randint(2,10) if rng.random()<badness else rng.randint(-4,1))
    candidate=po['planned_end_date']+timedelta(days=lag)
    ongoing=(mi==23 and rng.random()<.11) or (mi==22 and rng.random()<.02)
    done=(candidate<=AS_OF-timedelta(days=1)) and not ongoing
    astart=po['planned_start_date']+timedelta(days=rng.choice([0,0,1,2]))
    if done:
        completed=max(astart+timedelta(days=1),candidate)
        defective=round_qty(po['planned_qty']*rng.uniform(0.005,0.055)) if rng.random()<(.15+.08*(mi>=12)) else 0.0
        # Inspections use whole pieces, never fractional finished units.
        scrap=max(0,int(round(defective)))
        produced=po['planned_qty']+scrap
        good=po['planned_qty']
        status='Completed'
    else:
        completed=''
        produced=good=scrap=0
        status='Open'
    put('production_orders',production_order_id=p_id,sales_order_line_id=po['sales_order_line_id'],
        line_id=lid,planned_qty=po['planned_qty'],planned_start_date=po['planned_start_date'],
        planned_end_date=po['planned_end_date'],actual_start_date=astart if astart<=AS_OF else '',
        actual_completion_date=completed,produced_qty=produced,good_qty=good,status=status)
    if not done: continue
    prod_finished[po['sales_order_line_id']].append((completed,good))
    # Three operations per completed order: operation-level grain.
    span=max(1,(completed-astart).days)
    for opseq,optype in enumerate(['Preparation','Assembly','Testing'],1):
        op_date=astart+timedelta(days=round(span*(opseq-1)/2))
        op_id=len(ROWS['production_operations'])+1
        labor=po['planned_qty']*rng.uniform(.014,.030)
        machine=po['planned_qty']*rng.uniform(.012,.027)
        put('production_operations',operation_id=op_id,production_order_id=p_id,operation_seq=opseq,
            operation_type=optype,operation_date=op_date,labor_hours=fmt(labor,3),machine_hours=fmt(machine,3))
        events=rng.choices([0,1,2],[.79,.19,.02])[0]
        for ev in range(events):
            planned=rng.random()<.15
            put('downtime_events',downtime_id=len(ROWS['downtime_events'])+1,operation_id=op_id,
                event_date=op_date,duration_minutes=rng.randint(15,165),
                downtime_category=rng.choice(['Maintenance','Material Wait','Tooling','Setup','Equipment Fault']),
                is_planned=planned)
    put('quality_events',quality_event_id=len(ROWS['quality_events'])+1,production_order_id=p_id,
        inspection_date=completed,inspected_qty=produced,defective_qty=scrap,
        inspection_result='Defect Found' if scrap else 'Pass')
    for mid,per_unit in bom[product]:
        amount=round_qty(per_unit*good)
        cost=material_base[mid]*(1+0.009*mi)
        move(astart,'material_issue',-amount,material=mid,production=p_id,unit_cost=fmt(cost,2))
    move(completed,'finished_goods_receipt',good,product=product,production=p_id)

# Shipping: multiple shipment lines may fulfill the same sales order line.
ship_pieces=defaultdict(list)
for sl in ROWS['sales_order_lines']:
    lid=sl['sales_order_line_id']
    finished=prod_finished.get(lid,[])
    available=sum(q for _,q in finished)
    if not available: sl['line_status']='Open';continue
    qty=sl['ordered_qty']
    to_ship=min(qty,available)
    # Some unfinished commitments are partially shipped / open as of the snapshot.
    if rng.random()<.033:
        to_ship=int(to_ship*rng.uniform(.35,.85))
    if not to_ship:
        sl['line_status']='Open';continue
    last_done=max(d for d,_ in finished)
    earliest=last_done+timedelta(days=rng.randint(1,3))
    if earliest>AS_OF:
        sl['line_status']='Open';continue
    nparts=rng.choices([1,2,3],[.68,.29,.03])[0] if to_ship>=12 else 1
    if nparts==1: batches=[to_ship]
    else:
        cuts=sorted(rng.sample(range(1,to_ship),nparts-1))
        batches=[b-a for a,b in zip([0]+cuts,cuts+[to_ship])]
    actually_sent=0
    for bnum,bqty in enumerate(batches):
        shipday=earliest+timedelta(days=bnum*rng.randint(2,5))
        if shipday>AS_OF: continue
        # Group same-order same-day lines into a common shipment.
        ship_pieces[(sl['sales_order_id'],shipday)].append((lid,bqty,sl['product_id']))
        actually_sent+=bqty
    sl['line_status']='Fulfilled' if actually_sent==qty else ('Partially Shipped' if actually_sent else 'Open')

for (oid,ship_date),items in sorted(ship_pieces.items()):
    sid=len(ROWS['shipments'])+1
    put('shipments',shipment_id=sid,sales_order_id=oid,ship_date=ship_date,
        carrier_code=rng.choice(['CAR-01','CAR-02','CAR-03','CAR-04']))
    grouped=defaultdict(int)
    for lid,amount,product in items:
        grouped[(lid,product)]+=amount
    for (lid,product),amount in grouped.items():
        slid=len(ROWS['shipment_lines'])+1
        put('shipment_lines',shipment_line_id=slid,shipment_id=sid,sales_order_line_id=lid,shipped_qty=amount)
        move(ship_date,'finished_goods_shipment',-amount,product=product,shipline=slid)

# Initial stock levels are established explicitly at snapshot opening. Per-material
# opening stock is sufficient to keep nonnegative historical balance on every date.
flows=defaultdict(list)
for txn in stock_movements:
    if txn['material_id']:
        flows[txn['material_id']].append((txn['txn_date'],txn['qty_delta']))
for material in range(1,91):
    running=0.0
    smallest=0.0
    for _,v in sorted(flows[material],key=lambda x:x[0]):
        running=round_qty(running+v)
        smallest=min(smallest,running)
    reserve=max(100.0,abs(running)*.015)
    opening_qty=round_qty(max(0,-smallest)+reserve)
    move(OPENING,'opening_balance',opening_qty,material=material,
         unit_cost=fmt(material_base[material],2))
# Stable ID ordering, chronological, then type & source for repeatability.
stock_movements.sort(key=lambda x:(x['txn_date'],str(x['material_id']).zfill(4),str(x['product_id']).zfill(4),
                                  x['movement_type'],str(x['production_order_id']).zfill(8),str(x['shipment_line_id']).zfill(8),str(x['goods_receipt_id']).zfill(8)))
for txid,tx in enumerate(stock_movements,1):
    put('inventory_transactions',inventory_txn_id=txid,**tx)

# Deliberately raw/untrusted export: drifting date/number formats, optional notes,
# repeated receipt references. Canonical goods_receipts remains FK-consistent.
for gr in ROWS['goods_receipts']:
    pol=po_by_id[gr['purchase_order_line_id']]
    source_date=gr['receipt_date']
    dt=rng.choices([source_date.isoformat(),source_date.strftime('%d.%m.%Y'),source_date.strftime('%Y/%m/%d')],[.946,.035,.019])[0]
    num=gr['accepted_qty'].replace('.',',') if rng.random()<.052 else gr['accepted_qty']
    note='' if rng.random()<.09 else rng.choice(['Regular receipt','Packing slip checked','Dock scan'])
    put('raw_goods_receipts_export',raw_row_id=len(ROWS['raw_goods_receipts_export'])+1,
        receipt_reference=gr['receipt_reference'],po_line_reference=f"POL-{pol['purchase_order_line_id']:07d}",
        received_date_text=dt,accepted_qty_text=num,supplier_note=note,
        import_batch=f"BATCH-{source_date.strftime('%Y%m')}")
# Controlled duplicate raw rows, not duplicate canonical event IDs.
original=ROWS['raw_goods_receipts_export'][:]
for old in rng.sample(original,int(len(original)*.013)):
    row=dict(old)
    row['raw_row_id']=len(ROWS['raw_goods_receipts_export'])+1
    put('raw_goods_receipts_export',**row)

# CSV writer: no filesystem-derived randomness or library dependencies.
for table,cols in FIELDS.items():
    target=DATA/RELEASE[table]/f'{table}.csv'
    target.parent.mkdir(parents=True,exist_ok=True)
    with target.open('w',newline='',encoding='utf-8') as f:
        writer=csv.DictWriter(f,fieldnames=cols.split(','),lineterminator='\n')
        writer.writeheader()
        for row in ROWS[table]:
            writer.writerow({k: str(v) if isinstance(v,date) else v for k,v in row.items()})
print('Generated records by table:')
for table in FIELDS:
    print(f' {table:34} {len(ROWS[table]):>7,}')
print(f'TOTAL records: {sum(len(t) for t in ROWS.values()):,}; seed: {SEED}; snapshot: {AS_OF}')

# Machine-readable SHA-256 manifest enables re-generation comparisons on Windows.
import hashlib
import json
manifest={'dataset_version':'1.0.0','seed':SEED,'coverage_start':str(START),
          'coverage_end':str(END),'snapshot_date':str(AS_OF),'files':{}}
for table in FIELDS:
    path=DATA/RELEASE[table]/f'{table}.csv'
    manifest['files'][table]={'path':path.relative_to(ROOT).as_posix(),
                              'row_count':len(ROWS[table]),
                              'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
manifest['total_rows']=sum(len(x) for x in ROWS.values())
(ROOT/'data'/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
