{% macro test_normalize_text_trims_and_lowercases() %}
  {% set sql %}
    select {{ dbt_package_template.normalize_text("'  Alice@example.COM  '") }} as value
  {% endset %}

  {% set actual = dbt_package_template_integration_tests.fetch_scalar(sql) %}
  {% do dbt_package_template_integration_tests.assert_equals(actual, "alice@example.com") %}
{% endmacro %}

{% macro test_normalize_text_returns_none_for_blank_input() %}
  {% set sql %}
    select {{ dbt_package_template.normalize_text("'   '") }} as value
  {% endset %}

  {% set actual = dbt_package_template_integration_tests.fetch_scalar(sql) %}
  {% do dbt_package_template_integration_tests.assert_is_none(actual) %}
{% endmacro %}

{% macro test_normalize_text_returns_none_for_null_input() %}
  {% set sql %}
    select {{ dbt_package_template.normalize_text("null") }} as value
  {% endset %}

  {% set actual = dbt_package_template_integration_tests.fetch_scalar(sql) %}
  {% do dbt_package_template_integration_tests.assert_is_none(actual) %}
{% endmacro %}
