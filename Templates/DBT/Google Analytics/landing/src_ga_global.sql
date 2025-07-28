{{
  config(
    materialized = 'incremental',
    unique_key = 'ga_session_id',
    incremental_strategy = 'insert_overwrite',
    labels = {'type': 'google_analytics', 'category':'prod'},
    partition_by = {
      "field": "date",
      "data_type": "date",
      "granularity": "day"
    }
  )
}}

SELECT
    *
    , parse_date('%Y%m%d', event_date) AS date
    , concat(
        user_pseudo_id
        , (
            SELECT value.int_value FROM unnest(event_params)
            WHERE key = 'ga_session_id'
        )
    )                                  AS ga_session_id
    , (
        SELECT value.int_value FROM unnest(event_params)
        WHERE key = 'userId'
    )                                  AS ga_customer_id
FROM {{ source('ga4', 'events_*') }}
{% if is_incremental() %}
  where _table_suffix >= format_date('%Y%m%d',{{ var('start_date_incremental') }})
{% endif %}
