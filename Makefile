# Define default compose command
COMPOSE_CMD = docker compose

.PHONY: up server down build restart logs bash console tests db-setup

# Start the containers in the background
up:
	$(COMPOSE_CMD) up -d

# Start the containers in foreground
server:
	$(COMPOSE_CMD) up

# Stop the containers
down:
	$(COMPOSE_CMD) down

# Build or rebuild the containers
build:
	$(COMPOSE_CMD) build

# Restart the containers
restart: down up

# Show logs for the app container
logs:
	$(COMPOSE_CMD) logs -f app

# Open a bash shell in the Rails app container
bash:
	$(COMPOSE_CMD) exec app bash

# Open a Rails Console in the app container
console:
	$(COMPOSE_CMD) exec app rails console

# Run tests
tests:
	$(COMPOSE_CMD) exec app bundle exec rspec

# Run database setup (create, migrate, seed)
db-setup:
	$(COMPOSE_CMD) run app rails db:create db:migrate db:seed
