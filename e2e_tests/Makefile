include ../tools/make/ood_versions.mk

PROJECT_NAME := loop_e2e
COMPOSE_CMD := docker compose
WORKING_DIR := $(shell pwd)
ENV := env OOD_IMAGE=$(OOD_IMAGE) OOD_UID=$(OOD_UID) OOD_GID=$(OOD_GID)
CYPRESS_IMAGE := cypress/included:13.6.4

# Test execution modes
CYPRESS_BROWSER ?= electron
CYPRESS_SPEC ?=

.PHONY: help env_up env_down env_status env_logs cypress_deps cypress_build cypress_run clean

# Default target
help:
	@echo "Available targets:"
	@echo ""
	@echo "Environment Management:"
	@echo "  env_up          - Start test environment (OOD, mocks, services)"
	@echo "  env_down        - Stop test environment"
	@echo "  env_status      - Show status of environment services"
	@echo "  env_logs        - Show logs from environment services"
	@echo ""
	@echo "Cypress Testing (requires env_up first):"
	@echo "  cypress_deps    - Generate/update package-lock.json using Docker container"
	@echo "  cypress_build   - Build Cypress project and install dependencies"
	@echo "  cypress_run     - Run Cypress tests headless"
	@echo ""
	@echo "Cleanup:"
	@echo "  clean           - Stop environment and clean up artifacts"
	@echo ""
	@echo "Environment variables:"
	@echo "  CYPRESS_BROWSER   - Browser to use (chrome, firefox, edge) [default: chrome]"
	@echo "  CYPRESS_SPEC      - Specific test spec to run [default: all]"
	@echo "  LOOP_USERNAME     - Username for OOD authentication"
	@echo "  LOOP_PASSWORD     - Password for OOD authentication"
	@echo "  OOD_VERSION       - OnDemand version [default: 3.1.7]"

# Start the test environment
env_up: env_down
	@echo "Starting test environment..."
	$(ENV) $(COMPOSE_CMD) -f docker-compose.yml -p $(PROJECT_NAME) up -d --build
	@echo "Run 'make cypress_run' to execute tests"

# Stop the test environment
env_down:
	@echo "Stopping test environment..."
	$(ENV) $(COMPOSE_CMD) -f docker-compose.yml -p $(PROJECT_NAME) down -v --remove-orphans || :

bash:
	docker exec -it test_loop_ood /bin/bash

# Show environment status
env_status:
	@echo "Environment status:"
	$(ENV) $(COMPOSE_CMD) -f docker-compose.yml -p $(PROJECT_NAME) ps

# Show environment logs
env_logs:
	$(ENV) $(COMPOSE_CMD) -f docker-compose.yml -p $(PROJECT_NAME) logs --tail=500

# Show Loop logs
loop_logs:
	docker exec test_loop_ood cat /var/log/ondemand-nginx/ood/error.log || true

# Generate/update package-lock.json using Docker container
cypress_deps:
	@echo "Generating/updating package-lock.json using Docker container..."
	@echo "This ensures the lock file is created in the same Linux environment as test execution"
	@# Remove existing lock file and node_modules to ensure clean resolution
	@rm -f package-lock.json
	@rm -rf node_modules
	docker run --rm \
		-v $(WORKING_DIR):/e2e \
		-w /e2e \
		--entrypoint sh \
		$(CYPRESS_IMAGE) \
		-c "npm install && chown $(shell id -u):$(shell id -g) package-lock.json"
	@echo "package-lock.json updated successfully"
	@echo "You should commit this file to ensure consistent dependency resolution"

# Build Cypress project and install dependencies
cypress_build:
	@echo "Building Cypress project and installing dependencies..."
	docker run --rm \
		--network host \
		-v $(WORKING_DIR):/e2e \
		-w /e2e \
		--entrypoint sh \
		$(CYPRESS_IMAGE) \
		-c "npm ci"
	@echo "Cypress project built successfully"

# Run Cypress tests in headless mode using vanilla Cypress image
cypress_run:
	@echo "Running Cypress tests in headless mode..."
	docker run --rm \
	    --shm-size=2g \
		--network host \
		-e LOOP_USERNAME=$(LOOP_USERNAME) \
		-e LOOP_PASSWORD=$(LOOP_PASSWORD) \
		-v $(WORKING_DIR):/e2e \
		-w /e2e \
		$(CYPRESS_IMAGE) \
		cypress run --browser $(CYPRESS_BROWSER) $(if $(CYPRESS_SPEC),--spec $(CYPRESS_SPEC))

# Clean up everything
clean: env_down
	@echo "Cleaning up data and test artifacts..."
	@rm -rf data cypress/screenshots/* cypress/videos/* cypress/results/* || :
	@echo "Cleanup complete"
