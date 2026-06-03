select
    id as supply_id,
    name as supply_name,
    cost,
    perishable,
    sku as product_sku
from {{ ref('raw_supplies') }}
