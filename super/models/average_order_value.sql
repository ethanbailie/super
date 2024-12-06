{{ 
    config(
        materialized='table'
    ) 
}}

-- might not want to use the GMV as a basis as it includes refunded purchases
-- (for example, shopify excludes refunded purchases from their GMV calculation)
with total_value as (
    select 
        monthly_count.order_count,
        base.gross_merchandise_value,
        base.order_month
    from {{ ref('monthly_order_count') }} as monthly_count
    left join {{ ref('gross_merchandise_value') }} as base
        on monthly_count.order_month = base.order_month
)

select 
    trunc(gross_merchandise_value / order_count, 2) as average_order_value,
    order_month
from total_value