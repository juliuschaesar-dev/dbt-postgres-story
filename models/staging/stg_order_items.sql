select
    id as order_item_id,
    order_id,
    sku as product_sku
from {{ ref('raw_items') }}
