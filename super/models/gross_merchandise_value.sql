{{
    config(
        materialized='table'
    )
}}

select
    sum(total_price) as gross_merchandise_value,
    date_trunc('month', created_at) as order_month
from {{ source('raw', 'orders') }}
group by order_month
