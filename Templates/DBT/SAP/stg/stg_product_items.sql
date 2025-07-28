{{
    config(
        materialized='table',
        labels={'type': 'media_data', 'contains_pii': 'no', 'category': 'production'},
        tags=["real_time"]
    )
}}

SELECT DISTINCT
    itemcode AS item_code,
    itemname AS item_name,
    docentry AS item_doc_entry,
    cardcode AS item_carcode,
    sellitem AS item_sell_item,
    invntitem AS item_invnt_item,
    onhand AS item_on_hand,
    iscommited AS item_is_commited,
    onorder AS item_on_order
FROM {{ source('sap', 'OITM') }}
WHERE itemcode IS NOT null