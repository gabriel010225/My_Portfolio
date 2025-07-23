{{ 
    config(
      materialized = 'table',
      schema = 'landing',
      database = 'NETFLIX'
    ) 
}}

WITH raw_links AS (
  SELECT 
    * 
  FROM {{ source('NETFLIX', 'LINKS_RAW') }}
)

SELECT
  "movieId" AS movie_id,
  "imdbId" AS imdb_id,
  "tmdbId" AS tmdb_id
FROM raw_links