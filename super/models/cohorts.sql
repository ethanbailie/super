{{
    config(
        materialized='view'
    )
}}

select
    id as customer_id,
    date_trunc('month', created_at) as cohort_month
from {{ source('raw', 'customers') }}
