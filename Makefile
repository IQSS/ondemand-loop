all:: dev_up
.PHONY: loop_up loop_down dev_up dev_down loop_build remote_dev_build release_build loop_docker_builder clean logs bash test test_bash test_exec version release_notes coverage guide guide_dev

# OOD Configuration
include tools/make/ood_versions.mk

COMPOSE_CMD = docker compose
WORKING_DIR := $(shell pwd)
DOC_BUILDER_IMAGE := python:3.11-slim
WORKING_DIR := $(shell pwd)
CONFIG_DIR := $(WORKING_DIR)/config

ENV := env OOD_IMAGE=$(OOD_IMAGE) OOD_UID=$(OOD_UID) OOD_GID=$(OOD_GID)

loop_up: loop_down
	$(ENV) $(COMPOSE_CMD) -p loop_passenger up --build -d || :

loop_down:
	$(ENV) $(COMPOSE_CMD) -p loop_passenger down -v || :

dev_up: dev_down
	$(ENV) $(COMPOSE_CMD) -f docker-compose.yml -f docker/docker-local-override.yaml -p loop_passenger up --build -d
# These must be copied not bind-mounted b/c docker will present bind-mounted files and being owned by the calling user but OOD requires that config files be owned by root when run in rails_env=production
	docker cp $(CONFIG_DIR)/ondemand.d passenger_loop_ood:/etc/ood/config
	docker exec -u 0 passenger_loop_ood chown -hR root:root /etc/ood/config/ondemand.d

dev_down:
	$(ENV) $(COMPOSE_CMD) -f docker-compose.yml -f docker/docker-local-override.yaml -p loop_passenger down -v || :

loop_build:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_build.sh

remote_dev_build:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app -e APP_ROOT=/pun/dev/loop -e APP_ENV=production $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_build.sh

release_build:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app -e APP_ROOT=/pun/sys/loop -e APP_ENV=production $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_build.sh

native_build:
	cd application && APP_ENV=production ../scripts/loop_build.sh

loop_docker_builder:
	docker build --platform=linux/amd64 --build-arg RUBY_VERSION=ruby:3.3 --build-arg NODE_VERSION=nodejs:20 -t $(LOOP_BUILDER_IMAGE) -f docker/Dockerfile.builder .

clean:
	rm -rf ./application/node_modules
	rm -rf ./application/.bundle
	rm -rf ./application/vendor/bundle
	rm -rf ./application/public/assets
	rm -f ./application/log/*

# Show logs for the app container
logs:
	docker exec -it passenger_loop_ood tail -f /var/log/ondemand-nginx/ood/error.log

# Open a bash shell in the Rails app container
bash:
	docker exec -it passenger_loop_ood /bin/bash

test:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_test.sh

# Default TTY flags for interactive terminal
TEST_TTY := -it
test_bash:
	docker run --platform=linux/amd64 --rm $(TEST_TTY) -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app $(LOOP_BUILDER_IMAGE) /bin/bash

# Override TTY flags for non-interactive execution
test_exec: TEST_TTY := -i
test_exec: test_bash

version:
	docker run --rm -e VERSION_TYPE=$(VERSION_TYPE) -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_version.sh

release_notes:
	./scripts/loop_release_notes.sh

coverage:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR):/usr/local/loop -w /usr/local/loop $(LOOP_BUILDER_IMAGE) /usr/local/loop/scripts/loop_coverage.sh

# Build the user guide using MkDocs
guide:
	docker run --rm -v $(WORKING_DIR):/docs -w /docs $(DOC_BUILDER_IMAGE) ./scripts/guide.sh

guide_dev:
	docker run --rm -it -v $(WORKING_DIR):/docs -w /docs -e DEV=true -p 8000:8000 $(DOC_BUILDER_IMAGE) ./scripts/guide.sh
