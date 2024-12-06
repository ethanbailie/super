{{ 
    config(
        materialized='table'
    ) 
}}

select
    count(*) as order_count,
    date_trunc('month', created_at) as order_month
from source.orders
where refunded_at is null
group by order_month