# super

### Question 1:
The key models to set up Beth to track these KPIs are as follows:
- **monthly_order_count**
    - base model for counting orders by month to be used downstream
- **gross_merchandise_value**
    - this model would be used to track the gross merchandise value each month
    - this is the sum of all orders for a given month, without removing any refunded purchases
- **active_customers**
    - this model would be used to track the number of active customers each month
    - an active customer is defined as any customer who has made a purchase in the given month
- **average_order_value**
    - this model would be used to track the average order value each month
    - this is the gross merchandise value divided by the number of orders
    - a caveat here is that you want to filter out refunded orders, then you need create the GMV table without refunded orders as a cte for this model
- **average_basket_size**
    - this model would be used to track the average basket size each month
    - this is the sum of quantity in order lines per order divided by the number of orders per month
- **sample queries are in the sample_queries/q1_samples.sql file**

### Question 2:
- **cohorts**   
    - this model is basically just a split of customers into when they first ordered by month for downstream analysis
- **customer_retention**
    - this model would be used to track the retention of customers across cohorts
    - basically this takes customer activity and joins it to cohorts to track how many active customers there are per cohort per month
    - this doesn't reuse the customer_activity model because it needs to count customers per cohort instead of just per month
- **customer_lifetime_value**
    - this model would be used to track the lifetime value of customers across cohorts
    - this sums amount spent per customer, then sums them by cohort and divides by number of customers in the cohort to get the average
    - also utilizes a running total to get the cumulative average lifetime value by cohort
- **first_vendor**
    - this model would be used to track the first vendor of a customer
    - this is an example of how a customer could be segmented by a first purchase attribute
    - this is a model because its utilizes CTEs and more processing than I would like to have in any looker instance (basically due to performance of the dashboard)
- **sample queries are in the sample_queries/q2_samples.sql file**
    - here there is a cohort gender split sample query that is quite simple and would live somewhere in looker for visualization
- **how I would handle segmentation:**
    - The way I think of segmentation is that you want to identify where code might repeat, such as customer cohorts, as well as complexity of the query
        - in this case I added gender to the cohorts model to make it easy for people downstream to segment based on that, but you could also add other attributes like location, age, etc.
            - cohorts is used many times, you make it a model so that you dont need to repeat yourself over and over
            - this also makes it very easy once in Looker to segment on gender for example, and visualize that
        - in the case of performing more complex queries like first_vendor, you would want that to live in dbt because if you put it in looker the dashboard needs to calculate everything every time
            - this is kind of the balancing point of performance vs work efficiency
                - many things are faster to have in dbt, but you dont want to take an eternity writing out every single case you could have for segmentation there, so sometimes you need to make a compromise where dbt will act as the basis for some modeling within your visualization layer. An example of this would be just making the first_purchase model in dbt instead of going all the way, and then using that as a launching point for joining into other tables for more information on the customer's purchase and background.
    
### Question 3:
- **things I would add:**
    - for a subscription model, theres two paths you can take
        - you can have a new table altogether that has all subscription order data
        - you can add a column to the existing orders table that designates it as a subscription order or add in a column to the order lines table to indicate if that specific item was purchased through a subscription
    - in either case, you need to adjust your base models to either join in the subscription data if it is in a new table, or adjust the columns from the orders table to include the subscription flag
        - this is especially important to include for base models that are reused frequently, such as order count, as you can then do things like customer retention by subscription vs non-subscription without needing to change too much
    - you would also need to check if anything in your existing models needs to be adjusted to account for this (such as the average basket size overall, or average basket size by subscription vs non-subscription)
        - in the example of average basket size, altering the order count table helps a lot because now we can just grab the counts from there as new columns instead of having to process the data again here, and then you can create further derivations from there

### Additional notes:
- this is a sample of what the repo could look like, but it misses some things I would otherwise add into a production environment
    - there are no tests
        - source freshness, unique keys, duplicate rows, nulls, etc...
    - primary keys in a prod environment for things like cohort would be created through an md5 hash
    - sorting of the models so that they arent all just in one folder
    - 'in the middle' models not directly queried would be configured to materialize as views or ephemeral instead of as tables, it was just easier to write everything quickly for this case study by doing it this way because I could easily query it on my own as needed


### Database structure if you want to run this yourself:
- super_db
    - source
        - orders
        - order_lines
        - vendors
        - customers
        - products
    - dbt
        - active_customers
        - average_basket_size
        - average_order_value
        - cohorts
        - customer_lifetime_value
        - customer_retention
        - first_vendor
        - gross_merchandise_value
        - monthly_order_count

