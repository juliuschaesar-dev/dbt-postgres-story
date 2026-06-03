with fact_rows as (
    select count(*) as row_count
    from {{ ref('fact_order_items') }}
),

staging_rows as (
    select count(*) as row_count
    from {{ ref('stg_order_items') }}
)

select
    fact_rows.row_count as fact_row_count,
    staging_rows.row_count as staging_row_count
from fact_rows
cross join staging_rows
where fact_rows.row_count <> staging_rows.row_count
