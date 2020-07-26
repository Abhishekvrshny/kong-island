.PHONY: lint test

# Exports KONG_VERSION for make targets if not exposed as a custom value already.
KONG_VERSION?=2.0.3

help: ## Shows help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Initialization: Symblinks kong-pongo's executable to host's path.
	sudo rm -rf /usr/local/bin/pongo; sudo ln -s $(realpath kong-pongo/pongo.sh) /usr/local/bin/pongo

lint: ## Runs linters for all kong plugins.
	find kong-plugins/* -maxdepth 0 -type d -print0 | xargs -0 -L1 bash -c 'cd "$$0" && pongo lint'

test-integration: ## Runs integration tests across all kong plugins.
	mkdir -p ./test/kong/plugins
	find kong-plugins/* -maxdepth 0 -type d -print0 | xargs -0 -L1 bash -c 'cp -a $$(realpath "$$0"/kong/plugins/*) ./test/kong/plugins/'
	cd ./test && pongo run -v -o gtest ./spec

test-each: ## Runs individual tests for each kong plugin.
	find kong-plugins/* -maxdepth 0 -type d -print0 | xargs -0 -L1 bash -c 'cd "$$0" && pongo run -v -o gtest ./spec'

test-clean: ## Cleans test setup
	rm -rf ./test/kong

test: test-each test-integration test-clean ## Runs all tests for all kong plugins.

up: ## Brings up kong, cassandra and konga
	pongo up; docker-compose -f docker-compose.yml up --build -d --remove-orphans

down: ## Brings down kong, cassandra and konga
	docker-compose down; pongo down
