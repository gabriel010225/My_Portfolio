
{% macro get_databases() %}

    {% set query %}
        SHOW DATABASES;
    {% endset %}

    {% set results = run_query(query) %}

    {{ log("Databases accessible:", info=True) }}
    {% if execute %}
        {% for row in results.rows %}
            {{ log("- " ~ row.name, info=True) }}
        {% endfor %}
    {% endif %}

{% endmacro %}