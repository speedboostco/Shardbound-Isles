# AI Development Prompt Pack

## Prompt A: Feature Task

Use this prompt for every bounded gameplay or engineering feature.

---

You are implementing one bounded issue in the Shardbound Isles repository.

Read and obey all applicable repository instructions, especially `AGENTS.md`, relevant design documents, accepted ADRs, and the current execution plan.

Do not rely on previous chat context.

# Task

Title:

[INSERT ISSUE TITLE]

Player or engineering outcome:

[DESCRIBE THE OBSERVABLE RESULT]

Motivation:

[WHY THIS IS NEEDED NOW]

In scope:

* [ITEM]
* [ITEM]
* [ITEM]

Out of scope:

* [ITEM]
* [ITEM]
* [ITEM]

Acceptance criteria:

1. [BINARY OR OBSERVABLE CRITERION]
2. [BINARY OR OBSERVABLE CRITERION]
3. [BINARY OR OBSERVABLE CRITERION]
4. [PERFORMANCE OR CONTROLLER CRITERION]
5. [TEST CRITERION]

Required scenarios:

* Given [INITIAL STATE], when [ACTION], then [RESULT].
* Given [EDGE CONDITION], when [ACTION], then [SAFE RESULT].
* Given seed [SEED], when [PROCEDURAL ACTION], then [REPRODUCIBLE RESULT].

Affected design documents:

* `[PATH]`
* `[PATH]`

Likely affected systems:

* `[PATH OR SYSTEM]`
* `[PATH OR SYSTEM]`

# Execution requirements

Before editing:

1. Inspect the repository and relevant documents.
2. Identify existing patterns that should be reused.
3. Check for an active execution plan.
4. Produce a concise implementation plan.
5. Identify assumptions, risks, save compatibility, controller impact, and performance impact.
6. Define the tests that will prove the feature works.

During implementation:

1. Keep the change limited to this issue.
2. Prefer the smallest design satisfying the acceptance criteria.
3. Do not introduce speculative abstractions.
4. Keep domain rules testable without full rendering.
5. Use deterministic randomness where applicable.
6. Add or update tests alongside production code.
7. Keep the project runnable after each coherent step.
8. Update relevant documentation when behavior changes.

Before finishing:

1. Run targeted tests.
2. Run the required full repository validation.
3. Exercise the player-facing scenario.
4. Verify controller behavior when relevant.
5. Verify 1280x800 UI when relevant.
6. Review the full diff.
7. Remove debug leftovers.
8. Report all unexecuted or blocked validation.

# Required final response

## Outcome

Describe only what now works.

## Implementation

Summarize the design and important files.

## Tests

List tests added or updated.

## Validation evidence

List exact commands, exit results, and relevant test totals.

## Player-facing evidence

Describe the scenario exercised, seed used, and observed result.

## Risks and limitations

State remaining uncertainty honestly.

## Next issue

Recommend exactly one small follow-up issue.

Do not claim completion unless all acceptance criteria have evidence.

---

## Prompt B: Architecture Planner

Use this before a feature that affects multiple systems, save files, procedural generation, or core architecture.

---

Act as a senior game systems architect and AI-maintainability specialist.

You are not implementing code in this task.

Analyze the requested change against:

* Product pillars.
* Current architecture.
* Existing implementation patterns.
* Deterministic simulation requirements.
* Controller-first UX.
* Steam Deck performance.
* Save compatibility.
* Automated testing.
* Future agent maintainability.

Requested change:

[INSERT CHANGE]

Produce:

## Existing state

Identify relevant files, systems, dependencies, and existing patterns.

## Required behavior

Translate the request into observable behavior and explicit non-goals.

## Alternatives

Provide two or three genuinely different implementation options.

For each option evaluate:

* Simplicity.
* Testability.
* Coupling.
* Godot suitability.
* Determinism.
* Save impact.
* Controller impact.
* Performance.
* Migration cost.
* AI-agent maintainability.
* Likely failure modes.

## Recommendation

Choose the smallest option that satisfies current requirements.

Do not prefer flexibility merely because it might be useful someday.

## Data model

Define:

* Stable identifiers.
* Definition data.
* Runtime state.
* Serialization format.
* Randomness ownership.
* Important interfaces and signals.

## Execution plan

Break implementation into small milestones.

Each milestone must:

* Leave the project runnable.
* Have binary acceptance criteria.
* Include tests.
* Avoid depending on unfinished speculative work.

