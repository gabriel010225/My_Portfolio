{% macro clean_email(email_column) %}
    CASE 
        WHEN REGEXP_CONTAINS({{ email_column }}, r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        THEN REGEXP_REPLACE({{ email_column }}, r'\.\.', '.') 
        ELSE NULL 
    END
{% endmacro %}