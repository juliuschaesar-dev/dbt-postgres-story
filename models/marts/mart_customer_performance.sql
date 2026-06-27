select
    customer_id,
    customer_name,
    total_orders,
    first_ordered_at,
    last_ordered_at,
    lifetime_order_total,
    case
        when total_orders = 0 then 0
        else lifetime_order_total / total_orders
    end as average_order_value
from {{ ref('dim_customers') }}
