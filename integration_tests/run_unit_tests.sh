#!/usr/bin/env bash
set -euo pipefail

INTEGRATION_TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dbt_profiles_dir="${INTEGRATION_TESTS_DIR}/profiles"
dbt_target="${DBT_TARGET:-postgres}"
dbt_cmd="${DBT_CMD:-dbt}"

while (($# > 0)); do
  case "$1" in
    --profiles-dir)
      dbt_profiles_dir="${2:?}"
      shift 2
      ;;
    --target)
      dbt_target="${2:?}"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

cd "${INTEGRATION_TESTS_DIR}"
"${dbt_cmd}" deps --profiles-dir "${dbt_profiles_dir}" --target "${dbt_target}"
"${dbt_cmd}" run-operation test_macros \
  --profiles-dir "${dbt_profiles_dir}" \
  --target "${dbt_target}"
