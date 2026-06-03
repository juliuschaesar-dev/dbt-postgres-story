select
    order_id,
    subtotal,
    tax_paid,
    order_total
from {{ ref('stg_orders') }}
where order_total <> subtotal + tax_paid
