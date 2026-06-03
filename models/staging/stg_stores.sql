select
    id as store_id,
    name as store_name,
    opened_at,
    cast(opened_at as date) as opened_date,
    tax_rate
from {{ ref('raw_stores') }}
