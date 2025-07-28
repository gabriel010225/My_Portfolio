{{
    config(
        materialized='view',
        labels = {'type': 'shopify', 'contains_pii': 'oui', 'category':'prod'}
    )
}}

SELECT
    email
    , phone
    , tags
    , state
    , last_name
    , first_name
    , created_at
    , json_value(default_address.country) AS country
FROM {{ source ('shopify', 'customers') }}