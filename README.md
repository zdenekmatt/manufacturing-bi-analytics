# Manufacturing Operations & BI Analytics

**A SQL and Power BI portfolio project based on a fictional manufacturing company.**

**Status:** Work in progress  
**Main tools:** PostgreSQL 18, SQL, Python, VS Code  
**Next stage:** Power BI reports

## About the project

Moravia Industrial Systems is a **fictional** company that makes electrical components in Brno, Czechia.

In this project, I work as a Junior BI Analyst. I explore business data, write SQL queries, check data quality, and explain my findings in English.

The main business question is:

**What can the data tell us about production delays, customer deliveries, and operating costs?**

I want to understand business problems using data. I also want to learn how to explain results and their limits.

All data is synthetic. This project does **not** use information from ABB or any other real company.

## Data and tools

The dataset was created by a **Python generator developed with help from ChatGPT**. The script uses a fixed random seed, so the same dataset can be created again.

| Item | Details |
| --- | --- |
| Dataset version | 1.0.0 |
| Total records | 261,846 |
| Tables and exports | 22 |
| Sales data period | October 2024 to September 2026 |
| Inventory opening date | 2024-09-30 |
| Last operational snapshot | 2026-10-31 |
| Database | PostgreSQL 18 (`manufacturing_bi`) |
| Data generation | Python (`data/generator/`) |
| Reporting | Power BI (planned) |

The data covers customers, sales orders, production, quality, downtime, inventory, purchasing, shipping, and costs.

## How I use AI in this project

I use **ChatGPT as a learning partner and a Senior BI Analyst mentor**. AI is part of my workflow, but it does not replace my own learning and decisions.

**ChatGPT helps me with:**

- Designing the fictional company and its business problems.
- Preparing the Python script that generates synthetic data.
- Creating realistic tasks for a Junior BI Analyst.
- Reviewing my SQL queries and explaining mistakes.
- Improving the English and structure of my reports.

**My own work includes:**

- Writing and testing most SQL queries in PostgreSQL.
- Exploring tables and checking the results.
- Finding useful information and explaining what it means.
- Correcting mistakes and choosing how to solve tasks.
- Building this portfolio step by step.

Some SQL examples, validation queries, and final document edits were provided with AI support. I review the results and keep a record of what was completed and checked.

**The dataset is AI-assisted, not real company data.** ChatGPT helped design the generator; the actual records are produced by a repeatable Python script. My goal is to use AI responsibly while developing my own technical and analytical skills.

## My SQL investigations

Each ticket includes a business question, SQL queries, data checks, and findings.

| Ticket | Topic | Status |
| --- | --- | --- |
| MIS-001 | Business Data Exploration | Approved |
| MIS-002 | Production Data Exploration | Approved |
| MIS-003 | Production Hours & Workload | Tasks reviewed; final SQL file check pending |
| MIS-004 | Production Timeliness & Workload | Approved |
| MIS-005 | Production Quality | Tasks reviewed; final SQL file check pending |
| MIS-006 | Production Downtime | Approved |
| MIS-007 | Inventory Movements & Material Flow | Approved |

I use SQL skills such as `JOIN`, `GROUP BY`, `CASE`, `CTE`, `LEFT JOIN`, `COALESCE`, and data validation.

## Selected findings

These are examples from my SQL analysis. They are **not official company KPIs**.

- **Production:** 15,210 production orders were completed. Of these, 5,479 were completed after the planned date.
- **Downtime:** There were 10,397 recorded downtime events, with 938,540 total downtime minutes.
- **Inventory:** There were 91,718 inventory transactions. A total of 57,578 transactions were related to raw materials.

These results describe the dataset. They do not prove why customer orders may be late or why costs may change.

## Repository structure

- `tickets/` — business tasks and requirements
- `sql/investigations/` — SQL queries for each ticket
- `sql/setup/` — database setup and data import
- `sql/quality/` — data quality checks
- `docs/` — findings, data dictionary, and project notes
- `data/generator/` — Python scripts to generate and validate synthetic data

Generated CSV files in `data/releases/` are **not** stored in this public repository. You can create them using the steps below.

## How to run the project (Windows)

**Requirements:** Python, PostgreSQL, and a terminal such as the one in VS Code. I used PostgreSQL 18.

1. Download or clone this repository and open its folder in VS Code.
2. Open a PowerShell terminal in the main project folder.
3. Generate the synthetic CSV files:

   ```powershell
   python data/generator/generate.py
   ```

4. Validate the generated files:

   ```powershell
   python data/generator/validate.py
   ```

   The expected result is `PASS`, with `261846` total records.

5. In pgAdmin, create an **empty** PostgreSQL database named `manufacturing_bi`.
6. Run these commands from the main project folder:

   ```powershell
   & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -X -v ON_ERROR_STOP=1 -U postgres -d manufacturing_bi -f sql/setup/00_create_schema.sql
   & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -X -v ON_ERROR_STOP=1 -U postgres -d manufacturing_bi -f sql/setup/01_load_data.psql
   & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -X -v ON_ERROR_STOP=1 -U postgres -d manufacturing_bi -f sql/quality/01_post_import_checks.sql
   ```

   If PostgreSQL is installed in another folder, change the path to `psql.exe`.

7. The final check should show:

   `PASS: import baseline and business-key integrity assertions`

**Important:** The import script uses `psql` commands. Do not run it in the pgAdmin Query Tool. Do not import the data again into tables that already contain data.

## Data quality and limits

- This is training data, not data from a real business.
- Some source files include planned data problems for practice.
- One sales order line can be linked to more than one production or shipment record. I check the data level before calculating totals.
- Inventory balances are calculated from recorded movements. They are not confirmed physical stock counts.
- A connection between two results does not prove that one caused the other.
- Power BI dashboards and final business KPIs are **not finished yet**.

More information is available in the [data dictionary](docs/data_dictionary.md), [data model](docs/data_model.md), and [KPI decision log](docs/kpi_decisions.md).

## Next steps

I plan to continue with SQL investigations, define clear business KPIs, create a Power BI data model, and build dashboards for production and supply chain analysis.

This repository will grow as I complete more tasks.
