with product_mart as (
    select
        coalesce(sum(total_items_sold), 0) as total_items_sold,
        coalesce(sum(gross_revenue), 0) as gross_revenue
    from {{ ref('mart_product_performance') }}
),

fact_sales as (
    select
        count(*) as total_items_sold,
        coalesce(sum(item_price), 0) as gross_revenue
    from {{ ref('fact_order_items') }}
)

select
    product_mart.total_items_sold as mart_total_items_sold,
    fact_sales.total_items_sold as fact_total_items_sold,
    product_mart.gross_revenue as mart_gross_revenue,
    fact_sales.gross_revenue as fact_gross_revenue
from product_mart
cross join fact_sales
where product_mart.total_items_sold <> fact_sales.total_items_sold
    or product_mart.gross_revenue <> fact_sales.gross_revenue
