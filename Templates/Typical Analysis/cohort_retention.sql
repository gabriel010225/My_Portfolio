{{
    config(
        materialized='table',
        labels={'type': 'crm_database', 'contains_pie': 'no', 'category': 'analysis'}
    )
}}

with
    data_prep as (
        select distinct
            billing_address_country as country,
            cast(order_total_price as float64) as revenue,
            date(timestamp(order_created_at)) as date,
            customer_email,
            order_id,
            first_value(date(timestamp(order_created_at))) over (
                partition by billing_address_country, customer_email
                order by date(timestamp(order_created_at))
            ) as first_purchase_date,
        from {{ sales_table }}
        order by customer_email
    ),
    data_cohort as (
        select
            country,
            date,
            revenue,
            order_id as transactions,
            customer_email,
            date_diff(date, first_purchase_date, month) as month_order,
            date_trunc(first_purchase_date, month) as first_purchase
        from data_prep
    ),
    data_agg as (
        select
            country,
            first_purchase,
            month_order,
            sum(revenue) as revenue,
            count(distinct customer_email) as customers,
            count(distinct transactions) as transactions
        from data_cohort
        group by all
    )
select
    data_agg.country,
    data_agg.first_purchase,
    data_agg.month_order,
    data_agg.revenue,
    data_agg.customers,
    data_agg.transactions,
    first_value(customers) over (
        partition by data_agg.country, first_purchase
        order by month_order asc
    ) as cohort_customers,
    sum(revenue) over (
        partition by data_agg.country, first_purchase
        order by month_order asc
    ) as revenue_cumulative,
    sum(transactions) over (
        partition by data_agg.country, first_purchase
        order by month_order asc
    ) as transactions_cumulative
from data_agg
order by month_order asc