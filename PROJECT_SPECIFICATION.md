# PROJECT SPECIFICATION — Manufacturing Operations & BI Analytics

> **Drafted project charter / schválený rámec.** Konkrétní data, čísla KPI a technické detaily se teprve vytvoří a ověří.
> **Version:** 1.0 | **Date:** 2026-11-15

## 1. Business context

**Company (fictional):** Moravia Industrial Systems, an electrical-components manufacturer based in Brno serving industrial customers in Central Europe. The company operates six fictional production lines and collaborates with procurement, warehousing, quality control, sales, and finance.

**Business question:** Why is on-time customer order fulfillment deteriorating while operating costs are increasing?

**Analyst's mission:** Investigate the available evidence, define trustworthy KPIs, provide cross-functional reporting, communicate limitations, and propose justified next steps to management. A convincing analysis may conclude that the available data do not establish causality.

**Important:** The company and all records are fictional. This project does not represent work conducted for ABB or any other real company.

## 2. Project boundaries

| Dimension | Proposed scope |
|---|---|
| Main technology | PostgreSQL + Microsoft Power BI (Power Query, DAX) |
| Supplementary tools | CSV/Excel, Git/GitHub; Python for synthetic-data generation if useful |
| Dataset | Approximately 200k–300k rows across related entities, subject to performance/utility review |
| Temporal coverage | Aim for ~24 months of coherent historical records; exact date window selected during generation |
| Business domains | Sales orders, production, quality, procurement, inventory, shipping, cost |
| Working language | English for tickets, KPI names, data dictionary, public portfolio; Czech for mentoring/reviews |
| Effort | Approximately 60–80 hours, flexible; quality and learning take precedence |
| Work items | Approximately 8–10 core tickets + 4–6 optional extension tickets |
| BI report | Four eventual pages; two pages in first usable milestone |

### Out of scope

Live ERP/SAP access, a real enterprise data warehouse, industrial IoT implementation, predictive ML, elaborate orchestration, production cloud deployment, and Power BI Service administration. These may be briefly discussed, but should not become prerequisites to finishing the portfolio.

## 3. Proposed data sources

Data is introduced in stages to resemble real work. Names below are **logical entities, not an already implemented database**.

| Source (simulated) | Logical records | Example grain |
|---|---|---|
| ERP | customers, products, sales_orders, sales_order_lines, production_orders, purchase_order_lines | one order line / one production order / one PO line |
| MES | production_operations, downtime_events | one operation / one downtime event |
| QMS | quality_events | one inspection/defect event |
| WMS | inventory_transactions, goods_receipts | one inventory movement / one receipt |
| Finance / Controlling export | standard_cost_history, manufacturing_cost_rates, exchange_rates | one effective-dated cost or rate |
| Shipping export | shipments, shipment_lines | one shipment / one shipped sales-order line |

Additional dimension/bridge entities may include suppliers, materials, BOM versions, production lines, calendars, and production-order allocations to sales-order lines.

### Data realism constraints

1. Preserve **primary/foreign key consistency** and define the grain of every table explicitly.
2. Support **one-to-many** cases: an order contains multiple lines, an order line can be fulfilled across multiple shipments, a production order has multiple operations, a purchase order line may have partial receipts.
3. Distinguish **requested, confirmed/promised, planned, actual** dates and document which one a KPI uses.
4. Preserve inventory flow balance where possible; distinguish quantity on hand at a point in time from flows during a period.
5. Make costs interpretable: standard vs actual, unit and currency, historical validity, and where applicable FX rate. Avoid fictitious 'profit' without an auditable cost definition.
6. Include controlled imperfections (missing values, duplicates, format drift) mostly in raw imports; document expected resolution rules.
7. Generate plausible relationships between supplier reliability, material availability, operations, quality, fulfillment and cost without encoding a simplistic 'root_cause' answer column.
8. Use deterministic generation (fixed seed / version) and verification tests. Save real synthetic outputs or a runnable generator for later reproducibility.

## 4. KPI candidates — definitions must be agreed before use

These are **candidates**, not confirmed measures or computed results.

