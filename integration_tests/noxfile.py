from pathlib import Path
import os

import nox

nox.options.sessions = ["dev_unit_tests", "dev_integration_tests"]
nox.options.default_venv_backend = "uv"

PYTHON_VERSIONS = ["3.10", "3.11", "3.12"]
LOCAL_DBT_GROUPS = ["dbt-core-1-10", "dbt-core-1-11"]
SETUP_DBT_GROUPS = ["dbt-core-1-10", "dbt-core-1-11", "dbt-fusion"]
ADAPTERS = ["postgres", "duckdb"]
INTEGRATION_TESTS_DIR = Path(__file__).parent.resolve()
FUSION_GROUP = "dbt-fusion"
FUSION_BINARY_NAME = "dbt"
FUSION_VERSION = os.environ.get("DBT_FUSION_VERSION", "")


def install_dependencies(session, uv_group):
    session.install(".", "--group", uv_group)
    if uv_group == FUSION_GROUP:
        session.run(
            "bash",
            "scripts/ensure_fusion_backend.sh",
            "--install-runtime",
            "--verify-runtime",
            env={
                "DBT_FUSION_BIN_DIR": session.bin,
                "DBT_FUSION_BINARY_NAME": FUSION_BINARY_NAME,
                "DBT_FUSION_VERSION": FUSION_VERSION,
            },
            external=True,
        )


def get_dbt_command(session, uv_group):
    if uv_group == FUSION_GROUP:
        return str(Path(session.bin) / FUSION_BINARY_NAME)
    return "dbt"


def build_env(session, uv_group, adapter, dbt_cmd):
    env = dict(os.environ)
    env.update(session.env)
    env["DBT_CMD"] = dbt_cmd

    if adapter == "duckdb" and "DBT_DUCKDB_PATH" not in env:
        duckdb_dir = INTEGRATION_TESTS_DIR / "target"
        duckdb_dir.mkdir(exist_ok=True)
        py_ver = session.python.replace(".", "")
        uv_slug = uv_group.replace("-", "_")
        env["DBT_DUCKDB_PATH"] = str(
            duckdb_dir / f"dbt_package_template_{uv_slug}_{py_ver}.duckdb"
        )

    return env


def run_deps(session, dbt_cmd, adapter, env):
    session.run(
        dbt_cmd,
        "deps",
        "--profiles-dir",
        "profiles",
        "--target",
        adapter,
        env=env,
        external=True,
    )


def run_dbt_shell_script(session, uv_group, adapter, script_name):
    """Install deps, then run a bash harness script (unit or integration tests)."""
    install_dependencies(session, uv_group)
    dbt_cmd = get_dbt_command(session, uv_group)
    env = build_env(session, uv_group, adapter, dbt_cmd)
    run_deps(session, dbt_cmd, adapter, env)
    session.run(
        "bash",
        script_name,
        "--target",
        adapter,
        env=env,
        external=True,
    )


@nox.session(python="3.12")
def dev_unit_tests(session):
    """Run the starter macro unit tests quickly on Postgres."""
    unit_tests(session, "dbt-core-1-10", "postgres")


@nox.session(python="3.12")
def dev_integration_tests(session):
    """Run the starter integration tests quickly on Postgres."""
    integration_tests(session, "dbt-core-1-10", "postgres")


@nox.session(python="3.12")
def dev_unit_tests_fusion(session):
    """Run the starter macro unit tests quickly through dbt Fusion."""
    fusion_unit_tests(session)


@nox.session(python="3.12")
def dev_integration_tests_fusion(session):
    """Run the starter integration tests quickly through dbt Fusion."""
    fusion_integration_tests(session)


@nox.session(python=PYTHON_VERSIONS)
@nox.parametrize("uv_group", LOCAL_DBT_GROUPS)
@nox.parametrize("adapter", ADAPTERS)
def unit_tests(session, uv_group, adapter):
    """Run macro unit tests for a dbt-core line and adapter."""
    run_dbt_shell_script(session, uv_group, adapter, "run_unit_tests.sh")


@nox.session(python=PYTHON_VERSIONS)
@nox.parametrize("uv_group", LOCAL_DBT_GROUPS)
@nox.parametrize("adapter", ADAPTERS)
def integration_tests(session, uv_group, adapter):
    """Run dbt build for the example project for a dbt-core line and adapter."""
    run_dbt_shell_script(session, uv_group, adapter, "run_integration_tests.sh")


@nox.session(python=PYTHON_VERSIONS)
@nox.parametrize("uv_group", SETUP_DBT_GROUPS)
def setup_dbt_env(session, uv_group):
    """Install dbt dependencies for a version group and print the bin path."""
    install_dependencies(session, uv_group)
    dbt_cmd = get_dbt_command(session, uv_group)
    print(f"DBT_CMD={dbt_cmd}")
    print(f"BIN_PATH={session.bin}")


@nox.session(python=PYTHON_VERSIONS)
def fusion_unit_tests(session):
    """Run real Fusion unit tests on Postgres and DuckDB."""
    for adapter in ADAPTERS:
        unit_tests(session, FUSION_GROUP, adapter)


@nox.session(python=PYTHON_VERSIONS)
def fusion_integration_tests(session):
    """Run real Fusion integration tests on Postgres and DuckDB."""
    for adapter in ADAPTERS:
        integration_tests(session, FUSION_GROUP, adapter)
