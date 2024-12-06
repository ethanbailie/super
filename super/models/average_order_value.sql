{{ 
    config(
        materialized='table'
    ) 
}}

with base as (
    select 
        sum(total_price) as monthly_total,
        date_trunc('month', created_at) as order_month
    from {{ source('raw', 'orders') }}
    group by order_month
),

total_value as (
    select 
        monthly_count.order_count,
        base.monthly_total,
        base.order_month
    from {{ ref('monthly_order_count') }} as monthly_count
    left join base
        on monthly_count.order_month = base.order_month
)

select 
    trunc(monthly_total / order_count, 2) as average_order_value,
    order_month
from total_value