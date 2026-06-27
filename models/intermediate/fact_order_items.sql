select
    order_items.order_item_id,
    orders.order_id,
    orders.ordered_at,
    orders.ordered_date,
    orders.customer_id,
    customers.customer_name,
    orders.store_id,
    stores.store_name,
    products.product_sku,
    products.product_name,
    products.product_type,
    products.price as item_price,
    orders.subtotal,
    orders.tax_paid,
    orders.order_total
from {{ ref('stg_order_items') }} as order_items
left join {{ ref('stg_orders') }} as orders
    on order_items.order_id = orders.order_id
left join {{ ref('stg_customers') }} as customers
    on orders.customer_id = customers.customer_id
left join {{ ref('stg_stores') }} as stores
    on orders.store_id = stores.store_id
left join {{ ref('stg_products') }} as products
    on order_items.product_sku = products.product_sku
