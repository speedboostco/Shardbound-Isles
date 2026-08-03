# Bootstrap and First Playable

Status: active

## Goal

Establish the repository contract and deliver one deterministic, controller-playable path: move, break one tree, collect wood, attack one enemy, and collect one equipment drop.

## Assumptions

- Simple vector art drawn by Godot is acceptable bootstrap art.
- Godot 4.7.1 is the available stable 4.x editor; the project stays compatible with 4.x APIs.
- A dependency-free Godot test runner is preferable until a maintained third-party test plugin can be reviewed and pinned.
- Phase 1 equipment is collected and shown but not yet equippable; equipping belongs to the next milestone.

## Acceptance criteria

- `project.godot` imports without script errors.
- WASD, arrows, left stick, and D-pad move the player; Space/Enter and controller face button attack.
- A following camera frames a 1280x800 play area.
- A tree takes deterministic damage, drops wood, and nearby wood is automatically collected.
- One enemy pursues and damages the player, can be killed, and drops the same deterministic item for seed `424242`.
- The HUD presents health, wood, equipment pickup, controls, and objective.
- Unit, integration, and fixed-seed smoke tests pass headlessly.
- Windows and Linux debug export presets exist; exports are attempted and results recorded.

## Tests defined before production code

- Unit: seeded equipment generation repeats and produces the expected valid weapon data.
- Integration: resource damage/drop/pickup and enemy death/drop signals complete the path.
- Simulation: fixed-seed scripted scenario reaches wood `>= 3`, enemy defeated, and one equipment item collected.
- Import: headless editor import exits successfully.

## Expected files and systems

- Godot configuration and export presets.
- `src/domain`: deterministic equipment generation.
- `src/gameplay`: player, tree, pickup, enemy, item pickup, world orchestration.
- `src/ui`: minimal HUD.
- `tests`: dependency-free runners for three layers.
- `scripts` and `Makefile`: stable developer commands.
- Product/design/engineering documentation and CI.

## Milestones

1. Repository knowledge, project shell, command interface, CI, and boot scene.
2. Pure deterministic item generation plus unit test.
3. Playable gather/combat/drop path plus integration tests.
4. Fixed-seed smoke scenario, validation, export attempts, evidence, and documentation sync.
5. Backlog: equipment comparison/equip/salvage, second resources/enemies, crafting, automation, shards, rift, saves, polish.

## Milestone 2: equipment decisions

Goal: turn the collected deterministic weapon into a controller-first build decision without adding broader loot content.

Acceptance criteria:

- Collected equipment is stored in authoritative gameplay state.
- The equipment panel displays the selected item, equipped item, power comparison, and salvage value.
- The panel opens and all actions work with keyboard or controller; no pointer is required.
- Equipping changes the player's displayed attack damage and damage dealt.
- Salvaging removes the item and grants deterministic scrap; equipped items cannot be salvaged accidentally.
- Pure inventory rules and scene/UI interactions have deterministic automated coverage.

Tests defined before production changes:

- Unit: collect, compare, equip, damage calculation, salvage reward, and equipped-item protection.
- Integration: collecting the fixed drop updates the panel; equip updates player damage/HUD; salvage updates scrap and removes the item.
- Controller UI: opening the panel assigns focus to a valid action and cancel closes it.

Expected changes: equipment domain state, player attack damage, HUD equipment panel, world action wiring, input actions, tests, and synchronized loot/UI/controls documentation.

Risk and rollback: controller focus can become trapped or gameplay can continue behind the modal. Keep authoritative actions in the world, pause player input while the panel is open, and make the panel a removable HUD composition.

## Risks and rollback

- Export templates may be absent. Preserve verified project/test work and report exports as blocked.
- Headless execution cannot prove rendered readability. Keep visual evidence separate from logic evidence.
- Godot API differences may surface. Prefer stable 4.x APIs and correct failures rather than version-locking gameplay.
- Rollback is file-local: bootstrap features are composed scenes and scripts with no save compatibility yet.

## Discoveries and evidence

