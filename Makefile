# Define default compose command
COMPOSE_CMD = docker compose

.PHONY: up down build restart install server prod_server logs bash console tests

# Start the container in the background
up:
	$(COMPOSE_CMD) up -d

# Stop the container
down:
	$(COMPOSE_CMD) down

# Build or rebuild the container
docker:
	$(COMPOSE_CMD) build

# Restart the container
restart: down up

# Install dependencies with bundle install
install: up
	$(COMPOSE_CMD) exec app bundle install
	$(COMPOSE_CMD) exec app rails assets:precompile

# Start Rails server
server: up
	$(COMPOSE_CMD) exec app rails server -b 0.0.0.0

# Start Rails server in production mode
prod_server: up
	$(COMPOSE_CMD) exec app rails server -e production -b 0.0.0.0

# Show logs for the app container
logs: up
	$(COMPOSE_CMD) exec app tail -f log/development.log

# Open a bash shell in the Rails app container
bash: up
	$(COMPOSE_CMD) exec app bash

# Open a Rails Console in the app container
console: up
	$(COMPOSE_CMD) exec app rails console

# Run tests
tests: up
	$(COMPOSE_CMD) exec app bundle exec rails test
