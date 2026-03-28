# Gemini CLI Instructions

> Gemini CLI reads this file automatically.
> Follow AGENTS.md for the full setup procedure.

## Quick Reference

When the user asks to set up git safety hooks, read `AGENTS.md` and follow the procedure exactly.

## Gemini-Specific Notes

- Use shell tool to check existing hook configuration
- Use file write tool to create hook files
- Always verify hooks by running them after installation
- Read all hook template files from this repository before starting

## Release Procedure

When the user asks to create a GitHub release, tag a version, or publish a new release:

**MANDATORY: Always use `bash scripts/release.sh`. Never run `gh release create` or `git tag` directly.**

- Direct `gh release create` bypasses version checks and skips release note generation
- `scripts/release.sh` auto-generates `docs/release-notes/{version}.md` and updates `CHANGELOG.md`
- If `scripts/release.sh` does not exist, install it first (see AGENTS.md Step 4)

## Response Language

Respond in the same language the user is using.
