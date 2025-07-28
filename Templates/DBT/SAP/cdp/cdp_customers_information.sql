{{
    config(
        materialized='table',
        partition_by = {
            "field": "customer_create_date",
            "data_type": "date",
            "granularity": "month"
        },
        labels={'type': 'cdp', 'contains_pii': 'yes', 'category': 'production'},
    )
}}

SELECT DISTINCT
    cardcode AS customer_id,
    cardname AS customer_name,
    upper(address) AS customer_address,
    upper({{ clean_email('e_mail') }}) AS customer_email,
    upper({{ clean_phone('phone1') }}) AS customer_phone,
    upper(city) AS customer_city,
    upper(zipcode) AS customer_zipcode,
    CASE WHEN {{ clean_email('e_mail') }} IS null THEN 'No' ELSE 'Yes' END AS customer_has_email,
    cast(createdate AS DATE) AS customer_create_date,
    cast(updatedate AS DATE) AS customer_update_date,
    date_diff(current_date(), cast(createdate AS DATE), DAY) AS customer_age
FROM {{ source('sap', 'OCRD') }}
WHERE  {{ clean_email('e_mail') }}  IS NOT null