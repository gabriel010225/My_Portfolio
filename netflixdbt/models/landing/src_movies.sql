{{ 
    config(
      materialized = 'table',
      schema = 'landing',
      database = 'NETFLIX'
    ) 
}}

WITH raw_movies AS (
    SELECT 
        * 
    FROM {{ source('NETFLIX', 'MOVIES_RAW') }}
)
SELECT 
    "movieId" AS movie_id,
    "title" AS title,
    "genres" AS genres
FROM raw_movies