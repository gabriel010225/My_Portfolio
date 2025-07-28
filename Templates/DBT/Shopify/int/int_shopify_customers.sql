{{
  config(
    materialized = 'view',
    labels = {'type': 'shopify', 'contains_pii': 'yes', 'category':'prod'}
  )
}}

WITH orders_line AS (
    SELECT
        customer_email
        , billing_address_country
        , order_id_shopify
        , item_quantity
        , order_total_price
        , order_created_at
        , row_number() OVER (PARTITION BY order_id_shopify) AS rank
    FROM {{ sales_table }}
)

, rfm AS (
    SELECT
        customer_email
        , count(DISTINCT order_id_shopify)                          AS nb_cdes
        , sum(item_quantity)                                        AS total_quantity
        , date_diff(current_date(), max(order_created_at), DAY)     AS recency
        , count(DISTINCT order_id_shopify)                          AS frequency
        , sum(CASE WHEN rank = 1 THEN order_total_price ELSE 0 END) AS monetary
        , min(order_created_at)                                     AS first_order_date
        , max(order_created_at)                                     AS last_order_date
    FROM orders_line
    GROUP BY ALL
)

, rfm_segmentation AS (
    SELECT
        *
        , ntile(5) OVER (
            ORDER BY recency DESC
        ) AS recency_score
        , ntile(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score
        , ntile(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score
    FROM rfm
)

SELECT
    *
    , concat(recency_score, frequency_score, monetary_score) AS rfm_segment
FROM rfm_segmentation