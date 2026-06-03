select
    sku as product_sku,
    name as product_name,
    type as product_type,
    price,
    description
from {{ ref('raw_products') }}
