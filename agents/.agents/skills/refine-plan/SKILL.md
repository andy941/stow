---
name: refine-plan
description: Surgical refinements to an implemented feature — small refactors, logic improvements, bug fixes, missing tests. Discussion-first, changes only on explicit approval. Use when the user wants to refine, polish, tweak, fix, discuss, or improve code after implementation.
---

# Refine

Discussion-first refinement of code that has been implemented via `plan.md`. This agent is for reviewing, discussing, and then surgically applying changes — only when explicitly told to.

**Default mode is discussion.** Do not write or change any code unless the user explicitly asks you to. Your job is to help the user think through refinements, then execute them precisely when given the green light.

Maintain `refine.md` in the same feature archive directory as a shared notepad for tracking discussion items, decisions, and completed changes.

## File location

All refinement documents are stored alongside the plan and implementation log:

    past_feature_details/<branch-slug>/refine.md

## Startup

1. **Derive the branch slug.**
   - Run `git branch --show-current` to get the current branch name.
   - Strip everything up to and including the last `/` to produce the slug (e.g. `afinocchio/better-plan-naming` → `better-plan-naming`, `standalone-branch` → `standalone-branch`).
   - If the branch is `main`, `develop`, or HEAD is detached: fall back to asking the user for a short kebab-case name manually.

2. **Locate the feature directory.**
   - Search `past_feature_details/` for a directory named exactly `<slug>`.
   - **Exact match**: use it.
   - **No match**: list all available directories and ask the user which feature they want to refine, or whether to create a new one.
   - **Ambiguous slug** (e.g. two branches produce the same slug): ask the user for a unique short kebab-case name.

3. **Read context files in the feature directory:**
   - `refine.md` — if it exists, resume from where it left off.
   - `plan.md` — to understand the original design intent.
   - `implement.md` — to understand what was built and any recorded deviations.
   - `investigate.md` — if it exists, to understand exploration results and validated findings that informed the design.

4. Summarize any open items (DISCUSSING, AGREED, PARKED) to the user.

### Error recovery

- **`past_feature_details/` does not exist**: create it, then inform the user no feature directories were found. Ask if they want to specify a directory or start fresh.
- **Branch is `main`, `develop`, or HEAD is detached**: ask the user for a short kebab-case name and use that as the slug.
- **Feature directory exists but `plan.md` is missing**: inform the user "I found directory `<dir>` but it has no plan.md. I can still work on refinements but won't have the original design intent for reference." Ask whether to proceed.
- **Feature directory exists but `implement.md` is missing**: inform the user "No implementation log found — this may mean the feature hasn't been fully implemented yet." Ask whether to proceed with refinement anyway.
- **`refine.md` exists but is corrupted or has unexpected format**: show what was found and ask whether to repair it or start a fresh refinement log.
- **Git commit fails**: report the error verbatim and ask whether to retry, skip the commit, or abort.
- **File referenced in `refine.md` no longer exists at expected path**: search `past_feature_details/` for the file by name. If found elsewhere, ask the user to confirm before using it.

## refine.md structure

```markdown
# Refinement Log

> Feature: <name> | Last updated: <date>

## Items

Track every item the user raises. Status reflects the current state of discussion, not code.

| # | Status | Description | Notes |
|---|--------|-------------|-------|
| 1 | DONE | <description> | <commit ref or outcome> |
| 2 | AGREED | <description> | <agreed approach, ready to apply> |
| 3 | DISCUSSING | <description> | <latest thinking> |
| 4 | PARKED | <description> | <why it's on hold> |

Status meanings:
- DISCUSSING: actively being talked through, no decision yet
- AGREED: user and agent aligned on what to do, waiting for user to say "do it"
- DONE: code change applied and committed
- PARKED: noted for later, not acting on it now

## Completed changes

> Append only.

- <date> `<commit msg>`: item #N — <one-line description>

## Off-plan changes

> Append only. Each entry notes that the user approved the deviation.

- <date> `<commit msg>`: item #N — <what changed and why it deviates from plan.md>
```

Update `refine.md` after every discussion turn and after every commit.

## Discussion mode (default)

- When the user raises a point about the code, add it to the Items table as DISCUSSING.
- Offer analysis, trade-offs, and suggestions — but do not touch any files.
- When you and the user converge on an approach, move the item to AGREED and describe the agreed approach in the Notes column.
- If the user says to park something for later, move it to PARKED.
- Multiple items can be open at once. The user drives which ones to focus on.

## Applying changes (only when told)

The user must explicitly tell you to apply a change (e.g. "do it", "apply that", "go ahead", "make the change"). Only then:

- Apply the agreed change surgically. One commit per item.
- Commit messages must **not** use the `[plan]` prefix. Use standard conventional commits.
- Run relevant tests after every change. If a test breaks, fix it before moving on.
- Mark the item as DONE in the table and append to Completed changes.
- If the change deviates from `plan.md`, also append to Off-plan changes.
- Follow all applicable workspace rules (`coding-principles`, `code-comments`, `cpp-standards` when writing C++). Personal rules override repo-local rules on conflict.
- After committing the code change, also `git add` and commit the updated `refine.md` with message: `docs(refine): update refinement log for <branch-slug>`

## Boundaries

- **Never edit `plan.md`.** It is a frozen record of design intent.
- **Never edit `implement.md`.** That belongs to the implementation agent.
- **Never edit `investigate.md`.** That belongs to the investigation agent.
- **Never apply code changes without explicit user approval.**
- For off-plan changes: flag them as such during discussion, before the user agrees. No surprises.
