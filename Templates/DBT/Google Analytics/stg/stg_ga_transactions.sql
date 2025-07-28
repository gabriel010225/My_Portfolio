{{
  config(
    materialized = 'table',
    labels = {'type': 'google_analytics', 'contains_pii': 'no', 'category':'staging'},
    partition_by = {
      "field": "date",
      "data_type": "date",
      "granularity": "day"
    }
  )
}}

SELECT DISTINCT
    user_pseudo_id
    , user_id
    , device.category
    , device.mobile_brand_name
    , device.mobile_model_name
    , device.operating_system
    , device.language
    , geo.country
    , geo.region
    , geo.city
    , traffic_source.name              AS traffic_name
    , traffic_source.medium            AS traffic_medium
    , traffic_source.source            AS traffic_source
    , ecommerce.total_item_quantity
    , ecommerce.purchase_revenue
    , ecommerce.unique_items
    , ecommerce.transaction_id
    , items.item_name
    , items.item_variant
    , items.item_category
    , items.price
    , items.quantity
    , items.item_revenue
    , parse_date('%Y%m%d', event_date) AS date
    , (
        SELECT value.int_value FROM unnest(event_params)
        WHERE key = 'customer_id'
    )                                  AS customer_id
FROM {{ ref('src_ga_global') }}, unnest(items) AS items
WHERE event_name = 'purchase'