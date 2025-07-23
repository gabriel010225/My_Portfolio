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
  FROM {{ source('NETFLIX', 'GENOME_SCORES_RAW') }}
)

SELECT
  "movieId" AS movie_id,
  "tagId" AS tag_id,
  "relevance" AS relevance
FROM raw_data