{# macros/generate_schema_name.sql #}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if node.resource_type == 'model' -%}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}
    {%- else -%}
        {{ default_schema }}
    {%- endif -%}

{%- endmacro %}