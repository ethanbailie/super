{{
    config(
        materialized='table'
    )
}}

-- this is an example of how you might segment customers based on which vendor their first order was from
-- you could use this for something like retention analysis by vendor
-- queries like this would probably want to live within dbt instead of the visualization layer because you dont want a dashboard
--     to calculate these values every time they refresh, you would want the table to be generated and then the dashboard hits the table
with first_order as (
    select
        distinct
        customer_id,
        first_value(id) over (
            partition by customer_id 
            order by created_at asc
        ) as first_order
    from {{ source('raw', 'orders') }}
),

first_product as (
    select
        first_order.customer_id,
        order_lines.product_id,
    from first_order
    left join {{ source('raw', 'order_lines') }} as order_lines
        on first_order.first_order = order_lines.order_id
)

select
    customer_id,
    first_product.product_id,
    vendors.id as first_vendor_id
from first_product
left join {{ source('raw', 'vendors') }} as vendors
    on first_product.product_id = vendors.id
