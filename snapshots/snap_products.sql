{% snapshot snap_products %}

{{
    config(
        unique_key='product_sku',
        strategy='check',
        check_cols=[
            'product_name',
            'product_type',
            'price',
            'description'
        ]
    )
}}

select
    product_sku,
    product_name,
    product_type,
    price,
    description
from {{ ref('stg_products') }}

{% endsnapshot %}
