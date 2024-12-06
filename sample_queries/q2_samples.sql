-- this file contains sample queries related to what someone might do on top of the cohort data models

-- what is the average retention rate for the current month across all previous cohorts?
select 
    activity_month,
    sum(customer_retention) / count(cohort_month)
from dbt.customer_retention
where cohort_month < date_trunc('month', current_date)
    and activity_month = date_trunc('month', current_date)
group by activity_month
;

-- what is the retention rate difference between the current month and the previous month for all cohorts?
select
    cohort_month,
    activity_month,
    customer_retention,
    lag(customer_retention) over (
        partition by cohort_month 
        order by activity_month asc
    ) as prev_customer_retention,
    customer_retention - prev_customer_retention as difference
from dbt.customer_retention
;