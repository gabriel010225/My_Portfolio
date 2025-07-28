{{
  config(
    materialized = 'incremental',
    unique_key = 'item_id',
    incremental_strategy = 'insert_overwrite',
    labels = {'type': 'google_analytics', 'category':'prod'},
    partition_by = {
      "field": "date",
      "data_type": "date",
      "granularity": "day"
    }
  )
}}

select distinct

    (
        select value.string_value
        from unnest(event_params)
        where key = 'item_name'
    ) as item_name,

    (
        select value.string_value
        from unnest(event_params)
        where key = 'item_id'
    ) as item_id,
    (
        select value.string_value
        from unnest(event_params)
        where key = 'item_deal'
    ) as item_deal,
    (
        select value.int_value from unnest(event_params) where key = 'item_size'
    ) as item_size,
    (
        select value.int_value
        from unnest(event_params)
        where key = 'item_size_range'
    ) as item_size_range,
    (
        select value.string_value
        from unnest(event_params)
        where key = 'item_discount_ratio'
    ) as item_discount_ratio,
    (
        select value.string_value
        from unnest(event_params)
        where key = 'item_photo_type'
    ) as item_photo_type,
    (
        select value.int_value
        from unnest(event_params)
        where key = 'item_picture'
    ) as item_picture,
    (
        select value.string_value
        from unnest(event_params)
        where key = 'item_threads'
    ) as item_threads,
    (
        select value.string_value
        from unnest(event_params)
        where key = 'item_season'
    ) as item_season,
    (
        select value.string_value
        from unnest(event_params)
        where key = 'item_stock_status'
    ) as item_stock_status

from {{ ref('src_ga_global') }}
where event_name = 'view_item'