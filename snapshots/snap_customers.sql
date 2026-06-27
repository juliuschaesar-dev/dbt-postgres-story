{% snapshot snap_customers %}

{{
    config(
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_name']
    )
}}

select
    customer_id,
    customer_name
from {{ ref('stg_customers') }}

{% endsnapshot %}
