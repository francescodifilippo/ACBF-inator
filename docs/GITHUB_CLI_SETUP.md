# Configure GitHub with `gh`

The repository is designed to track development in **Issues**, six deliverable-based **Milestones**, one user-owned **GitHub Project**, and short-lived reviewable **Pull Requests**.

Because the connected GitHub integration does not expose user-owned GitHub Projects or milestone creation, the repeatable one-time setup uses the official GitHub CLI and the repository owner's own login.

## Windows PowerShell

1. Install [GitHub CLI](https://cli.github.com/) if missing, e.g. `winget install --id GitHub.cli -e`.
2. In a PowerShell terminal authenticate: `gh auth login` (choose GitHub.com and browser login).
3. Grant Projects permissions: `gh auth refresh -s project`. The scope is required for GitHub Projects, not for public reading.
4. Clone/download this repository and run:

   ```powershell
   git clone https://github.com/francescodifilippo/ACBF-inator.git
   cd ACBF-inator
   # While the script PR is open, check out its branch first: git switch chore/github-cli-bootstrap
   gh auth status
   pwsh -File ./scripts/bootstrap-github.ps1
   ```

   If PowerShell 7 (`pwsh`) is not installed, `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\bootstrap-github.ps1` is another Windows option.

## What it performs

- Sets repository description and Topics, and enables repository Projects.
- Creates *only missing* milestones M0-M5 and assigns the existing development issues.
- Reuses the existing owner project called **ACBF-inator - Development**, or creates one if absent.
- Links the project to the repository and adds existing issues #1-#13 and #15.
- Adds optional fields **Workflow**, **Priority**, and **Area** if missing.
- Does not merge PRs, create releases, change permissions, delete anything or store credentials.

The script is intended to be repeatable. If GitHub responds with an error during a partially completed run, fix the permission/connection problem and rerun; earlier operations should be recognized as existing.

## Final manual view configuration

Create a Board view organized around the project `Workflow` field (or use the default Status field), and a Roadmap view if desired. The basic `gh project` CLI manages items and fields but does not directly create/customize those views.

## Review

Confirm [PR #14](https://github.com/francescodifilippo/ACBF-inator/pull/14) for the corrected self-hosted scope and review this script's PR independently. You do **not** need to give ChatGPT your `gh` token, OAuth code, password, or any stored credentials.

Issue tracker: [#15](https://github.com/francescodifilippo/ACBF-inator/issues/15).
