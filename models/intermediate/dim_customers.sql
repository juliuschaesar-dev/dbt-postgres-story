with order_metrics as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        min(ordered_at) as first_ordered_at,
        max(ordered_at) as last_ordered_at,
        sum(order_total) as lifetime_order_total
    from {{ ref('stg_orders') }}
    group by 1
)

select
    customers.customer_id,
    customers.customer_name,
    coalesce(order_metrics.total_orders, 0) as total_orders,
    order_metrics.first_ordered_at,
    order_metrics.last_ordered_at,
    coalesce(order_metrics.lifetime_order_total, 0) as lifetime_order_total
from {{ ref('stg_customers') }} as customers
left join order_metrics
    on customers.customer_id = order_metrics.customer_id
