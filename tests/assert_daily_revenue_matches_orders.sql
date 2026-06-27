with mart_revenue as (
    select
        coalesce(sum(total_orders), 0) as total_orders,
        coalesce(sum(subtotal_revenue), 0) as subtotal_revenue,
        coalesce(sum(tax_revenue), 0) as tax_revenue,
        coalesce(sum(total_revenue), 0) as total_revenue
    from {{ ref('mart_daily_revenue') }}
),

order_revenue as (
    select
        count(*) as total_orders,
        coalesce(sum(subtotal), 0) as subtotal_revenue,
        coalesce(sum(tax_paid), 0) as tax_revenue,
        coalesce(sum(order_total), 0) as total_revenue
    from {{ ref('stg_orders') }}
)

select
    mart_revenue.total_orders as mart_total_orders,
    order_revenue.total_orders as order_total_orders,
    mart_revenue.subtotal_revenue as mart_subtotal_revenue,
    order_revenue.subtotal_revenue as order_subtotal_revenue,
    mart_revenue.tax_revenue as mart_tax_revenue,
    order_revenue.tax_revenue as order_tax_revenue,
    mart_revenue.total_revenue as mart_total_revenue,
    order_revenue.total_revenue as order_total_revenue
from mart_revenue
cross join order_revenue
where mart_revenue.total_orders <> order_revenue.total_orders
    or mart_revenue.subtotal_revenue <> order_revenue.subtotal_revenue
    or mart_revenue.tax_revenue <> order_revenue.tax_revenue
    or mart_revenue.total_revenue <> order_revenue.total_revenue
