with monthly_orders as (
    select 
        distinct 
        customer_id, 
        date_trunc('month', created_at) as order_month
    from {{ source('raw', 'orders') }}
    where refunded_at is null
)

select
    count(customer_id) as active_customers,
    order_month
from monthly_orders
group by order_month