- 2026-08-03: repository contained no Godot project or tooling.
- 2026-08-03: `godot` and `make` were absent from PATH; `C:\Users\vserg\Downloads\Godot_v4.7.1-stable_win64.exe` is available.
- 2026-08-03: headless import passed with Godot 4.7.1 after redirecting editor caches into ignored workspace storage. Godot logs a sandbox-specific root certificate-store warning.
- 2026-08-03: unit tests passed 5/5, integration tests passed 6/6, simulation tests passed 5/5; full validation passed 16/16.
- 2026-08-03: seed `424242` produced `starter_ranged_424242`, Tideglass Bow, power 5. The smoke scenario gathered 3 wood, defeated 1 enemy, and collected 1 item.
- 2026-08-03: Windows and Linux export attempts failed because Godot 4.7.1 export templates are not installed. Presets resolved correctly.
- 2026-08-03: a 1280x800 GUI launch was attempted but did not return cleanly through the execution wrapper and was terminated; no screenshot or manual controller/readability evidence was obtained.

The plan remains active because export and visual/controller acceptance criteria do not yet have local evidence.

### Milestone 2 evidence — 2026-08-03

- Equipment inventory unit tests pass: collect, comparison, equip, attack damage, protection, unequip, and salvage.
- Integration tests pass: pickup refresh, modal opening, valid action focus, displayed and dealt damage, salvage protection/reward, and close behavior.
- Full validation passes with 36 assertions and 0 failures.
- Reproducible GUI evidence captured at exactly 1280x800 in `evidence/equipment-panel-1280x800.png` using seed `424242`.
- Visual review found and corrected excessive modal transparency. Final review confirms readable text, visible focus, no clipping/overlap, no missing assets, correct anchors, and modal-over-gameplay layering.
- Controller behavior is covered through InputMap actions and focus assertions, but no physical controller hardware was available for a manual feel check.

## Milestone 3: first workbench recipe

Goal: convert the complete gather–fight–salvage output into one visible character upgrade through a controller-first workbench.

Assumptions:

- The first recipe costs exactly 3 wood and 2 scrap so it closes the currently playable loop.
- A Reinforced Heart adding 2 maximum health is a meaningful initial craft without introducing a broader item taxonomy.
- The recipe is unique per run; repeated crafting must be rejected without consuming resources.

Acceptance criteria:

- A visible workbench can be approached and opened without a pointer.
- The modal displays recipe effect, costs, affordability, and explicit success/failure feedback.
- Crafting consumes authoritative world resources only after validation.
- Reinforced Heart raises maximum and current health from 10 to 12 and cannot be crafted twice.
- Opening the modal assigns valid controller focus and suspends combat movement; cancel closes it.
- Unit, integration, and 1280x800 visual evidence cover the new flow.

Tests defined before production changes:

- Unit: exact affordability, insufficient-resource rejection, successful result, and already-crafted rejection.
- Integration: proximity gate, modal focus, authoritative deductions, health increase, duplicate rejection, feedback, and close behavior.
- Visual: fixed-state 1280x800 workbench modal showing affordable recipe and focused craft action.

Expected changes: pure crafting rule, workbench scene, world interaction/action wiring, HUD crafting modal, tests, InputMap, docs, and evidence.

Risk and rollback: modal duplication can create conflicting focus or leave gameplay frozen. Only one modal may be visible; close signals restore gameplay through the world composition root.

### Milestone 3 evidence — 2026-08-03

- Crafting unit tests pass: 8 assertions covering exact affordability, both insufficient inputs, successful result, exact deductions/effect, duplicate rejection, and failure reasons.
- Workbench integration tests pass: 12 assertions covering proximity, modal focus, authoritative deductions, health increase to 12/12, duplicate protection, feedback, and gameplay restoration.
- Reproducible GUI evidence captured at 1280x800 in `evidence/workbench-panel-1280x800.png` with the affordable recipe and Craft action focused.
- The first visual capture exposed out-of-world rendering when the camera followed the player north. Camera limits were added and the evidence was recaptured.
- Final visual review confirms readable text, no clipping/overlap, visible focus, correct opaque layering, visible workbench identity, and no missing assets.

## Milestone 4: Tidecatcher automation

Goal: reward mastery of manual tree gathering with one compact production building that creates wood without replacing exploration or combat.

Assumptions:

- Crafting the Reinforced Heart unlocks one free Tidecatcher construction choice; this avoids requiring a tree respawn solely to pay another cost.
- The Tidecatcher produces 1 wood every 2 seconds and stores at most 6.
- Stored wood transfers automatically when the player enters collection range, removing a repeated button chore.
- Production is run-local until the save milestone exists.

Acceptance criteria:

