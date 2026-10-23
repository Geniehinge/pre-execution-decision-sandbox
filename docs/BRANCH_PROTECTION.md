# PELLAIRI PEDS change-control policy

This document states the intended policy for the default `main` branch. It does not prove that GitHub currently enforces these settings. A maintainer must verify the live repository rules after configuration changes.

## Required change path

- Merge changes through pull requests. Do not push directly to `main`.
- Require at least one approving review from someone other than the pull request author.
- Do not treat self-review or an administrator bypass as independent approval.
- Require all applicable CI checks to pass before merging. Because workflows use path filters, require only checks that run for the changed files.
- Dismiss stale approvals when new commits change the reviewed diff.
- Resolve review conversations before merge.
- Block force pushes and deletion of `main`.
- Apply CODEOWNERS review to changes under `.github/`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, and this policy.

## Reviewer availability and emergency bypass

The project must have an independent reviewer with write access before enforcing an approval requirement. If none is available, keep substantive changes open for review rather than describing self-approval as independent review.

Any emergency bypass must be limited to an incident response, documented in the pull request with the reason and checks performed, and reviewed independently afterward. Do not grant an always-on bypass as the routine change path.

## Organization policy limits

Organization-level rulesets require a GitHub Team or Enterprise plan. If the organization does not have an eligible plan, enforce the required protections in this repository's settings and verify them directly. Do not describe a disabled organization policy or an unverified setting as active.
