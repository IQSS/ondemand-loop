# GitHub Actions
This project uses several GitHub Actions workflows to automate testing, releases, and documentation.
Access to these workflows varies based on user permissions.

For the actual definition of the workflows refer to the [repository source](https://github.com/IQSS/ondemand-loop/tree/main/.github/workflows).

### Public Workflows (Contributors Can Trigger)
These workflows run automatically for all contributors:

#### **test.yml**
- **Triggers:** Pull requests and pushes to `main` branch
- **Purpose:** Runs the full test suite via `make test`
- **Additional:** Generates SimpleCov coverage badges when changes are pushed to `main`
- **Access:** ✅ All contributors (runs on PR creation)

#### **guide.yml**
- **Triggers:** Changes to documentation under `docs/guide` on `main` branch
- **Purpose:** Builds this guide using `make guide` and deploys to GitHub Pages
- **Access:** ✅ All contributors (runs when docs are merged)

### Restricted Workflows (Authorized Users Only)
These workflows require special permissions and **cannot be triggered by external contributors**:

#### **create_release_candidate.yml**
- **Triggers:** `/create_release_candidate` issue comment
- **Purpose:** Validates issues and builds release candidate branches for testing
- **Access:** 🚫 Authorized users only
- **Dependencies:** Uses `build_from_hash.yml` workflow

#### **create_release.yml**
- **Triggers:** `/create_release` issue comment
- **Purpose:** Verifies release candidate approval and initiates release process
- **Access:** 🚫 Authorized users only
- **Dependencies:** Calls `release.yml` workflow

#### **slash_command_listener.yml**
- **Triggers:** Issue comments with `/create_release_candidate` or `/create_release`
- **Purpose:** Listens for and dispatches release commands
- **Access:** 🚫 Authorized users only (commands ignored from unauthorized users)

### 🔧 Internal Workflows
These workflows are called by other workflows and don't run independently:

#### **build_from_hash.yml**
- **Type:** Reusable workflow
- **Purpose:** Builds Loop from specific commit hash for QA or release candidates
- **Called by:** `create_release_candidate.yml` and other release workflows

#### **release.yml**
- **Type:** Internal workflow
- **Purpose:** Runs tests, bumps version, creates Git tags, and generates release notes
- **Called by:** `create_release.yml`

#### **label_issues_on_release.yml**
- **Triggers:** GitHub Release publication (automatic) or manual trigger
- **Purpose:** Labels closed issues with `released:<tag>` for tracking
- **Access:** 🚫 Manual trigger restricted to maintainers

**For maintainers:**
All workflows are available with appropriate repository permissions.
User permissions are managed in the `slash_command_listener.yml` workflow
Release processes are controlled through issue comments with slash commands for security and audit trail purposes.

---

These workflows ensure that code is automatically tested, releases are repeatable, documentation stays current, and release processes remain secure while being transparent to all contributors.
