select
    id as order_id,
    customer as customer_id,
    ordered_at,
    cast(ordered_at as date) as ordered_date,
    store_id,
    subtotal,
    tax_paid,
    order_total
from {{ ref('raw_orders') }}
