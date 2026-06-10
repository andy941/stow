---
name: implement-plan
description: Implement a feature exactly as described in plan.md at the project root. No planning, no questions, no plan edits. Use when the user says to implement the plan, execute the plan, or run the implementation.
---

# Implement Plan

Read `plan.md` and implement it exactly as written. Do not ask questions. Do not edit `plan.md`. Do not improvise beyond what the plan specifies.

Maintain `implement.md` in the same feature archive directory as a live progress log. It is the first thing read when resuming and the last thing updated after each step.

## File location

All implementation documents are stored alongside the plan:

    past_feature_details/<branch-slug>/implement.md

## Startup

1. **Derive the branch slug.**
   - Run `git branch --show-current` to get the current branch name.
   - Strip everything up to and including the last `/` to produce the slug (e.g. `afinocchio/better-plan-naming` → `better-plan-naming`, `standalone-branch` → `standalone-branch`).
   - If the branch is `main`, `develop`, or HEAD is detached: fall back to asking the user for a short kebab-case name manually.

2. **Locate the feature directory.**
   - Search `past_feature_details/` for a directory named exactly `<slug>`.
   - **Exact match**: use it.
   - **No match**: inform the user that no feature directory was found for branch slug `<slug>`. Ask if there is a plan elsewhere or if they need to run the planning skill first.
   - **Ambiguous slug** (e.g. two branches produce the same slug): ask the user for a unique short kebab-case name.

3. **Verify the plan is ready.**
   - Read `plan.md` in the feature directory. If it does not exist, inform the user.
   - If the plan status is not `FINAL`, inform the user: "The plan for `<slug>` is still in `<status>` state. Implementation requires a FINAL plan." Ask whether to proceed anyway or go back to planning.

4. **Check for existing `implement.md`.**
   - If it exists: read it, resume from the first incomplete step. Skip all completed steps.
   - If not: create it from the template below.

5. Read `plan.md` in full if not already read.
6. If `investigate.md` exists in the feature directory, read it for additional context on design decisions and their rationale.

### Error recovery

- **`past_feature_details/` does not exist**: create it, then inform the user no plans were found.
- **Branch is `main`, `develop`, or HEAD is detached**: ask the user for a short kebab-case name and use that as the slug.
- **Feature directory exists but `plan.md` is missing**: tell the user "I found directory `<dir>` but it has no plan.md." Ask: "Is there a plan elsewhere I should use, or should we start fresh?"
- **`plan.md` is corrupted or unparseable**: show what was found and ask how to proceed.
- **Git commit fails**: report the error verbatim and ask whether to retry, skip the commit, or abort.
- **File referenced in `implement.md` no longer exists at expected path**: search `past_feature_details/` for the file by name. If found elsewhere, ask the user to confirm before using it.

## Resuming

If `implement.md` already exists, read it before anything else. It contains the current progress state. Skip all completed steps and continue from the first incomplete one. Do not redo work already marked done.

## implement.md structure

```markdown
# Implementation Progress

> Plan: <feature name> | Started: <date> | Status: IN PROGRESS | DONE

## Steps

- [x] Step 1: <one-line description> — done
- [x] Step 2: <one-line description> — done
- [ ] Step 3: <one-line description> — in progress
- [ ] Step 4: <one-line description> — pending

## Test status

- [ ] Tests written
- [ ] All tests confirmed failing (pre-implementation)
- [ ] All tests passing (post-implementation)

## Deviations & issues

> Append only. Do not edit past entries.

- <date> Step N: <what happened and what was done>
```

Update `implement.md` after every completed step. Never delete or edit past entries in the Deviations section — append only.

## Execution

1. If `implement.md` exists, read it — resume from the first incomplete step. Otherwise read `plan.md` in full and create `implement.md` from the template above.
2. If no `plan.md` exists, stop and tell the user.
3. If the plan status is not `FINAL`, stop and tell the user — only implement a finished plan.
4. **Write tests first.** Implement all unit tests from section 7 before writing any logic. Mark "Tests written" in `implement.md`.
5. **Verify all tests fail.** Run the test suite and confirm every new test fails. Mark "All tests confirmed failing" in `implement.md`. If any test passes before implementation, stop and record it as a deviation.
6. Execute section 10 (Subagent Breakdown):
   - Dispatch parallel groups concurrently as specified.
   - Respect the sequential ordering between groups.
   - Use fast agents for steps marked as such.
7. Implement every step in section 5 exactly as written — exact file paths, function names, and types specified in the plan. Mark each step complete in `implement.md` as it finishes.
8. **Verify all tests pass.** Run the full test suite. Mark "All tests passing" in `implement.md`. If tests fail, fix the bug using the minimal change that makes the test pass without deviating from the plan's design. If fixing a failure requires changing the design, do not do it — record it as a deviation in `implement.md` instead.
9. After completing each commit's steps (per section 9 Commit Plan), create a git commit with the exact message specified in the plan. All such messages must include the `[plan]` prefix as written — do not omit it.

## Constraints

- **Never edit `plan.md`.**
- **Never edit `investigate.md`.** That belongs to the investigation agent.
- **Never ask the user a question** (except during error recovery at startup).
- Follow all applicable workspace rules (`coding-principles`, `code-comments`, `cpp-standards` when writing C++). Personal rules override repo-local rules on conflict.
- If something in the plan is ambiguous, make the most literal interpretation and note it in the final report.
- If a step cannot be completed, skip it, continue with the rest, and note it in the final report.

## Finalizing

When all steps are done:

1. Set `implement.md` status to `DONE`.
2. `git add past_feature_details/<date>_<branch-slug>/implement.md`
3. Commit with message: `docs(impl): archive implementation log for <branch-slug>`
4. Output the final report.

## Final report

When all steps are done, output a concise report covering **only deviations and problems**:

- Steps that could not be completed and why.
- Tests that passed before implementation (indicating a pre-existing behaviour or a bad test).
- Tests that still fail after implementation, and what was attempted.
- Bugs fixed during implementation and the minimal change made.
- Ambiguities that required a judgment call, and what was chosen.
- Anything that was skipped.

If everything was implemented exactly as planned and all tests pass, the report is: `All steps completed as planned. All tests pass.`

Do not summarize what was built. Do not list completed steps.
