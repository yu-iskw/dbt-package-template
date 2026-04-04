{% macro test_normalize_text_trims_and_lowercases() %}
  {% set sql %}
    select {{ dbt_package_template.normalize_text("'  Alice@example.COM  '") }} as value
  {% endset %}
  {% set result = run_query(sql) %}
  {% set actual = none if result is none or (result.rows | length) == 0 else result.rows[0][0] %}
  {% do dbt_unittest.assert_equals(actual, "alice@example.com") %}
{% endmacro %}

{% macro test_normalize_text_returns_none_for_blank_input() %}
  {% set sql %}
    select {{ dbt_package_template.normalize_text("'   '") }} as value
  {% endset %}
  {% set result = run_query(sql) %}
  {% set actual = none if result is none or (result.rows | length) == 0 else result.rows[0][0] %}
  {% do dbt_unittest.assert_is_none(actual) %}
{% endmacro %}

{% macro test_normalize_text_returns_none_for_null_input() %}
  {% set sql %}
    select {{ dbt_package_template.normalize_text("null") }} as value
  {% endset %}
  {% set result = run_query(sql) %}
  {% set actual = none if result is none or (result.rows | length) == 0 else result.rows[0][0] %}
  {% do dbt_unittest.assert_is_none(actual) %}
{% endmacro %}
