# DBT PostgreSQL Story

DBT Core learning project with PostgreSQL, Docker, seeds, models, tests, snapshots, and custom materializations.

## Data Flow

```text
CSV seeds
  -> staging models
  -> intermediate fact and dimension models
  -> analytics marts
```

## Project Structure

```text
.
|-- seeds/                 # Raw CSV datasets loaded with dbt seed
|-- models/
|   |-- staging/           # Cleaned source-level views
|   |-- intermediate/      # Reusable fact and dimension tables
|   `-- marts/             # Analytics tables for reporting
|-- snapshots/             # Snapshot definitions for historical tracking
|-- macros/
|   |-- materializations/  # Custom materializations
|   |-- generate_schema_name.sql
|   `-- generic_tests.sql
|-- tests/                 # Custom data tests
|-- analyses/              # Ad hoc analysis SQL files
|-- docs/                  # Project documentation assets
|-- Dockerfile             # dbt Core + dbt-postgres image
|-- docker-compose.yml     # Local Postgres and dbt services
|-- dbt_project.yml        # DBT project configuration
|-- profiles.yml           # DBT profile used inside Docker
`-- requirements.txt       # Python package dependencies for the dbt image
```

Generated runtime folders such as `target/`, `logs/`, and `dbt_packages/` are ignored by Git.

## Prerequisites

- Docker Desktop
- Docker Compose

No local Python or DBT installation is required. DBT runs inside the Docker container.

## Getting Started

Build the DBT image:

```powershell
docker compose build
```

Start Postgres:

```powershell
docker compose up -d postgres
```

Check the DBT connection:

```powershell
docker compose run --rm dbt debug
```

Load the CSV files into Postgres:

```powershell
docker compose run --rm dbt seed --full-refresh
```

Build the full project:

```powershell
docker compose run --rm dbt build
```

## Useful DBT Commands

Run only staging models:

```powershell
docker compose run --rm dbt run --select path:models/staging
```

Run only intermediate models:

```powershell
docker compose run --rm dbt run --select path:models/intermediate
```

Run only mart models:

```powershell
docker compose run --rm dbt run --select path:models/marts
```

Run a model with truncate-insert materialization:

```sql
{{ config(materialized='truncate_insert') }}
```

This custom materialization creates the target table on the first run, then truncates and reloads it on later runs.

Run a model with delete-insert by date materialization:

```sql
{{ config(
    materialized='delete_insert_by_date',
    date_column='ordered_date'
) }}
```

Then pass the date range at runtime:

```powershell
docker compose run --rm dbt run --select mart_daily_revenue --vars "{start_date: '2016-09-01', end_date: '2016-10-01'}"
```

This custom materialization deletes existing target rows where `date_column >= start_date` and `date_column < end_date`, then inserts rows from the model query for the same date range.

Run tests only:

```powershell
docker compose run --rm dbt test
```

Run snapshots:

```powershell
docker compose run --rm dbt snapshot
```

Snapshot definitions are stored in `snapshots/`. The snapshot tables are created in Postgres under the `snapshots` schema:

- `snapshots.snap_customers`
- `snapshots.snap_products`

Generate and serve DBT documentation:

```powershell
docker compose run --rm dbt docs generate
```

```powershell
docker compose run --rm --service-ports dbt docs serve --host 0.0.0.0 --port 8080
```

Open `http://localhost:8080` in your browser.

## Data Layers

### Seeds

Seeds are loaded into the `staging` schema as raw tables:

- `raw_customers`
- `raw_orders`
- `raw_items`
- `raw_products`
- `raw_stores`
- `raw_supplies`

### Staging

Staging models are source-level cleanup views in the same `staging` schema:

- `stg_customers`
- `stg_orders`
- `stg_order_items`
- `stg_products`
- `stg_stores`
- `stg_supplies`

### Intermediate

Intermediate models are reusable fact and dimension tables in the `intermediate` schema:

- `fact_order_items`
- `dim_customers`
- `dim_products`

### Marts

Mart models are analytics-ready reporting tables in the `marts` schema:

- `mart_daily_revenue`
- `mart_customer_performance`
- `mart_product_performance`

### Snapshots

Snapshot definitions live in the `snapshots/` folder and track historical changes with DBT snapshot metadata columns such as `dbt_valid_from` and `dbt_valid_to`.

- `snap_customers`
- `snap_products`

## Testing

The project includes generic schema tests for:

- Primary keys and required fields
- Relationships across seeds, staging, and intermediate models
- Accepted product type values
- Non-negative revenue, cost, count, and tax fields
- Positive product and item prices
- Unique column combinations, such as daily store revenue and supply-product pairs

It also includes custom data tests for business logic and reconciliation:

- `assert_order_total_equals_subtotal_plus_tax`
- `assert_fact_order_items_matches_staging_count`
- `assert_daily_revenue_matches_orders`
- `assert_customer_performance_matches_orders`
- `assert_product_performance_matches_fact`
- `assert_product_supply_cost_matches_supplies`

Run all tests with:

```powershell
docker compose run --rm dbt test
```

## Learning Exercises

1. Add `dim_stores` in the intermediate layer from `stg_stores`.
2. Create `mart_monthly_revenue` from `mart_daily_revenue`.
3. Add accepted value tests for product types.
4. Add a mart that ranks customers by lifetime revenue.
5. Generate DBT docs and inspect the lineage graph.
