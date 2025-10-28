---
name: Release
about: Follow these steps to create a release candidate build, approve it and finalize a release
title: "Release: "
labels: release
assignees: ''
---

Follow the steps below to create a release of OnDemand Loop.

1. **Prepare the issue**
   - Ensure the title starts with `Release`.
   - Add at least one assignee to this issue.
   - Add the label `release`

2. **Create a release candidate**
   - Comment the following command on this issue:
     ```
     /create_release_candidate
     ```
   - Eyes and rocket react appear when the command is received.
   - This designates the current `main` commit as one to be deployed to the QA environment and comments the result with the commit hash.

3. **Verify and approve**
   - Test the deployment in QA.
   - When ready to proceed, add a comment (which the next command will look for) containing:
     ```
     release approved
     ```

4. **Create the release**
   - Trigger the release workflow by commenting:
     ```
     /create_release type=<patch|minor|major>
     ```
     Replace `<patch|minor|major>` with the desired semantic version bump.
   - This will use the previously saved commit hash to create a tag and a release with the new version number.
   - While we are in beta, we are doing only minor releases. 

5. **Finish up**
   - Once the release workflow succeeds it will comment the version number and release notes link.
   - Close this issue when everything looks good.

_Only authorized users (in `.github/workflows/slash_command_listener.yml`) can execute the slash commands above._
