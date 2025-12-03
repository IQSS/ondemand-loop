# Repository Guidelines

## Project Structure & Module Organization
Rails code lives in `application/`; `app/` holds controllers, services, Stimulus controllers, and validators, while `app/assets/` stores SCSS and compiled builds. `application/test/` contains fixtures and unit suites, `e2e_tests/cypress/` tracks browser specs, `scripts/` + `tools/` host build helpers, and MkDocs sources live under `docs/`.

## Build, Test, and Development Commands
Use the root `Makefile` for day-to-day tasks:
- `make loop_build` boots the builder image (Ruby 3.3/Node 20) to install gems, Yarn packages, and compile assets.
- `make dev_up` / `make dev_down` control the docker-compose stack defined in `docker-compose.yml` and `docker/docker-local-override.yaml`.
- `make test` runs the Rails suite; follow with `make coverage` for line/branch reports.
- `make guide` or `make guide_dev` builds the MkDocs docs site in Python 3.11.
For Cypress workflows, run `cd e2e_tests && make env_up && make cypress_build && make cypress_run`.

## Coding Style & Naming Conventions
Follow the `rubocop-rails-omakase` defaults enforced by `application/.rubocop.yml`; keep Ruby at 2-space indentation and prefer single quotes. Service and validator classes should mirror their directory names (`app/services/reporting/report_collector.rb`). Stimulus controllers stay inside `app/javascript/controllers/*_controller.js`, and SCSS modules compile from `app/assets/stylesheets/` via `yarn build:css` or `yarn watch:css`.

## Testing Guidelines
Unit and integration specs use Minitest with Mocha; name files `*_test.rb`, store fixtures in `test/fixtures/`, and run `make test` before publishing a branch. Keep the line/branch badges in `docs/badges/` green by running `make coverage` when you touch critical logic. End-to-end flows live in `e2e_tests/cypress/e2e/*.cy.js`; bootstrap Docker with `make env_up`, then execute `make cypress_run` to verify uploads/downloads end-to-end.

## Commit & Pull Request Guidelines
Recent history favors Conventional Commit prefixes (`feat:`, `fix:`, `chore:`); keep that style, referencing the GitHub issue number when possible. PRs should summarize the change set, list the commands you ran (`make test`, `make cypress_run`, etc.), and describe any UI/configuration impacts. Attach screenshots for visible updates and include accessibility notes per `CONTRIBUTING.md`. CI must be green before requesting review.

## Security & Configuration Tips
Secrets belong in `.env` or the Open OnDemand environment, never in Git. Update `application/config/manifest.yml` and other YAML settings through the documented overrides, and keep Dataverse or Zenodo tokens in ignored credential files. If you tune Docker configuration, mirror the same change in both `docker-compose.yml` and `e2e_tests/docker-compose.yml` so dev and test environments stay aligned.
