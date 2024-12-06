-- this file contains sample queries related to what someone might do on top of the data models
-- in this case, I provided samples for average order value, but you can do the same for the other metrics

-- what is the average order value for the current month?
select * 
from dbt.average_order_value
where order_month = date_trunc('month', current_date)
;

-- what is the average order value for the previous month?
select * 
from dbt.average_order_value
where order_month = date_trunc('month', current_date) - interval '1 month'
;

-- what is the change in average order value from the previous month to the current month?
select 
    average_order_value,
    lag(average_order_value) over (order by order_month asc) as prev_average_order_value,
    average_order_value - prev_average_order_value as difference,
    order_month
from dbt.average_order_value
;

-- what is the average over the last 3 complete months? 
-- (average of the averages rather than taking all the orders from those months and calculating the average)
select 
    sum(average_order_value) / 3 as average_of_averages,
    order_month
from dbt.average_order_value
where order_month >= date_trunc('month', current_date) - interval '3 month'
group by order_month
;

