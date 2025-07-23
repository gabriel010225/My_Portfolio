{{ 
    config(
      materialized = 'table',
      schema = 'landing',
      database = 'NETFLIX'
    ) 
}}

WITH raw_data AS (
  SELECT 
    * 
  FROM {{ source('NETFLIX', 'GENOME_TAGS_RAW') }}
)

SELECT
  "tagId" AS tag_id,
  "tag" AS tag
FROM raw_data