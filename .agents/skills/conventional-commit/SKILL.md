---
name: conventional-commit-and-pii-scan
description: Enforces Conventional Commits 1.0.0 format and performs pre-commit PII/secrets scanning for all git commits.
version: 1.0.0
---

# Conventional Commit & PII Scan Skill

## Purpose
This skill ensures that all changes committed to the Calculator Lite repository adhere to standard Conventional Commits 1.0.0 specifications, and guarantees that no Personally Identifiable Information (PII), credentials, private keys, or API tokens are leaked into the git history.

---

## 1. Conventional Commit Specification

Every commit message must follow this exact structure:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Allowed Types
- `feat`: A new feature or capability introduced for the user or system.
- `fix`: A bug fix.
- `refactor`: A code change that neither fixes a bug nor adds a feature (e.g., restructuring, SOLID improvements).
- `perf`: A code change that improves execution or rendering performance.
- `test`: Adding missing tests or correcting existing tests.
- `docs`: Documentation-only changes (including `.docs/`, ADRs, and README).
- `chore`: Routine maintenance, updating build tasks, package manager dependencies, or configs.
- `style`: Changes that do not affect the meaning of the code (formatting, white-space, semicolon fixes).
- `ci`: Changes to CI/CD configuration files and automation scripts.

### Allowed Scopes
- `calc`: Calculator engine, parser, tokens, evaluation logic.
- `currency`: Currency exchange rate fetching, caching, and conversion.
- `history`: History storage, Hive adapters, history operations.
- `export`: CSV/Excel export service and dialog.
- `ui`: Reusable UI components, themes, layouts, animations.
- `security`: OWASP security hardening, input validation, window manager.
- `deps`: Pub package updates or dependency replacements.
- `docs`: Architecture docs, ADRs, diagrams, and README.

### Formatting Rules
1. Use the imperative, present tense: "add" not "added", "fix" not "fixed".
2. Do not capitalize the first letter of the subject description.
3. No period (.) at the end of the subject line.
4. Keep the subject line under 72 characters.
5. Breaking changes must contain `!` before the colon (e.g., `feat(calc)!: change return type of evaluate`) or include `BREAKING CHANGE:` in the footer.

---

## 2. Pre-Commit PII & Secrets Scanning Procedure

Before any commit is finalized, the agent MUST run the PII and Secrets Scanner:

```bash
python .agents/skills/conventional-commit/scripts/scan_pii.py
```

### What the Scanner Checks:
- **API Keys & Tokens**: Google API keys (`AIza...`), GitHub tokens, AWS keys, generic Bearer tokens.
- **Private Keys**: RSA, DSA, EC, or OpenSSH private key headers (`-----BEGIN ... PRIVATE KEY-----`).
- **Emails**: Unmasked personal or corporate email addresses (excluding sanctioned doc examples like `user@example.com`).
- **Authentication Secrets**: Hardcoded passwords, client secrets, basic auth strings.
- **Personal Identifiers**: Phone numbers, government IDs, physical addresses.

If the scanner detects any potential PII or secret, the commit MUST BE ABORTED immediately and the offending string must be removed or sanitized before proceeding.
