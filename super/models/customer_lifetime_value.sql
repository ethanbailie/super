{{
    config(
        materialized='table'
    )
}}

with customer_value as (
    select 
        customer_id,
        sum(total_price) as customer_total
    from {{ source('raw', 'orders') }}
    where refunded_at is null
    group by customer_id
)

select
    cohorts.cohort_month,
    trunc(sum(customer_value.customer_total) / count(cohorts.customer_id), 2) as cohort_customer_lifetime_value
from {{ ref('cohorts') }} as cohorts
left join customer_value
    on cohorts.customer_id = customer_value.customer_id
group by cohorts.cohort_month
