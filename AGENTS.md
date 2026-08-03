# AGENTS.md

## Mission

Build Shardbound Isles: a commercial-quality single-player 2D top-down action RPG combining fast resource gathering, incremental progression, Diablo-style procedural loot, compact automation, and installable procedural islands.

The defining mechanic is:

> The world itself is loot.

Players build a character, a production base, and an archipelago from island shards.

## Start here

Before changing code, read the documents relevant to the task:

* Product vision: `docs/product/vision.md`
* Core loop: `docs/product/core-loop.md`
* Product pillars: `docs/product/product-pillars.md`
* Non-goals: `docs/product/non-goals.md`
* Current vertical slice: `docs/product/vertical-slice.md`
* Architecture: `docs/engineering/architecture.md`
* Testing: `docs/engineering/testing-strategy.md`
* Performance: `docs/engineering/performance-budgets.md`
* Controls: `docs/design/controls.md`
* Active plans: `docs/exec-plans/active/`
* Accepted decisions: `docs/decisions/`

Treat repository documentation as the system of record. Do not rely on prior chat context.

## Source precedence

When requirements conflict, use:

1. Current explicit task.
2. Accepted architecture decisions.
3. Product pillars and non-goals.
4. Feature design documents.
5. Engineering documentation.
6. Existing implementation patterns.
7. Assumptions in the active execution plan.

Do not silently resolve product-level conflicts.

## Hard product constraints

* Single-player.
* Fully playable offline.
* Godot 4.x stable.
* GDScript with static typing.
* Controller-first.
* Steam Deck target: 1280x800.
* Normal performance target: stable 60 FPS.
* Validated worst-case minimum: 30 FPS.
* No mandatory mouse, keyboard, touchscreen, or text input.
* No multiplayer unless explicitly approved.
* No always-online dependencies.
* No live AI generation in the shipped game.
* No punishing hunger or thirst.
* No destructive base raids.
* No microtransactions.
* No Steamworks dependency before the core loop is validated.

## Core design rules

* Every major system must reinforce the core loop.
* Island shards are procedural loot with meaningful modifiers.
* Interesting equipment changes behavior or creates synergies.
* Automation removes obsolete chores without replacing exploration or combat.
* Endless progression must add combinations and pressure, not only larger health values.
* Prefer a small polished feature over broad placeholder content.
* Do not generate content volume before proving the underlying system is fun.

## Architecture rules

* Prefer scene composition over deep inheritance.
* Keep feature assets close to their scenes.
* Separate pure game rules from rendering and scene behavior.
* Definitions and runtime state must be separate.
* Use typed Resources or typed data structures for definitions.
* Procedural systems must use explicit seeded randomness.
* Never use unseeded randomness in deterministic domain logic.
* UI must not own authoritative gameplay state.
* Avoid global mutable state.
* Minimize Autoloads.
* Do not use Autoloads as a generic service locator.
* Use signals for local decoupling.
* Introduce global event infrastructure only when a proven cross-feature requirement exists.
* Do not create giant Player, World, GameManager, Main, or Utils classes.
* Avoid circular dependencies.
* Save stable IDs and serializable state, not scene references.
* All saves require an explicit schema version.
* Incompatible save changes require migration or explicit rejection.
* Prefer clarity over cleverness.
* Do not add speculative abstraction without a current consumer.

## Task protocol

For nontrivial work:

1. Inspect existing code and documentation.
2. Find the active execution plan or create one.
3. State assumptions.
4. Define acceptance criteria.
5. Define tests before implementation.
6. Implement the smallest coherent change.
7. Run targeted validation.
8. Run full validation when appropriate.
9. Review the diff.
10. Update documentation and the execution plan.
11. Report evidence and limitations.

Do not start a broad refactor before identifying the concrete requirement it solves.

## Scope control

* Do not modify unrelated systems.
* Do not rename or reorganize broad sections of the repository as a side effect.
* Do not replace an established pattern without explaining why it is insufficient.
* Do not add dependencies when the standard library or existing project tooling is adequate.
* Do not silently change player-facing behavior.
* Do not remove compatibility without explicit acceptance criteria.
* Do not leave dead code, abandoned files, debug output, or commented-out implementations.

When additional issues are discovered, document them separately rather than expanding the current task indefinitely.

## Required command interface

Use the repository’s stable commands:

* `make help`
* `make setup`
* `make validate`
* `make test`
* `make test-unit`
* `make test-integration`
* `make test-simulation`
* `make export-windows`
* `make export-linux`

When a command is unavailable or broken, repair the command interface as part of the task when reasonably in scope.

Do not bypass the stable commands with undocumented local-only procedures.

## Testing requirements

New behavior requires appropriate automated tests.

Use unit tests for pure rules:

* Combat math.
* Loot selection.
* Affixes.
* Item generation.
* Salvage.
* Crafting.
* Island modifiers.
* Progression.
* Save migrations.
* Deterministic generation.

Use integration tests for scene interactions:

* Resource gathering.
* Item pickup.
* Equipment.
* Enemy death.
* Crafting.
* Island installation.
* Controller UI navigation.
* Save and load.

Use fixed seeds for procedural tests.

Bug fixes should begin with a failing reproduction test whenever practical.

Tests must be deterministic and independent.

Do not weaken, skip, delete, or rewrite a valid test merely to make a change pass.

## Visual changes

For UI, rendering, animation, effects, or scene-layout changes:

* Run the relevant scene.
* Validate at 1280x800.
* Check controller focus.
* Check text readability.
* Check clipping and overlap.
* Check missing assets.
* Check anchors and scaling.
* Check layering.
* Capture a screenshot or reproducible visual artifact when tooling allows.

A scene launching without errors is not sufficient visual validation.

## Performance

Do not optimize based only on intuition.

For performance-sensitive changes:

1. Define a reproducible scenario.
2. Measure before.
3. Implement the smallest effective improvement.
4. Measure after.
5. Record the result.

Avoid per-frame work on objects that can use events, timers, batching, sleeping, or distance-based activation.

Do not introduce object pooling unless profiling or a known allocation-heavy scenario justifies it.

## Definition of done

A task is complete only when:

* Acceptance criteria are met.
* The project imports without new errors.
* Relevant tests pass.
* Required full validation passes.
* Player-facing behavior is manually or automatically exercised.
* Controller behavior is validated when affected.
* Save compatibility is considered when affected.
* Documentation matches implementation.
* The diff contains no accidental changes.
* Known limitations are reported.
* Evidence is provided.

Never claim an unexecuted check passed.

Never claim environment-blocked validation succeeded.

## Git rules

* Keep changes focused.
* Prefer small reviewable commits.
* Do not amend or rewrite existing commits unless explicitly requested.
* Do not force-push.
* Do not commit secrets.
* Do not commit generated build output unless the repository explicitly tracks it.
* Do not commit temporary logs, screenshots, or recordings outside approved evidence paths.
* Leave the worktree clean when committing is part of the task.

## Safety boundaries

Allowed without additional approval:

* Repository reads and edits.
* Local tests.
* Local builds.
* Local debug runs.
* Local evidence generation.

Require explicit human approval:

* Publishing a release.
* Uploading a Steam build.
* Changing Steamworks settings.
* Using production credentials.
* Purchasing services.
* Accepting legal or licensing terms.
* Deleting remote data.
* Disabling safeguards.
* Rewriting remote history.

## Final report

Every implementation response must include:

1. Outcome.
2. Important changes.
3. Validation commands and results.
4. Gameplay or reproduction evidence.
5. Known limitations.
6. Exactly one recommended next task.

Be concise, factual, and explicit about uncertainty.
