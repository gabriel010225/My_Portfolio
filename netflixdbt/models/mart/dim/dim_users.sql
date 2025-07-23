{{ 
    config(
      materialized = 'table',
      schema = 'mart',
      database = 'NETFLIX'
    ) 
}}

WITH ratings AS (
  SELECT 
    DISTINCT user_id 
  FROM {{ ref('src_ratings') }}
),

tags AS (
  SELECT 
    DISTINCT user_id 
  FROM {{ ref('src_tags') }}
),

all_users AS (
  SELECT 
    * 
  FROM ratings
  UNION
  SELECT 
    * 
  FROM tags
)

SELECT 
    DISTINCT user_id
FROM all_users