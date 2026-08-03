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
