with sales as (
    select
        product_sku,
        count(order_item_id) as total_items_sold,
        count(distinct order_id) as total_orders,
        sum(item_price) as gross_revenue
    from {{ ref('fact_order_items') }}
    group by 1
)

select
    products.product_sku,
    products.product_name,
    products.product_type,
    products.price,
    products.supply_count,
    products.total_supply_cost,
    products.has_perishable_supply,
    coalesce(sales.total_items_sold, 0) as total_items_sold,
    coalesce(sales.total_orders, 0) as total_orders,
    coalesce(sales.gross_revenue, 0) as gross_revenue
from {{ ref('dim_products') }} as products
left join sales
    on products.product_sku = sales.product_sku
