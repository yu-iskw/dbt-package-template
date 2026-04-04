# dbt-package-template

This repository is a local-first starter template for new dbt packages.

<!-- toc -->

- [What This Template Includes](#what-this-template-includes)
- [Requirements](#requirements)
- [Supported warehouses](#supported-warehouses)
- [Repository Layout](#repository-layout)
- [Starter Macro](#starter-macro)
  - [`normalize_text`](#normalize_text)
- [Testing](#testing)
- [Codex](#codex)

<!-- tocstop -->

## What This Template Includes

- A guided starter macro under [`macros/`](./macros)
- A local integration test project under [`integration_tests/`](./integration_tests)
- Unit and integration test commands that run against `postgres` and `duckdb`
- Standard dbt-core coverage for `dbt-core-1-10` and `dbt-core-1-11`
- A restored `dbt Fusion` lane that runs on the same `postgres` and `duckdb` contract
- Shared agent configuration for Codex and Claude-based workflows

## Requirements

- dbt-core 1.10 and 1.11 for the bundled standard test harness
- Docker with Compose support for the Postgres test target
- DuckDB for the embedded DuckDB test target

## Supported warehouses

The template executes tests against:

- Postgres
- DuckDB

## Repository Layout

- [`macros/`](./macros): package macros that ship with the template
- [`integration_tests/`](./integration_tests): example dbt project used for unit and integration tests
- [`docs/`](./docs): starter documentation for contributors and agents

## Starter Macro

### `normalize_text`

`normalize_text(expression)` returns a SQL expression that:

- casts the value to the adapter string type
- lowercases it
- trims surrounding whitespace
- converts empty strings to `null`

**Usage:**

```sql
select
  {{ dbt_package_template.normalize_text("customer_name") }} as normalized_name
from {{ ref("raw_users") }}
```

See [`integration_tests/models/example/stg_users.sql`](./integration_tests/models/example/stg_users.sql) for a complete example.

## Testing

Use the integration test project for all package checks:

```bash
make setup-integration-tests
make run-unit-tests
make run-integration-tests
make run-fusion-tests
```

The unit-test harness runs dbt macros directly with `dbt run-operation`.
The integration harness runs `dbt build` against the sample project on both adapters.
Postgres-backed local tests start and stop a Docker Compose managed Postgres container automatically.

The repository has two testing lanes:

- Local adapter lane: runnable on `postgres` and `duckdb` for `dbt-core-1-10` and `dbt-core-1-11`
- Fusion lane: runnable on the same `postgres` and `duckdb` profiles, with the Fusion runtime installed into each nox virtual environment

Set `DBT_FUSION_VERSION` to pin a specific Fusion build during local runs or in CI.

Fusion was originally removed during the migration from a BigQuery-oriented package harness to the new local `postgres`/`duckdb` contract. It is now restored as a real execution lane on that same adapter contract.

For a starter walkthrough, see [docs/starter_walkthrough.md](./docs/starter_walkthrough.md).

## Codex

This repository includes shared Codex configuration in [`.codex/config.toml`](./.codex/config.toml) and project instructions in [`AGENTS.md`](./AGENTS.md).

These files provide a safe default sandbox, approval behavior, editor links for Cursor, and repository-specific guidance for testing and documentation updates.

The checked-in top-level configuration remains the default. For Codex CLI usage, the repository also defines two opt-in profiles:

- `fast`: `gpt-5.4` with low reasoning effort for smaller, iterative tasks
- `deep`: `gpt-5.4` with high reasoning effort for planning, review, and more complex changes

The repository also includes two read-only review subagents for Codex:

- `reviewer`: reviews dbt macros, SQL generation paths, workflows, and config changes for regressions and correctness risks
- `test_gap_checker`: reviews changes for missing unit, integration, and workflow coverage

Shared agent skills should be authored under [`.claude/skills`](./.claude/skills). [`.agents/skills`](./.agents/skills) is a compatibility symlink for other agent tooling and should not contain separate copies.

Example usage:

```bash
codex --profile fast
codex --profile deep
```
