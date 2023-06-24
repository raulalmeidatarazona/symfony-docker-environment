current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

UID=$(shell id -u)
GID=$(shell id -g)
COMPOSER=$(wildcard /var/app/composer.json)
DOCKER_PHP_SERVICE=php
DOCKER_DB_SERVICE=postgres
DOCKER_DB_PORT=5432


help: ## ❓ Show this help message
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

init: ## 🚀 Initialize the project
		$(MAKE) erase && $(MAKE) build && $(MAKE) start && $(MAKE) composer-install

start: ## ▶️ Start the containers 🐳
		U_ID=${UID} docker-compose up -d

stop: ## ⏹️ Stop the containers 🐳
		U_ID=${UID} docker-compose stop

build: ## 🛠 Rebuilds all the containers 🐳
		U_ID=${UID} docker-compose build --no-cache

restart: ## 🔄 Restart the containers 🐳
		$(MAKE) stop && $(MAKE) start

erase: ## 🗑 Erase all the containers 🐳
		U_ID=${UID} docker-compose down -v

composer-install: ## 🔧 Install the project dependencies 🐳
ifdef COMPOSER
	U_ID=${UID}  docker-compose run --rm -u ${UID}:${GID} ${DOCKER_PHP_SERVICE} sh -c 'if [ -f /var/app/composer.json ]; then composer install; else echo "composer.json file not found. Skipping composer-install."; fi'
else
	@echo "composer.json file not found. Skipping composer-install."
endif

bash: ## 💻 Run a shell in the php container 🐳
		U_ID=${UID} docker-compose run --rm -u ${UID}:${GID} ${DOCKER_PHP_SERVICE} bash

code-style: ## 🪄 Runs php-cs to fix code styling following Symfony rules 🐳
		U_ID=${UID}  docker-compose run --rm -u ${UID} ${DOCKER_PHP_SERVICE} php-cs-fixer fix src --rules=@Symfony