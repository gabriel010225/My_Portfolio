{{ 
    config(
      materialized = 'table',
      schema = 'landing',
      database = 'ECOMMERCE'
    ) 
}}

SELECT 
    *
FROM {{ source('ECOMMERCE', 'SHIPMENTS') }}