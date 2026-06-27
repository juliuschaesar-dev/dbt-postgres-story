with customer_mart as (
    select
        coalesce(sum(total_orders), 0) as total_orders,
        coalesce(sum(lifetime_order_total), 0) as lifetime_order_total
    from {{ ref('mart_customer_performance') }}
),

orders as (
    select
        count(*) as total_orders,
        coalesce(sum(order_total), 0) as lifetime_order_total
    from {{ ref('stg_orders') }}
)

select
    customer_mart.total_orders as mart_total_orders,
    orders.total_orders as order_total_orders,
    customer_mart.lifetime_order_total as mart_lifetime_order_total,
    orders.lifetime_order_total as order_lifetime_order_total
from customer_mart
cross join orders
where customer_mart.total_orders <> orders.total_orders
    or customer_mart.lifetime_order_total <> orders.lifetime_order_total
