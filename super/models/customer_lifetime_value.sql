{{
    config(
        materialized='table'
    )
}}

with customer_value as (
    select 
        customer_id,
        date_trunc('month', created_at) as order_month,
        sum(total_price) as customer_total
    from {{ source('raw', 'orders') }}
    where refunded_at is null
    group by all
)

select
    cohorts.cohort_month,
    customer_value.order_month,
    trunc(sum(customer_value.customer_total) / count(cohorts.customer_id), 2) as monthly_value,
    sum(monthly_value) over (
        partition by cohort_month
        order by order_month
    ) as cohort_customer_lifetime_value
from {{ ref('cohorts') }} as cohorts
inner join customer_value
    on cohorts.customer_id = customer_value.customer_id
group by all
