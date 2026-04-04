.PHONY: setup clean test \
	postgres-up postgres-wait postgres-down postgres-logs \
	run-unit-tests run-unit-tests-postgres run-unit-tests-duckdb \
	run-integration-tests run-integration-tests-postgres run-integration-tests-duckdb \
	run-unit-tests-fusion run-integration-tests-fusion run-fusion-tests

setup:
	uv sync

clean:
	rm -f ./*.duckdb
	rm -rf target logs dbt_packages

postgres-up:
	docker compose -f docker-compose.postgres.yml up -d postgres

postgres-wait:
	@started_at="$$(date +%s)"; \
	while true; do \
		state="$$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' dbt-package-template-postgres 2>/dev/null || true)"; \
		if [ "$$state" = "healthy" ]; then \
			exit 0; \
		fi; \
		if [ -z "$$state" ]; then \
			echo "Postgres container dbt-package-template-postgres was not created successfully." >&2; \
			exit 1; \
		fi; \
		if [ $$(( $$(date +%s) - $$started_at )) -ge 60 ]; then \
			echo "Timed out waiting for Postgres to become healthy." >&2; \
			exit 1; \
		fi; \
		sleep 1; \
	done

postgres-down:
	docker compose -f docker-compose.postgres.yml down --remove-orphans

postgres-logs:
	docker compose -f docker-compose.postgres.yml logs --no-color postgres

run-unit-tests-postgres:
	./scripts/run_with_postgres_container.sh \
		bash -lc "uv run nox -s \"unit_tests-3.12(adapter='postgres', uv_group='dbt-core-1-10')\" && uv run nox -s \"unit_tests-3.12(adapter='postgres', uv_group='dbt-core-1-11')\""

run-unit-tests-duckdb:
	uv run nox -s "unit_tests-3.12(adapter='duckdb', uv_group='dbt-core-1-10')"
	uv run nox -s "unit_tests-3.12(adapter='duckdb', uv_group='dbt-core-1-11')"

run-unit-tests: clean run-unit-tests-postgres
	$(MAKE) run-unit-tests-duckdb

run-unit-tests-fusion:
	./scripts/run_with_postgres_container.sh \
		uv run nox -s "fusion_unit_tests-3.12"

run-integration-tests-postgres:
	./scripts/run_with_postgres_container.sh \
		bash -lc "uv run nox -s \"integration_tests-3.12(adapter='postgres', uv_group='dbt-core-1-10')\" && uv run nox -s \"integration_tests-3.12(adapter='postgres', uv_group='dbt-core-1-11')\""

run-integration-tests-duckdb:
	uv run nox -s "integration_tests-3.12(adapter='duckdb', uv_group='dbt-core-1-10')"
	uv run nox -s "integration_tests-3.12(adapter='duckdb', uv_group='dbt-core-1-11')"

run-integration-tests: clean run-integration-tests-postgres
	$(MAKE) run-integration-tests-duckdb

run-integration-tests-fusion:
	./scripts/run_with_postgres_container.sh \
		uv run nox -s "fusion_integration_tests-3.12"

run-fusion-tests: run-unit-tests-fusion run-integration-tests-fusion

test: run-unit-tests run-integration-tests
