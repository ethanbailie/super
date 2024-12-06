{{
    config(
        materialized='table'
    )
}}

select
    id as customer_id,
    gender,
    date_trunc('month', created_at) as cohort_month,
from {{ source('raw', 'customers') }}