- The workbench offers controller-focused construction only after the Reinforced Heart is crafted.
- Construction activates a visible building once and rejects duplicates.
- Seed-independent production timing is deterministic, chunk-size independent, and capped at 6.
- Approaching the building transfers all stored wood to authoritative inventory and gives visible feedback.
- Tests cover timing, cap, collection, unlock, construction, duplicate protection, and world transfer.
- A 1280x800 artifact proves readable construction or production state.

Tests defined before production changes:

- Unit: sub-interval production, exact interval, chunk-size independence, storage cap, and collection reset.
- Integration: locked construction rejection, post-heart construction, duplicate rejection, six-second production, automatic nearby collection, HUD feedback, and authoritative wood update.
- Visual: built Tidecatcher with stored production, readable HUD status, and no layout regression at 1280x800.

Expected changes: deterministic production rule, composed building node, workbench construction action, HUD status/feedback, world wiring, tests, and synchronized automation docs.

Risk and rollback: per-frame production can become nondeterministic or wasteful. Keep timing in a pure accumulator and give only the single active building lightweight processing; later buildings can move to timer/event batching when a measured consumer exists.

### Milestone 4 evidence — 2026-08-03

- Production unit tests pass: 5 assertions covering sub-interval behavior, exact interval output, chunk-size independence, six-wood cap, and collection reset.
- Tidecatcher integration tests pass: 8 assertions covering unlock, visible construction, duplicate rejection, deterministic production, proximity transfer, authoritative inventory, emptied storage, and feedback.
- Workbench integration additionally verifies focus moves to Build Tidecatcher immediately after crafting unlocks it.
- Reproducible built-state evidence captured at 1280x800 in `evidence/tidecatcher-1280x800.png` with 3/6 stored wood.
- Visual review confirms readable cadence/storage/collection guidance, completed construction state, valid Close focus, no clipping/overlap, bounded camera, and visible building identity.

## Milestone 5: versioned local persistence

Goal: preserve the meaningful run state through a controller-accessible save/load cycle without introducing global state.

Assumptions:

- Schema version 1 covers player health/position, wood, scrap, generated equipment including IDs and seeds, equipped ID, Reinforced Heart, Tidecatcher construction, and stored wood.
- Tree/enemy transient encounter state is not persisted in this milestone; loading restores progression into a fresh arena encounter.
- `user://shardbound-save.json` is the single local slot and requires no text entry.
- Temp-file write plus replace/rollback is the practical atomic strategy available through Godot file APIs.

Acceptance criteria:

- A controller-focused system menu exposes Save, Load, and Close without a pointer.
- Saved JSON declares schema version 1 and contains only serializable values/stable identifiers.
- Successful load deterministically restores every scoped field and refreshes gameplay/UI.
- Malformed JSON, missing required state, and unsupported versions are rejected without mutating the live world.
- Save replacement uses a temp file and preserves/restores the previous file if replacement fails.
- Unit and integration tests cover validation, round trip, disk IO, restoration, rejection, and menu focus/feedback.

Tests defined before production changes:

- Unit: schema emission, valid round trip, malformed rejection, unsupported-version rejection, missing-state rejection, and disk round trip.
- Integration: populate a source world, save, load into a fresh world, verify all scoped fields/building storage/equipment, and verify system-menu focus and visible feedback.

Expected changes: persistence service, world state snapshot/restore, Tidecatcher restoration, system menu, input mapping, tests, save docs, and evidence.

Risk and rollback: partial load mutation could corrupt an active run. Decode and validate the complete payload before applying any field; integration tests load into a fresh composition and assert authoritative state afterward.

### Milestone 5 evidence — 2026-08-03

- Save-service unit tests pass: 8 assertions covering schema emission, semantic round trip, malformed/unsupported/missing-state rejection, and disk round trip.
- Save/load integration tests pass: 13 assertions covering disk IO, health/position/resources, stable item seed/equipped ID/derived damage, progression, construction, stored wood, menu focus/feedback, and mutation-free malformed rejection.
- JSON numeric fields are canonicalized after decoding so integer domain values remain typed and deterministic.
- Reproducible system-menu evidence captured at 1280x800 in `evidence/system-menu-1280x800.png` showing schema version 1, saved 12/12 health, 5 wood, 4/6 stored wood, success feedback, and Save focus.
- Visual review confirms readable labels, no clipping/overlap, correct modal layering, visible focus, consistent background HUD state, and no missing assets.
