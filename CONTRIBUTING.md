# Contributing to dbt_package_template

Thank you for your interest in contributing to dbt_package_template!

## Before you start

This repository is a starter template for new dbt packages.
It is intentionally small, so contributors should keep changes focused and preserve the local-first workflow.

## How to develop

### Directory structure

- `macros/`: package macros that ship with the template
- `integration_tests/`: example dbt project for unit and integration tests
- `docs/`: supporting documentation for package authors and agents

### How to set up the development environment

Install the integration test environment from the repository root:

```shell
make setup-integration-tests
```

### How to run unit testing

Unit tests execute dbt macros directly with `dbt run-operation` on both supported adapters and both standard dbt-core lines: `dbt-core-1-10` and `dbt-core-1-11`.

```shell
make run-unit-tests
```

The repository also exposes a separate Fusion lane:

```shell
make run-unit-tests-fusion
```

That target installs the Fusion runtime into the nox virtual environment and runs the Fusion unit lane on Postgres and DuckDB.

### How to implement unit tests

- Add or update package macros under `macros/`.
- Add matching macro tests under `integration_tests/macros/tests/`, **mirroring** the directory layout under `macros/` (for example `macros/example/foo.sql` → `integration_tests/macros/tests/example/test_foo.sql`).
- Use [dbt-unittest](https://github.com/yu-iskw/dbt-unittest) (`dbt_unittest.*`) for assertions.
- Call package macros directly in SQL (for example `{{ dbt_package_template.normalize_text("'x'") }}`) and use dbt’s `run_query` when you need to execute that SQL and assert on the result.
- Register new test macros from `integration_tests/macros/tests/test_macros.sql` (the only test macro file that stays at the `tests/` root).

### How to run integration testing

Integration tests run the example project under `integration_tests/` on Postgres and DuckDB for both standard dbt-core lines: `dbt-core-1-10` and `dbt-core-1-11`.

```shell
make run-integration-tests
```

Fusion integration coverage is exposed separately:

```shell
make run-integration-tests-fusion
```

That target installs the Fusion runtime into the nox virtual environment and runs the Fusion integration lane on Postgres and DuckDB.

### Local Postgres

The Postgres target uses a Docker Compose managed container during local test runs.
Contributors need Docker Engine and Docker Compose v2 available locally.

The dbt profile still connects with these defaults:

- host: `localhost`
- port: `5432`
- user: `postgres`
- password: `postgres`
- database: `dbt_package_template`
- schema: `dbt_package_template`

You can override any of them with `DBT_POSTGRES_*` environment variables.

### Starter conventions

- Keep starter content copyable for new package authors.
- Prefer cross-adapter SQL in starter macros and tests.
- Implement public package macros with `adapter.dispatch` and `macro_namespace: 'dbt_package_template'` so downstream projects can override implementations (see `macros/CLAUDE.md`).
- Update `README.md` and `docs/` when public behavior changes.
