{{ 
    config(
      materialized = 'table',
      schema = 'landing',
      database = 'NETFLIX'
    ) 
}}

WITH raw_tags AS (
  SELECT 
    * 
  FROM {{ source('NETFLIX', 'TAGS_RAW') }}
)

SELECT
  "userId" AS user_id,
  "movieId" AS movie_id,
  "tag" AS tag,
  TO_TIMESTAMP_LTZ("timestamp") AS tag_timestamp
FROM raw_tags