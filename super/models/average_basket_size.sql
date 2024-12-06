{{ 
    config(
        materialized='table'
    ) 
}}

with total_basket_size as (
    select 
        lines.order_id,
        sum(lines.quantity) as quantity,
        date_trunc('month', orders.created_at) as order_month
    from {{ source('raw', 'order_lines') }} as lines
    left join {{ source('raw', 'orders') }} as orders
        on lines.order_id = orders.id
    group by all
),

calculations as (
    select
        sum(quantity) as total,
        count(order_id) as orders,
        total_basket_size.order_month
    from total_basket_size
    left join {{ ref('monthly_order_count') }} as order_count
        on total_basket_size.order_month = order_count.order_month
    group by total_basket_size.order_month
)

select
    total / orders as average_basket_size,
    order_month
from calculations