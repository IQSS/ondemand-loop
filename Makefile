all:: loop_up
.PHONY: loop_up loop_down loop_build loop_docker_builder logs bash test

COMPOSE_CMD = docker compose
OOD_UID := $(shell id -u)
OOD_GID := $(shell id -g)
OOD_IMAGE := hmdc/sid-ood:ood-3.1.7.el8
LOOP_BUILDER_IMAGE := hmdc/ondemand-loop:builder-R3.1
WORKING_DIR := $(shell pwd)

ENV := env OOD_IMAGE=$(OOD_IMAGE) OOD_UID=$(OOD_UID) OOD_GID=$(OOD_GID)

loop_up: loop_down
	$(ENV) $(COMPOSE_CMD) -p loop_passenger up --build || :

loop_down:
	$(ENV) $(COMPOSE_CMD) -p loop_passenger down -v || :

loop_build:
	docker run --platform=linux/amd64 --rm -v $(WORKING_DIR)/application:/usr/local/app -v $(WORKING_DIR)/scripts:/usr/local/scripts -w /usr/local/app $(LOOP_BUILDER_IMAGE) /usr/local/scripts/loop_build.sh

loop_docker_builder:
	docker build --platform=linux/amd64 --build-arg RUBY_VERSION=ruby:3.1 -t $(LOOP_BUILDER_IMAGE) -f docker/Dockerfile.builder .

clean:
	rm -rf ./application/node_modules
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
