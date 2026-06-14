# DBT + Databricks Medallion Architecture Project

## Project Overview
End-to-end modern data engineering pipeline implementing 
Medallion Architecture using dbt Core and Databricks. 
Built as hands-on implementation of dbt concepts including 
models, tests, seeds, macros, snapshots and SCD Type 2.

---

## Tech Stack
- **Transformation:** dbt Core 1.11
- **Data Warehouse:** Databricks (Serverless)
- **Storage Format:** Delta Lake
- **Language:** SQL + Jinja
- **Version Control:** Git + GitHub
- **Adapter:** dbt-databricks 1.12

---

## Architecture

```
Source Layer (Databricks)
        ↓
Bronze Layer (Raw models)
        ↓
Silver Layer (Cleaned + Joined)
        ↓
Gold Layer (Aggregated + Deduplicated)
        ↓
Snapshot Layer (SCD Type 2)
```

---

## Project Structure

```
DBT_DBT/
├── models/
│   ├── Bronze/          # Raw source models
│   │   ├── bronze_sales.sql
│   │   ├── bronze_customer.sql
│   │   ├── bronze_store.sql
│   │   ├── bronze_returns.sql
│   │   ├── bronze_date.sql
│   │   ├── bronze_product.sql
│   │   └── properties.yml
│   ├── Silver/          # Cleaned + joined models
│   │   └── sales_info.sql (CTE based joins)
│   ├── Gold/            # Aggregated + deduplicated
│   │   └── source_gold_items.sql
│   └── Source/
│       └── sources.yml
├── snapshots/           # SCD Type 2
│   └── gold_items.sql
├── seeds/               # Reference data
│   └── lookup.csv
├── macros/              # Custom reusable logic
│   ├── multiply.sql
│   ├── generate_schema_name.sql
│   └── generic_non_negative.sql
├── tests/               # Custom data tests
│   └── generic/
│       └── non_negative_test.sql
└── dbt_project.yml
```

---

## Key Concepts Implemented

### 1. Medallion Architecture
- **Bronze:** Raw data ingested from Databricks source tables
- **Silver:** Cleaned, joined and enriched data using CTEs
- **Gold:** Aggregated and deduplicated data for consumption

### 2. dbt Models
- Table, view materializations across layers
- CTE-based multi-table joins (fact + dimensions)
- Source references using `{{ source() }}`
- Model references using `{{ ref() }}`

### 3. SCD Type 2 via Snapshots
- Tracks historical changes to items dimension
- Timestamp strategy using `updateDate` column
- Active records identified by `dbt_valid_to = 9999-12-31`
- Full change history preserved per unique id

### 4. Data Quality Testing
- Built-in tests: `unique`, `not_null`, `accepted_values`
- Custom generic test: `non_negative` (reusable across models)
- Singular tests for business rule validation
- Tests run automatically via `dbt build`

### 5. Macros
- `multiply(col1, col2)` — reusable column multiplication
- `generate_schema_name` — custom schema naming for
   clean medallion layer separation (bronze/silver/gold)
- Generic test macros for data quality

### 6. Seeds
- `lookup.csv` — customer reference data loaded via `dbt seed`
- Column types enforced via `dbt_project.yml`

### 7. Schema Management
- Custom `generate_schema_name` macro for clean layer naming
- Without macro: `source_bronze` (default dbt behaviour)
- With macro: `bronze`, `silver`, `gold` (clean names) ✅

---

## Data Flow

```
7 Source Tables (Databricks)
        ↓  {{ source() }}
6 Bronze Models
  fact_sales, fact_returns,
  dim_store, dim_customer,
  dim_date, dim_product
        ↓  {{ ref() }}
Silver Model (sales_info)
  CTE joins: fact + 2 dimensions
  quantity * unit_price = total_amount
        ↓  {{ ref() }}
Gold Model (source_gold_items)
  ROW_NUMBER() deduplication
  Latest record per id
        ↓
Snapshot (gold_items)
  SCD Type 2 history table
  dbt_valid_from / dbt_valid_to
```

---

## How to Run

```bash
# Install dependencies
pip install dbt-databricks

# Test connection
dbt debug

# Install packages
dbt deps

# Load seed data
dbt seed

# Run all models
dbt run

# Run tests
dbt test

# Run snapshots
dbt snapshot

# Run everything in correct order
dbt build

# Generate documentation
dbt docs generate
dbt docs serve

# Full refresh incremental models
dbt run --full-refresh
```

---

## dbt build Results

```
✅ 6 Bronze models created
✅ 1 Silver model created  
✅ 1 Gold model created
✅ 1 Seed loaded (3 rows)
✅ 1 Snapshot created (SCD Type 2)
✅ 5 Data tests passed
✅ 2 Custom macro tests passed
```

---

## Key Learnings

- How `generate_schema_name` macro controls 
  schema naming in medallion architecture
- Why CTEs are preferred over raw joins in dbt
- Difference between `source()` and `ref()` 
  and when to use each
- How `dbt snapshot` implements SCD Type 2 
  automatically using timestamp strategy
- Why `dbt build` is preferred over running 
  models, tests, snapshots separately
- How `--full-refresh` reprocesses all 
  historical data in incremental models

---

## Author
Priya Rai
Data Engineer | Accenture
Skills: dbt • Databricks • PySpark • ADF • DataStage
