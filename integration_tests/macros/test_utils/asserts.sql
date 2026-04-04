{% macro assert_equals(value, expected_value) %}
  {% if value != expected_value %}
    {% do exceptions.raise_compiler_error(
      "FAILED: value `" ~ value ~ "` does not equal expected value `" ~ expected_value ~ "`"
    ) %}
  {% endif %}
{% endmacro %}

{% macro assert_is_none(value) %}
  {% if value is not none %}
    {% do exceptions.raise_compiler_error(
      "FAILED: expected `none` but received `" ~ value ~ "`"
    ) %}
  {% endif %}
{% endmacro %}
