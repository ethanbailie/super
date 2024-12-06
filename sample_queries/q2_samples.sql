-- this file contains sample queries related to what someone might do on top of the cohort data models
-- the samples here dont cover the lifetime value model, but its very similar in use-case
-- for example, if you wanted to see value change monthly per cohort, the query would look very similar to sample query 2

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

-- gender split of cohorts
-- this example query shows how you might segment cohorts by gender, but ideally this would live in looker instead of a dbt model
select
    cohort_month,
    count(case when gender = 'M' then customer_id end) as male_count,
    count(case when gender = 'F' then customer_id end) as female_count,
    count(customer_id) as total_cohort_size
from dbt.cohorts
group by all
;
