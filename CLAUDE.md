# Claude Code Instructions

> Claude Code reads this file automatically.
> Follow AGENTS.md for the full setup procedure.

## Quick Reference

When the user asks to set up git safety hooks, read `AGENTS.md` and follow the procedure exactly.

## Claude-Specific Notes

- Use the `Read` tool to fetch hook file contents from this repository
- Use the `Bash` tool to check existing hook configuration
- Use the `Write` tool to create hook files
- Use the `Edit` tool to modify existing hooks
- Always run hooks with `Bash` to verify they work before committing

## File Fetch Order

Read these files in order before starting setup:
1. `AGENTS.md` — full procedure
2. `global/pre-commit` — global security hook
3. `global/pre-push` — global pre-push hook
4. `project/pre-commit` — project hook template
5. `project/pre-push` — project version check template

## Response Language

Respond in the same language the user is using.
If the user writes in Korean, respond in Korean.
