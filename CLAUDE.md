# Archer — Project Context

This is the working directory for the Archer project itself.
See `.claude/commands/archer.md` for the full Archer skill definition.

---

## On `end`

When the user sends exactly `end`, write a session entry to `SESSIONS.md` before closing out.

Format:

```markdown
## [YYYY-MM-DD]

**What we worked on:** [1-2 sentence summary]

**Decisions made:**
- [decision] — [why]

**Patterns / fixes discovered:**
- [thing learned]

**Current state:**
- Branch: [branch name]
- Last commit: [short sha and message]
- Open threads: [anything unresolved or deferred]
```

Keep it dense. 10-15 bullets max. The goal is a new session being able to read this in 30 seconds and pick up without re-litigating anything. Once a decision is stable and reflected in the code, it can be pruned from older entries.

Prepend the new entry — newest session at the top, below the header.

---

## Project State

- Repo: `~/Archer` → `github.com/dloyst/Archer`
- Active branch: `poc/petstore`
- Distributed skill: `.claude/commands/archer.md` (self-contained, install to `~/.claude/commands/`)
- `CLAUDE.md` (this file): dev context only, not the skill
- `SESSIONS.md`: local session log, gitignored
