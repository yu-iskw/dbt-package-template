lint:
	pre-commit run -a

update-pre-commit-hooks:
	pre-commit autoupdate

generate-toc:
	markdown-toc --maxdepth 5 -i README.md

######################################################################
# Integration tests
######################################################################
setup-integration-tests:
	$(MAKE) -C integration_tests setup

run-unit-tests:
	$(MAKE) -C integration_tests run-unit-tests

run-unit-tests-fusion:
	$(MAKE) -C integration_tests run-unit-tests-fusion

run-integration-tests:
	$(MAKE) -C integration_tests run-integration-tests

run-integration-tests-fusion:
	$(MAKE) -C integration_tests run-integration-tests-fusion

run-fusion-tests:
	$(MAKE) -C integration_tests run-fusion-tests

test-integration:
	$(MAKE) -C integration_tests test

test: run-unit-tests run-integration-tests
