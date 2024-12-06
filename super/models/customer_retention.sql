{{
    config(
        materialized='table'
    )
}}

with cohort_sizes as (
    select
        cohort_month,
        count(*) as total_customers
    from {{ ref('cohorts') }}
    group by cohort_month
),

customer_activity as (
    select
        cohorts.cohort_month,
        date_trunc('month', orders.created_at) as activity_month,
        orders.customer_id
    from {{ source('raw', 'orders') }} as orders
    left join {{ ref('cohorts') }} as cohorts 
        on orders.customer_id = cohorts.customer_id
    where orders.refunded_at is null
),

retention as (
    select
        cohort_month,
        activity_month,
        count(distinct customer_id) as active_customers
    from customer_activity
    group by cohort_month, activity_month
)

select
    retention.cohort_month,
    retention.activity_month,
    trunc(retention.active_customers / cohort_sizes.total_customers, 2) as customer_retention
from retention
left join cohort_sizes
    on retention.cohort_month = cohort_sizes.cohort_month
