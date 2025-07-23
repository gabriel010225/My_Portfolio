{{ 
    config(
      materialized = 'table',
      schema = 'landing',
      database = 'NETFLIX'
    ) 
}}

WITH raw_ratings AS (
  SELECT 
    * 
  FROM {{ source('NETFLIX', 'RATINGS_RAW') }}
)

SELECT
  "userId" AS user_id,
  "movieId" AS movie_id,
  "rating" AS rating,
  TO_TIMESTAMP_LTZ("timestamp") AS rating_timestamp
FROM raw_ratings