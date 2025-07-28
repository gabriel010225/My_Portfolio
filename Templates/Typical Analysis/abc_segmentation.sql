-- Used as custom query in Looker Studio
-- Parameters defined in dashboard:
-- @START_DATE: start date of date range
-- @END_DATE: end date of date range
-- @percentage_a: the percentage threshold of segment A, typically 80
-- @percentage_b: the percentage threshold of segment B, typically 90

with data_group as (
    select 
        item_name,
  		item_sku,
        sum(sales_quantity) as total_quantity,
        sum(net_sales) as net_sales,
    from {{ sales_table }}
    where
      date between parse_date("%Y%m%d", @START_DATE) and parse_date("%Y%m%d", @END_DATE)
    group by all
),
 data_agg as (
    select
        item_name,
      	item_sku,
  		total_quantity,
        net_sales,
        current_date() as date,
        round(sum(net_sales) over (), 2) as global_net_sales,
        round(
            sum(
                net_sales
            ) over (partition by current_date() order by net_sales desc),
            2
        ) as running_sum,
        round(
            sum(
                net_sales
            ) over (partition by current_date() order by net_sales desc)
        / sum(net_sales) over () *100, 2) as rn_pct
    from data_group
    order by net_sales desc
)
select
    item_name,
    item_sku,
	total_quantity,
    net_sales,
    global_net_sales,
	round(net_sales/global_net_sales*100, 2) as pct,
    running_sum,
    rn_pct,
    case
        when rn_pct <= @percentage_a then 'A'
        when rn_pct > @percentage_a and rn_pct <= @percentage_b then 'B'
        when rn_pct > @percentage_b then 'C'
    end as segment_abc
from data_agg