# Skill: commit

Analyzes staged git changes and generates a [Conventional Commits](https://www.conventionalcommits.org/) message.

---

## Trigger Phrases

- "commit"
- "git commit"
- "write a commit message"
- "save to git"
- "create a commit"

---

## Commit Message Format

```
<type>(<scope>): <short description>

[optional body — explain WHAT and WHY, not HOW]

[optional footer — breaking changes, closes issue]
```

Short description rules:
- Max 72 characters
- Imperative mood: "add", "fix", "update" — not "added", "fixed"
- Written in English

---

## Commit Types

| Type | When to use |
|------|------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Refactor without behavior change |
| `docs` | Documentation only |
| `test` | Add or update tests |
| `chore` | Build, config, dependencies |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |
| `style` | Formatting only (no logic change) |
| `revert` | Revert a previous commit |

---

## Steps

1. Run `git diff --staged` to read the staged changes
2. Analyze which files changed, what the impact is, and why the change was made
3. Choose the most appropriate `type` and `scope`
4. Write the short description — imperative mood, max 72 characters
5. Add a body if the change needs context beyond the title
6. Run the commit

---

## Examples

Simple change:

```
feat(auth): add JWT refresh token support
```

Change with body:

```
fix(api): handle null response from payment gateway

Payment gateway occasionally returns null instead of an error object
when the service is unavailable, causing an unhandled exception.
```

Breaking change:

```
feat(api)!: change response format for /users endpoint

BREAKING CHANGE: response now returns { data: [...] } instead of a plain array
```

---

## Notes

- If no files are staged, ask the user which files they want to commit before proceeding
- Never include changes from `.env` or credential files in the commit
- Prefer one logical change per commit over bundling unrelated changes
