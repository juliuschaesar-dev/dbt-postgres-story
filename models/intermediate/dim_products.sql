with supply_costs as (
    select
        product_sku,
        count(*) as supply_count,
        sum(cost) as total_supply_cost,
        bool_or(perishable) as has_perishable_supply
    from {{ ref('stg_supplies') }}
    group by 1
)

select
    products.product_sku,
    products.product_name,
    products.product_type,
    products.price,
    products.description,
    coalesce(supply_costs.supply_count, 0) as supply_count,
    coalesce(supply_costs.total_supply_cost, 0) as total_supply_cost,
    coalesce(supply_costs.has_perishable_supply, false) as has_perishable_supply
from {{ ref('stg_products') }} as products
left join supply_costs
    on products.product_sku = supply_costs.product_sku
