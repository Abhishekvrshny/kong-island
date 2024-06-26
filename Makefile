.PHONY: lint test

# Exports KONG_VERSION for make targets if not exposed as a custom value already.
KONG_VERSION?=3.4.0

# Exports PONGO_NETWORK to link all containers to this network
# Based on https://github.com/Kong/kong-pongo/blob/d10eb09f8d0de6856fb022555cd2dd9b56695f23/pongo.sh#L74
# Until pongo exposes SERVICE_NETWORK_NAME
export PONGO_NETWORK := $(shell ./pongo-network.sh)
$(info $(PONGO_NETWORK))

help: ## Shows help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Initialization: Symblinks kong-pongo's executable to host's path.
	sudo rm -rf /usr/local/bin/pongo; sudo ln -s $(realpath kong-pongo/pongo.sh) /usr/local/bin/pongo

lint: ## Runs linters for all kong plugins.
	for i in $$(find kong-plugins/* -maxdepth 0 -type d -print0 | xargs -0 -L1); do cd $$i; pongo lint; done

test-integration: ## Runs integration tests across all kong plugins.
	mkdir -p ./test/kong/plugins
	find kong-plugins/* -maxdepth 0 -type d -print0 | xargs -0 -L1 bash -c 'cp -a $$(realpath "$$0"/kong/plugins/*) ./test/kong/plugins/'
	cd ./test && pongo run --v -o gtest ./spec

test-each: ## Runs individual tests for each kong plugin.
	for i in $$(find kong-plugins/* -maxdepth 0 -type d -print0 | xargs -0 -L1); do cd $$i; pongo run -v -o gtest ./spec; done

test-clean: ## Cleans test setup
	rm -rf ./test/kong
	find kong-plugins/* -maxdepth 0 -type d -print0 | xargs -0 -L1 bash -c 'cd "$$0" && pongo down'
	cd ./test && pongo down

test: test-each test-integration test-clean ## Runs all tests for all kong plugins.

up: ## Brings up kong, cassandra and konga
	pongo up
	docker-compose -f docker-compose.yml up --build -d --remove-orphans

down: ## Brings down kong, cassandra and konga
	docker-compose down; pongo down
