USE ROLE ACCOUNTADMIN;

-- Create the `transform` role and assign it to ACCOUNTADMIN
CREATE ROLE IF NOT EXISTS TRANSFORM;
GRANT ROLE TRANSFORM TO ROLE ACCOUNTADMIN;

-- Create a default warehouse
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;

-- Create the `dbt` user and assign to the transform role
CREATE USER IF NOT EXISTS dbt
  PASSWORD=''
  LOGIN_NAME=''
  MUST_CHANGE_PASSWORD=FALSE
  DEFAULT_WAREHOUSE='COMPUTE_WH'
  DEFAULT_ROLE=TRANSFORM
  DEFAULT_NAMESPACE='NETFLIX.PUBLIC'
  COMMENT='DBT user used for data transformation';
ALTER USER dbt SET TYPE = LEGACY_SERVICE;
GRANT ROLE TRANSFORM TO USER dbt;

-- Create a database and NETFLIX.PUBLIC.GENOME_SCORES_RAW for the project
CREATE DATABASE IF NOT EXISTS NETFLIX;
CREATE SCHEMA IF NOT EXISTS NETFLIX.PUBLIC;

-- Grant permissions to the `transform` role
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;
GRANT ALL ON DATABASE NETFLIX TO ROLE TRANSFORM;
GRANT ALL ON ALL SCHEMAS IN DATABASE NETFLIX TO ROLE TRANSFORM;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE NETFLIX TO ROLE TRANSFORM;
GRANT ALL ON ALL TABLES IN SCHEMA NETFLIX.PUBLIC TO ROLE TRANSFORM;
GRANT ALL ON FUTURE TABLES IN SCHEMA NETFLIX.PUBLIC TO ROLE TRANSFORM;

-- Create storage integration s3
CREATE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = ''
  STORAGE_ALLOWED_LOCATIONS = ('s3://*');
USE ROLE ACCOUNTADMIN;

-- Create stage s3
CREATE STAGE my_s3_stage
  STORAGE_INTEGRATION = s3_int
  URL = 's3://*';

-- Set defaults
USE DATABASE NETFLIX;
USE SCHEMA NETFLIX.PUBLIC;

-- Load all data

-- genome-scores table
-- Method 1: define the schema then import tables
CREATE OR REPLACE TABLE raw_genome_scores (
  movieId INTEGER,
  tagId INTEGER,
  relevance FLOAT
);

COPY INTO raw_genome_scores
FROM '@my_s3_stage/genome-scores.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Method 2: infer the schema then import tables
-- Define the file format for infering the schema
CREATE OR REPLACE FILE FORMAT my_csv_format
  TYPE = csv
  PARSE_HEADER = true -- Take the first row as header(column name)
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Create the table structure by calling the file format defined
CREATE OR REPLACE TABLE genome_scores_raw
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE(
        INFER_SCHEMA(
            LOCATION => '@my_s3_stage/genome-scores.csv',
            FILE_FORMAT => 'my_csv_format'
        )
    )
);

-- Copy the table by using the normal csv format and skipping the header(column name)
COPY INTO genome_scores_raw
FROM @my_s3_stage/genome-scores.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"'); -- Config "PARSE_HEADER" is only allowed while defining the schema, so here we can't use my_csv_format directly

SHOW TABLES LIKE 'genome_scores_raw';

-- genome-tags table
CREATE OR REPLACE TABLE genome_tags_raw
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE(
        INFER_SCHEMA(
            LOCATION => '@my_s3_stage/genome-tags.csv',
            FILE_FORMAT => 'my_csv_format'
        )
    )
);

COPY INTO genome_tags_raw
FROM @my_s3_stage/genome-tags.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- links table
CREATE OR REPLACE TABLE links_raw
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE(
        INFER_SCHEMA(
            LOCATION => '@my_s3_stage/links.csv',
            FILE_FORMAT => 'my_csv_format'
        )
    )
);

COPY INTO links_raw
FROM @my_s3_stage/links.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- movies table
CREATE OR REPLACE TABLE movies_raw
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE(
        INFER_SCHEMA(
            LOCATION => '@my_s3_stage/movies.csv',
            FILE_FORMAT => 'my_csv_format'
        )
    )
);

COPY INTO movies_raw
FROM @my_s3_stage/movies.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- ratings table
CREATE OR REPLACE TABLE ratings_raw
USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE(
        INFER_SCHEMA(
            LOCATION => '@my_s3_stage/ratings.csv',
            FILE_FORMAT => 'my_csv_format'
        )
    )
);

COPY INTO ratings_raw
FROM @my_s3_stage/ratings.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- tags table
CREATE OR REPLACE TABLE tags_raw (
  "userId" INTEGER,
  "movieId" INTEGER,
  "tag" STRING,
  "timestamp" BIGINT
);

COPY INTO tags_raw
FROM '@my_s3_stage/tags.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'CONTINUE';