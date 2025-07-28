{{
  config(
    materialized = 'incremental',
    incremental_strategy='insert_overwrite',
    labels = {'type': 'google_analytics', 'contains_pii': 'no', 'category':'prod'},
    partition_by = {
        "field": "date",
        "data_type": "date",
        "granularity": "day"
    }
  )
}}

WITH
data_consolidation AS (
    SELECT
        date
        , coalesce(session_traffic_source_last_click.cross_channel_campaign.default_channel_group, 'Unassigned') AS ga_channel_grouping
        , device.category                                                                                        AS ga_device_category
        , geo.country                                                                                            AS ga_counry
        , geo.region                                                                                             AS ga_region
        , geo.city                                                                                               AS ga_city
        , count(DISTINCT user_pseudo_id)                                                                         AS ga_total_users
        , count(
            DISTINCT concat(
                user_pseudo_id
                , '_'
                , (
                    SELECT value.int_value
                    FROM unnest(event_params)
                    WHERE key = 'ga_session_id'
                )
            )
        )                                                                                                        AS sessions
        , count(
            DISTINCT CASE
                WHEN event_name = 'page_view' THEN ga_session_id
            END
        )                                                                                                        AS ga_page_view
        , count(
            DISTINCT CASE
                WHEN event_name = 'view_item_list' THEN ga_session_id
            END
        )                                                                                                        AS ga_view_item_list
        , count(
            DISTINCT CASE WHEN event_name = 'view_item' THEN ga_session_id END
        )                                                                                                        AS ga_view_item
        , count(
            DISTINCT CASE WHEN event_name = 'select_item' THEN ga_session_id END
        )                                                                                                        AS ga_select_item
        , count(
            DISTINCT CASE WHEN event_name = 'add_to_cart' THEN ga_session_id END
        )                                                                                                        AS ga_add_to_cart
        , count(
            DISTINCT CASE WHEN event_name = 'view_cart' THEN ga_session_id END
        )                                                                                                        AS view_cart
        , count(
            DISTINCT CASE
                WHEN event_name = 'begin_checkout' THEN ga_session_id
            END
        )                                                                                                        AS ga_begin_checkout
        , count(
            DISTINCT CASE
                WHEN event_name = 'add_payment_info' THEN ga_session_id
            END
        )                                                                                                        AS add_payment_info
        , count(
            DISTINCT CASE
                WHEN event_name = 'add_shipping_info' THEN ga_session_id
            END
        )                                                                                                        AS add_shipping_info
        , count(
            DISTINCT CASE WHEN event_name = 'purchase' THEN ga_session_id END
        )                                                                                                        AS ga_purchase

    FROM {{ ref('src_ga_global') }}
    {# where date between current_date() - 30 and current_date() #}
    GROUP BY ALL
)

SELECT *
FROM data_consolidation
{% if is_incremental() %} WHERE date > (SELECT max(date) FROM {{ this }})
{% else %}
  where date >= '2024-01-01'
{% endif %}