-- macros/get_schema_objects.sql

{% macro get_schema_objects(database_name, schema_name) %}

    {% set query %}
        SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
        FROM {{ database_name }}.INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = '{{ schema_name }}'
        ORDER BY TABLE_NAME;
    {% endset %}

    {% set results = run_query(query) %}

    {{ log("Objects in " ~ database_name ~ "." ~ schema_name ~ ":", info=True) }}
    {% if execute %}
        {% for row in results.rows %}
            {{ log("- " ~ row.TABLE_NAME ~ " (" ~ row.TABLE_TYPE ~ ")", info=True) }}
        {% endfor %}
    {% endif %}

{% endmacro %}