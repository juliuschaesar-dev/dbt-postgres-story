with product_costs as (
    select
        coalesce(sum(total_supply_cost), 0) as total_supply_cost
    from {{ ref('dim_products') }}
),

supply_costs as (
    select
        coalesce(sum(cost), 0) as total_supply_cost
    from {{ ref('stg_supplies') }}
)

select
    product_costs.total_supply_cost as product_total_supply_cost,
    supply_costs.total_supply_cost as supply_total_supply_cost
from product_costs
cross join supply_costs
where product_costs.total_supply_cost <> supply_costs.total_supply_cost
