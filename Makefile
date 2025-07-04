all:: loop_up
.PHONY: loop_up loop_down loop_build remote_dev_build release_build loop_docker_builder clean logs bash test test_bash version release_notes

COMPOSE_CMD = docker compose
OOD_UID := $(shell id -u)
OOD_GID := $(shell id -g)
OOD_IMAGE := hmdc/sid-ood:ood-3.1.7.el8
LOOP_BUILDER_IMAGE := hmdc/ondemand-loop:builder-R3.1
WORKING_DIR := $(shell pwd)
DOC_BUILDER_IMAGE := squidfunk/mkdocs-material:latest

ENV := env OOD_IMAGE=$(OOD_IMAGE) OOD_UID=$(OOD_UID) OOD_GID=$(OOD_GID)

loop_up: loop_down
	$(ENV) $(COMPOSE_CMD) -p loop_passenger up --build || :

loop_down:
	$(ENV) $(COMPOSE_CMD) -p loop_passenger down -v || :

loop_build:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_build.sh

remote_dev_build:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app -e APP_ROOT=/pun/dev/loop -e APP_ENV=production $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_build.sh

release_build:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app -e APP_ROOT=/pun/sys/loop -e APP_ENV=production $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_build.sh

loop_docker_builder:
	docker build --platform=linux/amd64 --build-arg RUBY_VERSION=ruby:3.1 -t $(LOOP_BUILDER_IMAGE) -f docker/Dockerfile.builder .

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

test_bash:
	docker run --rm -it -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app $(LOOP_BUILDER_IMAGE) /bin/bash

version:
	docker run --rm -e VERSION_TYPE=$(VERSION_TYPE) -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_version.sh

release_notes:
	./scripts/loop_release_notes.sh

coverage:
	./scripts/loop_coverage_badge.sh

# Build the user guide using MkDocs
user_guide:
	docker run --rm -v $(WORKING_DIR):/docs -w /docs $(DOC_BUILDER_IMAGE) ./scripts/user_guide.sh
