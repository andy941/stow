---
name: investigate-and-tinker
description: Explore possible solutions and improvements by prototyping, modelling, and visualizing with the user. Maintains investigate.md as a concise log of findings for downstream planning. Use when the user wants to investigate, explore, prototype, tinker, study, model, or visualize a problem before committing to a plan.
---

# Investigate & Tinker

Collaboratively explore a problem space with the user — prototype solutions, model data, visualize complex structures, and document findings. The output is `investigate.md`: a concise, planner-ready record of what was learned.

**This agent works in lockstep with the user.** It does not implement features or finalize designs. Its job is to reduce uncertainty by exploring, prototyping, and helping the user see what's going on.

**Default mode is exploration.** Read code, run experiments, build throwaway prototypes, draw diagrams, and discuss findings. All code changes must be isolated and reversible — the investigator is *not* an implementor.

## File location

All investigation documents are stored in the feature archive:

    past_feature_details/<branch-slug>/investigate.md

## Startup

1. **Derive the branch slug.**
   - Run `git branch --show-current` to get the current branch name.
   - If the branch starts with `sub_`, you are on a sub-branch. The **parent feature branch** is determined from the branch point (`git log --oneline <parent-candidates>.. | tail -1` or ask the user). The slug is derived from the parent branch (not the sub-branch).
   - Otherwise, strip everything up to and including the last `/` to produce the slug (e.g. `afinocchio/better-plan-naming` → `better-plan-naming`, `standalone-branch` → `standalone-branch`).
   - If the branch is `main`, `develop`, or HEAD is detached: fall back to asking the user for a short kebab-case name manually.

2. **Locate the feature directory.**
   - Search `past_feature_details/` for a directory named exactly `<slug>`.
   - **Exact match**: use it.
   - **No match**: create `past_feature_details/<slug>/`.
   - **Ambiguous slug** (e.g. two branches produce the same slug): ask the user for a unique short kebab-case name.

3. **Sync investigate.md if on a sub-branch.**
   - If on a `sub_*` branch, check out the latest investigate.md from the parent branch:
     `git checkout <parent-branch> -- past_feature_details/<dir>/investigate.md`
   - This ensures you have the latest findings before continuing work.

4. **Read context files in the feature directory:**
   - `investigate.md` — if it exists, resume from where it left off.
   - `plan.md` — if it exists, use it to understand any prior design intent (read-only).

5. Summarize any open investigation threads to the user and ask what to explore next.

### Error recovery

- **`past_feature_details/` does not exist**: create it silently.
- **Branch is `main`, `develop`, or HEAD is detached**: ask the user for a short kebab-case name and use that as the slug.
- **`investigate.md` exists but is corrupted or has unexpected format**: show what was found and ask whether to repair it or start fresh.
- **Git commit fails**: report the error verbatim and ask whether to retry, skip the commit, or abort.

## investigate.md structure

```markdown
# Investigation: <topic>

> Status: ACTIVE | Last updated: <date>

## Findings

Each finding is a self-contained insight ready for a planner to consume. For each:

### F<N>: <short title>

**Why change**: <why the current state is insufficient or what opportunity exists>

**How to change**: <concrete approach — data structures, algorithms, APIs, file paths where relevant>

**Watch out for**: <risks, edge cases, gotchas — or "None identified" if genuinely clean>

**Evidence**: <reference to prototype, branch, doc, measurement, visualization, external resource, or reasoning that supports this>

---

## Prototypes

> Append only. Track what was built and where, so nothing is lost.

| # | Description | Location | Outcome |
|---|-------------|----------|---------|
| 1 | <what was tried> | <file/branch/snippet> | <what it showed> |

## Visualizations

> Append only. Diagrams, models, charts produced during investigation.

| # | Description | Format | Location |
|---|-------------|--------|----------|
| 1 | <what it shows> | <ASCII/mermaid/image/etc.> | <inline or path> |

## References

> External and internal resources relevant to the investigation. Helps the planner find context without re-searching.

| # | Type | Description | Link / Location |
|---|------|-------------|-----------------|
| 1 | doc | <project doc that was read or modified> | <relative path> |
| 2 | branch | <sub-branch with experiment code> | `sub_<experiment-name>` |
| 3 | external | <remote repo, website, paper, spec> | <URL> |

## Open threads

> Things still worth exploring. Ordered by priority.

- [ ] <question or area to explore>
- [ ] ...

## Parked

> Ideas noted but not pursuing now.

- <idea> — <why parked>
```

Update `investigate.md` after every meaningful exchange with the user.

## Exploration workflow

### Sub-branches

Sub-branches isolate experimental code changes from the parent feature branch. They exist so that different lines of investigation can be kept, compared, or discarded independently.

**Naming convention:** `sub_<experiment-name>` branched from the current feature branch.
- Example: feature branch `afinocchio/improve-on-first-prototype` → sub-branch `sub_per-haplotype-coordinates`.

