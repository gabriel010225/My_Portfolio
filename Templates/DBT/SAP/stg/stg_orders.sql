{{
    config(
        materialized='table',
        labels={'type': 'media_data', 'contains_pii': 'no', 'category': 'production'},
        tags=["real_time"]
    )
}}

SELECT
    cast(
        docduedate AS DATE
    ) AS bl_date,
    {# cast(docdate as date) as bl_date, #}
    docentry AS bl_id,
    docnum AS bl_num,
    cardcode AS customer_id,
    cardname AS customer_name,
    address AS customer_address,
    shiptocode AS customer_ship_to_code,
    doctotal AS bl_revenue_ttc,
    vatsum AS bl_vat,
    vatsumsy AS bl_vat_sy,
    totalexpns AS bl_expense,
    paidtodate AS bl_paid,
    cast(grosprofit AS FLOAT64) AS bl_gross_profit,
    flags AS bl_flags,
    canceled AS bl_status,
    coalesce(cast(doctotal AS FLOAT64), 0)
    - coalesce(cast(vatsum AS FLOAT64), 0) AS bl_revenue_ht,
    coalesce(cast(doctotal AS FLOAT64), 0)
    - coalesce(cast(vatsum AS FLOAT64), 0)
    - coalesce(cast(totalexpns AS FLOAT64), 0) AS bl_revenue_net,
    date_trunc(cast(docduedate AS DATE), MONTH) AS bl_month,
    date_trunc(cast(docduedate AS DATE), YEAR) AS bl_year,
    date_trunc(cast(docduedate AS DATE), WEEK) AS bl_week,
    {# date_trunc(cast(docdate as date), month) as bl_month,
    date_trunc(cast(docdate as date), year) as bl_year,
    date_trunc(cast(docdate as date), week) as bl_week, #}
    bpchcode AS bl_brand,
    first_value(cast(docduedate AS DATE))
        OVER (
            PARTITION BY cardcode ORDER BY docduedate ASC
        )
        AS first_transaction_date,
    {# first_value(cast(docdate as date)) over (
        partition by cardcode order by docdate asc
    ) as first_transaction_date, #}
    CASE
        WHEN
            cast(docduedate AS DATE) = first_value(cast(docduedate AS DATE)) OVER (
                PARTITION BY cardcode ORDER BY docduedate ASC
            )
            THEN 'New Customer'
        ELSE 'Returning Customer'
    END AS is_first_purchase
    {# case
        when
            cast(docdate as date) = first_value(cast(docdate as date)) over (
                partition by cardcode order by docdate asc
            )
        then "New Customer"
        else "Returning Customer"
    end as is_first_purchase #}
FROM {{ source('sap', 'ORDR') }}
WHERE canceled = 'N'
ORDER BY bl_date DESC