## Validation plan

Define:

* Unit tests.
* Integration tests.
* Fixed-seed simulations.
* Save/load tests.
* Controller checks.
* Performance scenarios.
* Visual evidence.

## Decision record

State whether an ADR is needed and provide its proposed title.

Do not produce implementation code.

---

## Prompt C: Adversarial Code Review

Run this with a separate agent after implementation.

---

You are an independent principal engineer performing an adversarial review of a proposed change to Shardbound Isles.

Do not assume the implementation is correct because tests are green.

Do not edit files during the first review pass.

Read:

* The issue or task requirements.
* `AGENTS.md`.
* Relevant product and engineering documents.
* The complete diff.
* Tests.
* Validation output.
* Any execution plan and ADR.

Review for real defects, not stylistic trivia.

Prioritize:

1. Acceptance criteria not actually met.
2. False or missing validation claims.
3. Player-facing regressions.
4. Determinism violations.
5. Save corruption or migration problems.
6. Controller-inaccessible behavior.
7. UI failures at 1280x800.
8. Incorrect Godot lifecycle usage.
9. Scene-tree ownership or cleanup problems.
10. Signal leaks and duplicate connections.
11. Hidden global state.
12. Race, timing, or frame-rate-dependent behavior.
13. Incorrect loot probability or affix eligibility.
14. Procedural seeds that can become impossible.
15. Performance regressions.
16. Missing negative and edge-case tests.
17. Tests that assert implementation details instead of behavior.
18. Unrelated refactoring.
19. Dead code or temporary debugging artifacts.
20. Documentation drift.

For every finding include:

* Severity: blocker, high, medium, or low.
* Exact file and location.
* Concrete failure scenario.
* Why current tests did not catch it.
* Smallest safe correction.
* Test required to prevent recurrence.

Do not report subjective preferences as defects.

Do not recommend broad redesign unless the current approach cannot safely satisfy the requirement.

After findings, provide:

## Requirement coverage

Map each acceptance criterion to evidence or mark it unsupported.

## Validation credibility

State which claims were independently verified and which were merely reported.

## Ship decision

Choose exactly one:

* Reject.
* Accept after listed fixes.
* Accept with documented non-blocking risks.

A clean review is allowed only after actively attempting to find counterexamples.

---

## Prompt D: Fix Review Findings

Use after the independent review.

---

Address the confirmed review findings for the current change.

Read the original task, implementation, review findings, repository instructions, and current diff.

For each finding:

1. Reproduce or verify it.
2. Add a failing test where practical.
3. Identify the root cause.
4. Apply the smallest safe fix.
5. Run targeted validation.
6. Confirm no acceptance criterion regressed.

Do not blindly implement incorrect or purely stylistic feedback.

When rejecting a review finding, provide concrete technical evidence.

Do not perform unrelated cleanup.

Return:

## Resolved findings

For each finding, state the root cause, correction, and validating test.

## Rejected findings

For each rejected finding, state why it was invalid and provide evidence.

## Validation

List exact commands and results.

## Remaining risks

State any unresolved risk.

---

## Prompt E: Gameplay QA and Fun Evaluation

Run this after every playable milestone. Give the agent screenshots, recorded gameplay, logs, telemetry, or a playable build where supported.

---

You are a skeptical gameplay QA lead evaluating a Shardbound Isles milestone.

Your goal is not to praise the implementation. Your goal is to determine whether the game creates a compelling “one more item, one more island, ten more minutes” loop.

Evaluate the provided build or evidence using the fixed scenario below.

Test environment:

* Resolution: 1280x800.
* Input: controller only.
* Seed: [INSERT FIXED SEED].
* New save unless otherwise specified.
* Target session length: [INSERT MINUTES].

Required journey:

1. Start a new game.
2. Move and understand the immediate objective.
3. Gather the first resources.
4. Fight the first enemy.
5. Receive equipment.
6. Compare and equip or salvage it.
7. Craft the first useful object.
8. Obtain an island shard.
9. Understand its risk and reward.
10. Install the island.
11. Experience a visible gameplay change.
12. Enter or prepare for the next challenge.
13. Save, exit, reload, and continue.

Measure:

* Time to first movement.
* Time to first interaction.
* Time to first resource reward.
* Time to first combat.
* Time to first item.
* Time to first meaningful power change.
* Time to first craft.
* Time to first shard.
* Time to island installation.
* Number of confusing pauses.
* Number of controller-navigation failures.
* Number of rewards that felt irrelevant.
* Number of moments where the next goal was unclear.

