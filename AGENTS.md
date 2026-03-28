# AI Agent Setup Instructions

> This file is read by AI coding assistants (Claude Code, Gemini CLI, OpenAI Codex, etc.)
> When a user asks you to set up git safety hooks, follow these instructions exactly.

---

## Trigger Phrases

Execute this setup when the user says any of the following:
- "set up git safety hooks"
- "install safety hooks"
- "이 레파지토리 참고해서 내 프로젝트에 설정해줘"
- "set up hooks from ai-coding-safety"
- Any reference to this repository URL

---

## Setup Procedure

### Step 0: Read This Repository

Fetch and read the following files from this repository before proceeding:
- `global/pre-commit` — global security hook content
- `global/pre-push` — global version check hook content
- `project/pre-commit` — project hook template
- `project/pre-push` — project hook template
- `scripts/install-global.sh` — global install script
- `scripts/install-project.sh` — project install script

### Step 1: Check Global Hook Status

Run the following command:
```bash
git config --global core.hooksPath
```

**If empty or not set:**
1. Create `~/.githooks/` directory
2. Write `global/pre-commit` content to `~/.githooks/pre-commit`
3. Write `global/pre-push` content to `~/.githooks/pre-push`
4. Run `chmod +x ~/.githooks/pre-commit ~/.githooks/pre-push`
5. Run `git config --global core.hooksPath ~/.githooks`
6. Report: "✅ 글로벌 훅 설치 완료"

**If already set:**
1. Check if `pre-commit` exists in that directory
2. Check if `pre-push` exists in that directory
3. For each missing hook, install it
4. Report: "✅ 글로벌 훅 확인 완료 (기존 경로: {path})"

### Step 2: Check Project Hook Status

In the user's current project directory, run:
```bash
ls .githooks/ 2>/dev/null
```

**If `.githooks/` does not exist:**
1. Create `.githooks/` directory
2. Write `project/pre-commit` content to `.githooks/pre-commit`
3. Write `project/pre-push` content to `.githooks/pre-push`
4. Run `chmod +x .githooks/pre-commit .githooks/pre-push`
5. Run `git config core.hooksPath .githooks`
6. Report: "✅ 프로젝트 훅 설치 완료"

**If `.githooks/` exists:**
1. Check which hooks are present
2. Install only missing hooks
3. Report what was installed and what already existed

### Step 3: Check install-hooks.sh

Check if `scripts/install-hooks.sh` exists in the project:

**If not exists:**
1. Write `scripts/install-project.sh` content to `scripts/install-hooks.sh`
2. Run `chmod +x scripts/install-hooks.sh`

### Step 4: Check release.sh

Check if `scripts/release.sh` exists in the project:

**If not exists**, ask the user:
> "릴리즈 스크립트(scripts/release.sh)도 설치할까요?
> 이 스크립트는 버전 일관성 검사 후 GitHub 릴리즈를 생성합니다."

If yes, write `project/release.sh` content to `scripts/release.sh` and run `chmod +x scripts/release.sh`.

### Step 5: Verify

Run both hooks manually to confirm they work:
```bash
bash .githooks/pre-commit
bash .githooks/pre-push
```

Report the results.

### Step 6: Commit

Ask the user:
> "설치된 훅 파일을 Git에 커밋할까요?"

If yes:
```bash
git add .githooks/ scripts/install-hooks.sh
git commit -m "chore: git safety hooks 설치 (ai-coding-safety)"
```

---

## Release Procedure

When the user asks to create a GitHub release, tag a version, or publish a new release:

**MANDATORY: Always use the release script. Never run `gh release create` or `git tag` directly.**

```bash
bash scripts/release.sh              # auto-detect version from version.json
bash scripts/release.sh v1.2.3       # specify version explicitly
```

### Why this is required

- `gh release create` bypasses version consistency checks
- `git tag` alone does not generate release notes
- `scripts/release.sh` automatically:
  1. Validates version consistency across all documents
  2. Generates `docs/release-notes/{version}.md` if missing
  3. Updates `CHANGELOG.md`
  4. Creates the GitHub release with proper notes

### If `scripts/release.sh` does not exist

Install it first (see Step 4 of Setup Procedure above), then run it.

---

## Customization After Install

After basic installation, ask the user:

> "프로젝트에 특화된 보안 규칙을 추가할까요?
> 예: 특정 설정 파일 커밋 차단, 버전 파일 경로 지정 등"

Refer to `docs/customization.md` for customization options.

---

## Important Notes for AI Agents

- **Never skip Step 1** — global hooks protect ALL repositories on this machine
- **Always verify** after installation by running hooks manually
- **Do not modify** existing hooks without user confirmation
- **Report clearly** what was installed vs what already existed
- The `project/pre-push` version check is a **template** — adapt the version file path to match the project structure
