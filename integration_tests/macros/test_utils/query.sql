{% macro fetch_scalar(sql) %}
  {% call statement("unit_test_query", fetch_result=True, auto_begin=False) %}
    {{ sql }}
  {% endcall %}

  {% set result = load_result("unit_test_query") %}

  {% if result is none or result["table"] is none or (result["table"].rows | length) == 0 %}
    {{ return(none) }}
  {% endif %}

  {{ return(result["table"].rows[0][0]) }}
{% endmacro %}