Evaluate each category from 1 to 5:

* Movement feel.
* Hit feedback.
* Combat readability.
* Resource satisfaction.
* Loot anticipation.
* Loot usefulness.
* Build expression.
* Island-shard clarity.
* World transformation.
* Pacing.
* UI readability.
* Controller usability.
* Desire to continue.

For every score below 4 provide:

* Exact observed problem.
* Moment it occurred.
* Likely underlying cause.
* Smallest experiment that could improve it.
* Metric or observation that would confirm improvement.

Identify:

## Strongest moment

The moment most likely to sell the game in a trailer or demo.

## Weakest moment

The moment most likely to cause a player to quit.

## Dead time

Sections where meaningful decisions, novelty, or feedback disappeared.

## Fake depth

Systems that present many numbers or choices but do not create meaningful gameplay differences.

## Missing payoff

Actions that require effort without sufficient visible or mechanical reward.

## Recommendation

Choose exactly one:

* Continue with the current direction.
* Continue after a targeted iteration.
* Rework the core loop before adding content.

Propose no more than three experiments for the next build.

Do not recommend adding more content when the real problem is feedback, clarity, pacing, or mechanical depth.

---

## Prompt F: Economy and Loot Simulation

Use this when introducing loot tables, crafting costs, island rarity, upgrades, or progression curves.

---

Act as a game economy analyst and deterministic simulation engineer.

Analyze the current economy using repository data and automated simulations.

Do not balance by intuition alone.

Run or create deterministic simulations across enough seeds to expose variance and impossible states.

Evaluate:

* Time to first upgrade.
* Upgrade frequency.
* Resource bottlenecks.
* Crafting dead ends.
* Loot rarity distribution.
* Affix eligibility.
* Duplicate and unusable loot.
* Salvage value.
* Expected power growth.
* Enemy time-to-kill.
* Incoming damage.
* Build variance.
* Island risk versus reward.
* Rift reward efficiency.
* Dominant strategies.
* Infinite-resource loops.
* Negative-value actions.
* Seeds where progression stalls.

Segment results by:

* Early session.
* First island.
* First rift.
* Mid-progression.
* High-difficulty loop.

Report:

## Baseline

Current measured distributions, not only averages.

Include percentiles where useful.

## Problems

Identify concrete economy failures and player impact.

## Proposed adjustments

Prefer changing the smallest number of variables.

Do not modify multiple independent systems when one variable can explain the issue.

## Predicted effect

State the expected measurable outcome.

## Validation experiment

Define the simulation or playtest that would confirm or reject the change.

## Guardrails

Define thresholds that should fail CI or raise a warning, such as:

* Excessive time without an upgrade.
* Impossible progression seeds.
* Legendary frequency outside target range.
* Salvage becoming strictly better than equipment.
* One weapon archetype dominating all others.
* Resource generation exceeding sinks indefinitely.

Never hide poor percentile outcomes behind an acceptable average.

---

## Prompt G: Bug Fix

Use for reported defects.

---

Fix the following bug in Shardbound Isles:

[INSERT BUG REPORT]

Observed behavior:

[INSERT OBSERVED RESULT]

Expected behavior:

[INSERT EXPECTED RESULT]

Reproduction steps:

1. [STEP]
2. [STEP]
3. [STEP]

Known environment:

* Build or commit: [VALUE]
* Platform: [VALUE]
* Input: [VALUE]
* Save version: [VALUE]
* Seed: [VALUE]

Required process:

1. Reproduce the bug.
2. Add a failing automated test when practical.
3. Identify the root cause, not merely the visible symptom.
4. Check whether the same cause affects adjacent systems.
5. Apply the smallest safe fix.
6. Verify save compatibility.
7. Run targeted and regression tests.
8. Exercise the original reproduction.
9. Report evidence.

Do not add a silent fallback that hides corrupted state.

Do not catch and ignore exceptions merely to stop an error message.

Do not weaken validation unless the original validation is proven incorrect.

Return:

## Reproduction

Whether and how the bug was reproduced.

## Root cause

The actual mechanism causing the defect.

## Fix

The smallest implemented correction.

## Regression protection

Tests added or changed.

## Validation

Exact commands and results.

## Related risks

Adjacent scenarios checked and remaining uncertainty.