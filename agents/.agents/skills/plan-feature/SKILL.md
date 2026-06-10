---
name: plan-feature
description: Iteratively plan a feature with the user by maintaining a detailed plan.md file at the project root. Covers data flow, structures, transformations, and subagent breakdown. Use when the user wants to plan a feature, design a system, create a technical spec, or work on a plan.md file.
---

# Plan Feature

Collaboratively build a detailed `plan.md` through iterative AI-user refinement. The plan is the source of truth — deep thinking now makes implementation the easy part.

**The bar for "done"**: a separate agent with no prior context must be able to open `plan.md` and implement the feature immediately, without asking any clarifying questions or doing any design work.

**Immutability rule**: once the plan reaches full `[FINAL]` status it is frozen for all agents *except* the planning agent (i.e. the agent running this skill). Implementation agents must never edit it — not to fix typos, not to incorporate new information, not to reflect what was actually built. The final plan is a permanent record of the design intent. Any follow-on work that requires a material change should be brought back to the planning agent, which will revise the plan in a new session.

## File location

All planning documents are stored in the feature archive:

    past_feature_details/<branch-slug>/plan.md

Where `<branch-slug>` is derived automatically from the current git branch (see "Starting a session").

## Workflow

### Starting a session

1. **Derive the branch slug.**
   - Run `git branch --show-current` to get the current branch name.
   - Strip everything up to and including the last `/` to produce the slug (e.g. `afinocchio/better-plan-naming` → `better-plan-naming`, `standalone-branch` → `standalone-branch`).
   - If the branch is `main`, `develop`, or HEAD is detached: fall back to asking the user for a short kebab-case name manually.

2. **Locate the feature directory.**
   - Search `past_feature_details/` for a directory named exactly `<slug>`.
   - **Exact match**: use that directory.
   - **No match**: create `past_feature_details/<slug>/`.
   - **Ambiguous slug** (e.g. two branches produce the same slug): ask the user for a unique short kebab-case name.
   - Set the matched/created directory as the working directory for all plan files.

3. **Read context files in the feature directory.**
   - `plan.md` — if it exists, read it fully, identify the current state, and continue where it left off. If not, create it with the template below, seeding any lines the user provided.
   - `investigate.md` — if it exists, read it in full. Its Findings section contains validated exploration results (Why / How / Watch out for) and may reference sub-branches (`sub_<name>`) showing exact diffs. **Do not adopt investigation findings verbatim.** The investigator identifies *what* to change and *where*; the planner's job is to re-elaborate those raw insights into a high-quality design — considering architecture, data flow, edge cases, and how changes compose with each other. **Never merge sub-branches** — they are reference material only.

4. Announce what section/stage you're picking up from.
5. Begin the research and refinement loop.

### Error recovery

- **`past_feature_details/` does not exist**: create it silently.
- **Branch is `main`, `develop`, or HEAD is detached**: ask the user for a short kebab-case name and use that as the slug.
- **`plan.md` exists but is corrupted or has no status header**: inform the user, show what was found, and ask how to proceed (repair or start fresh).
- **Git commit fails** (at finalization): report the error verbatim and ask whether to retry, skip the commit, or abort.

### Research loop

For each open or underdeveloped section:

1. Use **fast subagents** to gather facts (grep codebase, read files, search docs).
2. Synthesize findings into the plan — be specific, not generic.
3. Write a clear `<!-- TODO: ... -->` comment for anything still unresolved.
4. After each batch of updates, summarize the changes to the user and ask focused questions to resolve open TODOs.

### Iteration protocol

- Every AI turn: update `plan.md`, then ask the user **one focused question** to unblock the next section.
- Every user turn: incorporate feedback into `plan.md` immediately.
- Mark sections `[DRAFT]`, `[REVIEWED]`, or `[FINAL]` in their headings.
- Always leave a blank line before and after any markdown list (bulleted or numbered) to avoid rendering artifacts.
- The plan is done when all sections are `[FINAL]`, no `<!-- TODO -->` comments remain, and the plan passes the **implementability test**: could a fresh agent read only this file and implement everything without asking a single question? If not, it is not done.
- Once the overall status is set to `FINAL`, the file is **frozen for implementation agents**. Only the planning agent (this skill) may edit it after that point.

### Finalizing

When the plan reaches `[FINAL]` status:

1. `git add past_feature_details/<branch-slug>/plan.md`
2. Commit with message: `docs(plan): archive final plan for <branch-slug>`

---

## plan.md Template

Use this structure. Omit sections that truly don't apply; never leave them blank.