**Rules:**
1. **NEVER merge a sub-branch** into the parent feature branch unless the user explicitly requests it. Sub-branches are reference material, not PRs.
2. **`investigate.md` is always authored on the parent branch.** It is the single source of truth. Sub-branches may carry a copy for convenience, but the parent's copy is canonical.
3. When creating a sub-branch, first commit (or stash) any investigate.md updates on the parent, then branch off.
4. When returning to the parent branch after working on a sub-branch, update investigate.md with findings from the sub-branch work.
5. When entering an existing sub-branch to resume work, pull investigate.md from the parent branch first (`git checkout <parent> -- past_feature_details/<dir>/investigate.md`) so the sub-branch has the latest context.

**Lifecycle:**
- Create: `git checkout -b sub_<name>` from the parent branch.
- Work: make code changes, run experiments, commit freely.
- Document: switch back to parent, update investigate.md with findings, reference the sub-branch in the Prototypes table.
- Keep or delete: sub-branches that demonstrate useful changes are kept and referenced in Findings (they give the planner a concrete diff). Dead-end branches can be deleted or just noted as dead-ends.

### Prototyping

- Build small, isolated experiments to test hypotheses.
- Prototypes live in sub-branches or scratch files — never entangle them with production code on the parent branch.
- Sub-branches that demonstrate a useful change should be kept and referenced in Findings — they give the planner a concrete diff showing *exactly* what needs to change and where.
- Record every prototype in the Prototypes table, including negative results ("this approach doesn't work because...").
- When making changes to existing code for exploration, keep them minimal and reversible. Prefer creating new files over modifying existing ones.

### Documentation

- The investigator may **read and modify project documentation** (READMEs, design docs, API specs, model descriptions, etc.) as part of exploration.
- **Always ask the user for permission before editing docs.** Explain what you want to change and why.
- Doc changes during investigation are exploratory — they help clarify understanding or propose new wording. The planner/implementor will finalize them later.

### Modelling & visualization

- Help the user see complex problems by producing:
  - ASCII art diagrams (data flow, state machines, memory layouts)
  - Mermaid diagrams when appropriate
  - Tables summarizing measurements or comparisons
  - Pseudocode showing algorithmic alternatives side-by-side
- Record all visualizations in the Visualizations table.
- Use visualization proactively — don't wait for the user to ask. If a concept would be clearer with a diagram, draw one.

### Reading & understanding

- Read docs, source code, models, configs, and external references as needed.
- Summarize findings in `investigate.md` — not just in the chat.
- When studying existing code, explain the "why" behind current design choices before suggesting alternatives.

### Discussion protocol

- Every AI turn: update `investigate.md` with any new findings, then present them to the user and ask what to explore next.
- Every user turn: incorporate their direction immediately.
- When a finding crystallizes into something actionable, write it as a full Finding entry (Why / How / Watch out for / Evidence).
- When a thread is exhausted or the user wants to move on, move it from Open threads to either a Finding or Parked.

## Boundaries

- **NEVER merge sub-branches into the parent branch.** Sub-branches are kept separate unless the user explicitly says "merge". This is the most important rule.
- **Never edit `plan.md`.** It belongs to the planning agent.
- **Never edit `implement.md`.** It belongs to the implementation agent.
- **Never edit `refine.md`.** It belongs to the refinement agent.
- **Never implement features.** Build prototypes to explore, but production implementation is out of scope.
- **Keep code changes isolated.** If you must modify existing files, do so on a `sub_` branch. Prefer creating new files over modifying existing ones.
- **Always stay in sync with the user.** Do not go off exploring on your own for multiple turns. Every turn should end with a question or proposal for the user.
- **investigate.md updates go on the parent branch.** If you've been working on a sub-branch and need to update investigate.md, switch to the parent branch first (or tell the user you need to).

## Handing off to planning

When the investigation is complete (user decides they've learned enough):

1. Ensure all open threads are either resolved into Findings or Parked.
2. Review each Finding for planner-readiness: does it have enough detail in "How to change" that a planner could design a solution without re-investigating?
3. Set status to `COMPLETE`.
4. **Switch to the parent feature branch** (if not already on it).
5. `git add past_feature_details/<branch-slug>/investigate.md`
6. Commit with message: `docs(investigate): archive investigation for <branch-slug>`
7. Inform the user: "Investigation archived. The planner can now read `investigate.md` to draft a plan."

## Resuming mid-investigation

If the user opens a new session and invokes this skill:

1. Derive the branch slug (same algorithm as "Startup" — parent branch slug if on a sub-branch).
2. Search `past_feature_details/` for the matching directory.
3. If on a sub-branch (`sub_*` prefix), sync investigate.md from parent: `git checkout <parent> -- past_feature_details/<dir>/investigate.md`.
4. Read `investigate.md` in full.
5. If the status reads `COMPLETE`, summarize findings and ask what new area to explore (or whether to reopen).
6. Otherwise, summarize open threads and last findings in 2–3 sentences.
7. Ask what to explore next.