| KPI | Provisional business interpretation | Critical question |
|---|---|---|
| On-Time Delivery Rate (OTD) | Share of committed order lines fully delivered by promised date | Line vs order level? How treat partial shipments? |
| Delivery Delay Days | Actual fulfillment date minus committed date | Calendar days or working days? Which deliveries count? |
| Production Plan Adherence | Actual completion vs production plan | Quantity, date, or both? |
| Downtime Hours | Valid line/operation downtime duration | Planned vs unplanned? Overlap and event duplicates? |
| Defect Rate | Defective units relative to inspected/produced units | Rework, repeated inspections, different denominators? |
| Supplier On-Time Rate | Accepted quantities/PO lines received by confirmed date | Partial receipts, early receipts, cancellation? |
| Inventory Coverage | Available inventory relative to usage rate | Date snapshot and consumption horizon? |
| Unit Manufacturing Cost | Material + labor (+ justified overhead) per good unit | Actual vs standard costs; allocation and currency? |
| Gross/Contribution Margin | Revenue less defined attributable costs | Which costs are included, discounts, returns, FX? |

Every KPI must eventually have an owner, precise formula, source tables, grain, filter treatment, date logic, limitations, and SQL-to-Power-BI validation where relevant.

## 5. BI deliverables

1. **Executive Overview** — high-level on-time delivery, operational and cost trends, priority risks, and context.
2. **Manufacturing Performance** — production execution, downtime, quality and trends by line/product/time.
3. **Supply Chain & Inventory** — supplier reliability, receipts, material availability, inventory signals.
4. **Orders & Profitability** — order fulfillment and carefully defined cost/margin analysis.

First usable milestone: a coherent model and **two** working pages. Final milestone: **four** pages, validated cross-filtering, documented KPIs, sensible UX, appropriate handling of limitations.

## 6. Ticket and review process

Each English ticket contains: `Ticket ID`, `Title`, `Requestor`, `Priority`, `Business context`, `Expected deliverables`, `Acceptance criteria`. Do **not** disclose a complete solution or pre-select technical functions for the junior analyst.

Review statuses: **Approved**, **Changes Requested**, **Rework Required**. Check technical correctness, row grain and aggregations, consistency against SQL, interpretation, readability and reproducibility. Progress only when approved and the junior agrees.

Typical workstream themes (not prescribed ticket order): onboarding and data audit; manufacturing and quality investigations; suppliers and inventory; costs and fulfillment; reporting layer; model and measures; report QA; change request; final presentation.

## 7. Milestones and acceptance

### M1 — Usable analytical core

- Database/import and basic data-quality checks reproducible.
- Valid SQL findings on key business questions, without unsupported causal claims.
- KPI definitions documented.
- Fit-for-purpose data model and two working Power BI pages.
- Evidence of reconciliation between SQL and Power BI.

### M2 — Portfolio-ready delivery

- Four report pages, a manageable number of meaningful metrics.
- Change request resolved and regression checks run.
- SQL scripts, data dictionary, KPI definitions, QA findings, screenshots, `.pbix` and business summary organized.
- Public English `README.md`, reproducible synthetic data or generator + import/setup instructions.
- Presentation and mock interview covering problem, choices, validation, findings and limitations.

## 8. Suggested GitHub structure (adjust as project evolves)

```text
manufacturing-bi-analytics/
├── README.md
├── data/
│   ├── sample/
│   └── generator/
├── sql/
│   ├── setup/
│   ├── quality/
│   ├── investigations/
│   └── reporting_views/
├── powerbi/
├── docs/
│   ├── data_dictionary.md
│   ├── data_model.md
│   ├── kpi_definitions.md
│   ├── data_quality.md
│   └── business_insights.md
├── screenshots/
└── .gitignore
```

`PROJECT_CONTEXT.md` and potentially `MASTER_PROMPT.md` may remain private working documents. If kept out of the public repository, add them to `.gitignore` **before first git add**. Do not publicly commit credentials, private data or claimed relationships with real employers.

## 9. Preconditions for first ticket

- [ ] Confirm available local PostgreSQL installation/connection, Power BI Desktop, VS Code and Git basics.
- [ ] Choose physical schema and grain for all core tables.
- [ ] Generate actual files/SQL scripts, not merely table descriptions.
- [ ] Verify counts, keys, referential integrity, chronology, quantities and known test cases.
- [ ] Prepare staged export delivery and clear import instructions.
- [ ] Confirm data volume can run on the user's computer; reduce volume if needed without degrading the analytical story.
- [ ] Only then start onboarding and ticket `MIS-001` following user approval.

## 10. Important status notice

**At the time of writing, this is a project specification, not an implemented database or completed report.** No generated KPI result, business conclusion, SQL script, dataset or PBIX should be represented as already delivered.