```markdown
# Feature Plan: <name>

> Status: DRAFT | Last updated: <date>

## 1. Goal [DRAFT]

One paragraph: what problem does this solve and for whom?

## 2. Scope [DRAFT]

### In scope
- ...

### Out of scope
- ...

## 3. Data Design [DRAFT]

The most important section. For every stage of the feature:

### 3.1 Inputs
| Name | Type | Source | Notes |
|------|------|--------|-------|

### 3.2 Core data structures
```
// Pseudocode or real structs/types
struct Foo {
  id: u64,
  ...
}
```

### 3.3 Transformations
Describe each transformation step as:
  Input → Operation → Output

### 3.4 Outputs / side effects
| Name | Type | Destination | Notes |
|------|------|-------------|-------|

## 4. Architecture [DRAFT]

- Component/module breakdown
- Boundaries and interfaces between components
- Key design decisions and rationale

## 5. Implementation Steps [DRAFT]

Ordered list of concrete tasks. Each task must be self-contained enough that an agent can execute it with no additional context beyond this file. Include exact file paths, function names, type names, and expected outputs where relevant.

1. ...
2. ...

## 6. Edge Cases & Error Handling [DRAFT]

- ...

## 7. Testing Strategy [DRAFT]

Tests are written **before** the implementation. The implementation step in section 5 must have "write tests" as one of its earliest entries, placed before any logic is written.

### Unit tests (written first)

A small number of meaningful tests — not exhaustive coverage, but tests that would catch a broken implementation. For each test specify:

| Test name | Input | Expected output | What it proves |
|-----------|-------|-----------------|----------------|
| `test_foo_empty` | empty input | `Error::Empty` | rejects degenerate case |
| `test_foo_basic` | minimal valid input | correct output | happy path works |

All listed tests must fail (compilation aside) before implementation begins. This is verified explicitly before writing any logic.

### Bug fixing rule

Unit tests may be used to diagnose and fix bugs found during implementation. However, fixing a bug is not a license to change the design or add scope not in the plan. If a bug cannot be fixed without changing the design, it must be reported as a deviation — not silently worked around.

### Integration / manual verification

- ...

## 8. Open Questions [DRAFT]

- <!-- TODO: ... -->

## 9. Commit Plan [DRAFT]

Define the commit sequence a reviewer will follow when reading the PR. Each commit must be a coherent, reviewable unit — a reviewer should be able to understand it in isolation.

| # | Commit message | Steps included | Notes |
|---|----------------|----------------|-------|
| 1 | `type(scope): short imperative description` | Step 1 | e.g. foundation types, no logic yet |
| 2 | `type(scope): ...` | Step 2, Step 3 | ... |

**Rules:**
- Order commits so the diff tells a story: foundational types first, then **tests** (failing), then logic, then wiring.
- One logical change per commit — never mix refactors with feature additions.
- Message format: `[plan] type(scope): short imperative description` (e.g. `[plan] test(parser): add failing unit tests`, `[plan] feat(parser): add token stream struct`).
- The `[plan]` prefix marks this commit as part of the original planned implementation. All other commits (fixes, reviewer comments, touchups) must not use it.
- Avoid commits that only make sense together; each must leave the codebase in a buildable state.

## 10. Subagent Breakdown [DRAFT]

Map every implementation step to an execution slot. A fresh orchestrating agent must be able to read this section and dispatch work immediately.

### Parallel groups

Steps within the same group have no dependencies on each other and can run concurrently.

| Group | Step(s) | Fast agent? | Reason |
|-------|---------|-------------|--------|
| A | Step 1, Step 3 | Yes | Independent file edits, no shared state |
| B (after A) | Step 2 | No | Requires reasoning across outputs of A |
| C (after B) | Step 4, Step 5 | Yes | Mechanical, well-scoped |

### Dependency notes

Describe any ordering constraints not obvious from the table (e.g. "Step 4 needs the type defined in Step 2").

**Fast agent criteria**: mechanical edits, renames, boilerplate generation, grepping,
simple well-scoped changes. Use the default (capable) model for anything requiring
design judgment, subtle debugging, or cross-cutting changes.
```

---

## Data design guidelines

This section must be the most detailed. For every data structure:
- Name every field, its type, and its invariants.
- Describe ownership/lifetime if relevant (e.g. who allocates, who frees).
- Show the transformation chain explicitly: `raw input → parsed → validated → stored → returned`.
- Call out any lossy conversions or places where data is discarded.

Prefer tables for inputs/outputs, pseudocode structs for internal types.

---

## Workspace rules awareness

The plan must conform to all applicable workspace rules from the start. During research, read the active rules (particularly `coding-principles`, `code-comments`, and `cpp-standards` when the plan targets C++) so that data structures, naming, error handling, and documentation expectations are baked into the plan — not bolted on during implementation.

Personal rules override repo-local rules on conflict.

---

## Research with subagents

Spawn fast subagents for:
- Grepping the codebase for existing patterns to reuse
- Reading referenced files to extract types/interfaces
- Checking dependencies or build configs
- Summarizing existing tests

Always feed subagent findings directly back into `plan.md` — never just into the chat.

---

## Resuming mid-plan

If the user opens a new session and provides a prompt like "continue the plan" or "let's keep working on plan.md":

1. Derive the branch slug (same algorithm as "Starting a session").
2. Search `past_feature_details/` for the matching directory.
3. Read `plan.md` in full.
4. If the status header reads `FINAL`, summarize the current plan and ask what needs to change.
5. Otherwise, find the lowest-numbered section that is not `[FINAL]`.
6. Summarize the current state in 2–3 sentences.
7. Ask the single most important open question to move forward.
