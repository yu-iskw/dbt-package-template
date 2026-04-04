{% macro normalize_text(expression) -%}
  {%- set normalized_expression -%}
    nullif(trim(lower(cast({{ expression }} as {{ dbt.type_string() }}))), '')
  {%- endset -%}

  {{- return(normalized_expression | trim) -}}
{%- endmacro %}
