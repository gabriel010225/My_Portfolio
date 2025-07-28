{{
    config(
        materialized='view',
        labels = {'type': 'shopify', 'contains_pii': 'oui', 'category':'prod'}
    )
}}

WITH orders_raw AS (
    SELECT
    -- orders informations
        cast(created_at AS DATE)                                                  AS order_created_at
        , extract(HOUR FROM created_at)                                           AS hour
        , cast(extract(HOUR FROM created_at) AS INT64) + 1                        AS actual_hour
        , date(parse_timestamp('%Y-%m-%dT%H:%M:%S%Ez', processed_at))             AS order_processed_at
        , cancelled_at                                                            AS order_cancelled_at
        , updated_at                                                              AS order_updated_at
        , cast(order_number AS STRING)                                            AS order_id_shopify
        , name                                                                    AS order_name_shopify
        , source_name                                                             AS order_source_name
        , total_price                                                             AS order_total_price
        , subtotal_price                                                          AS order_subtotal_price
        , confirmed                                                               AS order_confirmed
        , cancel_reason                                                           AS order_cancel_reason
        , current_total_tax                                                       AS order_tax
        , current_total_price                                                     AS order_total_amount
        , current_subtotal_price                                                  AS order_subtotal_amount
        , json_value(total_shipping_price_set.shop_money.amount)                  AS order_shipping_amount
        , safe_cast(json_value(total_discounts_set.shop_money.amount) AS FLOAT64) AS order_discount_amount
        , cast(json_extract_scalar(total_price_set.shop_money.amount) AS FLOAT64) AS order_total_price_set
        , CASE
            WHEN current_total_price = 0 AND total_price > 0
                THEN 'Total Refund'
            WHEN total_price > current_total_price AND current_total_price != 0
                THEN 'Partial Refund'
            ELSE 'No Refund'
        END                                                                       AS order_refund
        , cast(total_price AS INT64)
        - cast(current_total_price AS INT64)                                      AS order_refund_total
        -- customer info
        , customer_locale                                                         AS customer_locale_language
        , contact_email                                                           AS customer_email
        , email                                                                   AS customer_email_v1
        , json_value(billing_address.name)                                        AS billing_address_name
        , json_value(billing_address.country)                                     AS billing_address_country
        , json_value(billing_address.city)                                        AS billing_address_city
        , json_value(billing_address.longitude)                                   AS billing_address_longitude
        , json_value(billing_address.country_code)                                AS billing_address_country_code
        , json_value(billing_address.latitude)                                    AS billing_address_latitude
        , json_value(billing_address.address2)                                    AS billing_address_address2
        , json_value(billing_address.address1)                                    AS billing_address_address1
        , json_value(billing_address.province_code)                               AS billing_address_province_code
        , json_value(billing_address.phone)                                       AS billing_address_phone
        , json_value(billing_address.zip)                                         AS billing_address_zip
        , CASE
            WHEN
                rank()
                    OVER (
                        PARTITION BY email
                        ORDER BY cast(created_at AS DATE) ASC
                    )
                = 1
                THEN 'New Customer'
            ELSE 'Returning Customer'
        END                                                                       AS customer_new_or_returning
        , json_value(customer.tags)                                               AS customers_tags
        , location_id
        , tags
        , user_id
        , source_name
        , json_extract_array(line_items)                                          AS items
    FROM {{ source ('shopify', 'orders') }}
)

SELECT
    * EXCEPT (items)
    -- itmes   
    , json_extract_scalar(items, '$.name')                         AS item_name
    , json_extract_scalar(items, '$.product_id')                   AS item_product_id
    , safe_cast(json_extract_scalar(items, '$.price') AS FLOAT64)  AS item_unit_price
    , json_extract_scalar(items, '$.sku')                          AS item_sku
    , safe_cast(json_extract_scalar(items, '$.quantity') AS INT64) AS item_quantity
FROM orders_raw, unnest(items) AS items