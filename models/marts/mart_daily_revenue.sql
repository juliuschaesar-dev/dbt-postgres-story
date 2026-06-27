with order_items as (
    select *
    from {{ ref('fact_order_items') }}
),

orders as (
    select distinct
        order_id,
        ordered_date,
        store_id,
        store_name,
        subtotal,
        tax_paid,
        order_total
    from order_items
),

daily_order_revenue as (
    select
        ordered_date,
        store_id,
        store_name,
        count(order_id) as total_orders,
        sum(subtotal) as subtotal_revenue,
        sum(tax_paid) as tax_revenue,
        sum(order_total) as total_revenue
    from orders
    group by 1, 2, 3
),

daily_item_sales as (
    select
        ordered_date,
        store_id,
        count(order_item_id) as total_items_sold,
        sum(item_price) as gross_item_revenue
    from order_items
    group by 1, 2
)

select
    daily_order_revenue.ordered_date,
    daily_order_revenue.store_id,
    daily_order_revenue.store_name,
    daily_order_revenue.total_orders,
    daily_item_sales.total_items_sold,
    daily_item_sales.gross_item_revenue,
    daily_order_revenue.subtotal_revenue,
    daily_order_revenue.tax_revenue,
    daily_order_revenue.total_revenue
from daily_order_revenue
left join daily_item_sales
    on daily_order_revenue.ordered_date = daily_item_sales.ordered_date
    and daily_order_revenue.store_id = daily_item_sales.store_id
