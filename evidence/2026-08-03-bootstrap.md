# Bootstrap Evidence — 2026-08-03

Environment: Windows, Godot 4.7.1 stable. `godot` and `make` were not on PATH; commands used the repository PowerShell wrapper and discovered the local editor executable.

## Automated validation

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 import` — exit 0; project scan and editor load completed.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 test-unit` — exit 0; 5 assertions, 0 failures.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 test-integration` — exit 0; 6 assertions, 0 failures.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 test-simulation` — exit 0; 5 assertions, 0 failures.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/dev.ps1 validate` — exit 0; import completed and all 16 assertions passed.
- `git diff --check` — no whitespace errors. Git emitted only line-ending and inaccessible global-ignore warnings.

Godot emitted `Failed to read the root certificate store` in the restricted environment. It did not change exit status or offline project/test behavior.

## Fixed-seed scenario

Seed `424242` scripted two tree hits, wood collection, three enemy hits, and equipment collection. Metrics:

```json
{"enemies_defeated":1,"item":{"archetype":"ranged","id":"starter_ranged_424242","name":"Tideglass Bow","power":5,"rarity":"uncommon","seed":424242},"items_collected":1,"seed":424242,"wood":3}
```

## Blocked or incomplete evidence

- `scripts/dev.ps1 export-windows` — exit 1: Godot 4.7.1 Windows templates absent.
- `scripts/dev.ps1 export-linux` — exit 1: Godot 4.7.1 Linux templates absent.
- A 1280x800 GUI launch was attempted, but the environment wrapper did not return cleanly and it was terminated. No screenshot, controller hardware check, text-readability review, clipping review, or gameplay feel assessment is claimed.
- CI is configured to install templates, run all tests, and export Linux, but the workflow has not been executed in this local uncommitted workspace.

## Equipment milestone evidence

- `scripts/dev.ps1 validate` — exit 0; import completed and all 36 assertions passed.
- Unit coverage verifies authoritative collect, compare, equip, attack damage, equipped-item protection, unequip, and deterministic salvage rules.
- Integration coverage verifies modal focus, HUD updates, increased damage dealt, salvage protection and reward, and controller cancel behavior.
- `tests/visual/capture_equipment_panel.gd` — exit 0; captured `equipment-panel-1280x800.png` at 1280x800 using seed `424242`.
- Visual inspection verified readable text, visible Equip focus, no clipping or overlap, no missing assets, safe anchors, and opaque modal layering. The first capture exposed excessive transparency; the panel style was corrected and recaptured.
- Physical controller hardware was not exercised; controller behavior is automated at the InputMap/focus level.

## Workbench milestone evidence

- Crafting unit suite adds 8 passing assertions for validation, output, duplicate protection, and non-consuming failures.
- Workbench integration adds 12 passing assertions for proximity, focus, exact deductions, health increase, feedback, duplicate rejection, and restored input.
- `tests/visual/capture_workbench_panel.gd` — exit 0; captured `workbench-panel-1280x800.png` at 1280x800 with exact recipe resources.
- Initial capture exposed the camera clear color above the arena near the northern workbench. Camera limits were added and the scenario was recaptured.
- Final image review verifies readable recipe/effect/cost/status text, highlighted Craft focus, no clipping or overlap, opaque modal layering, and a visible workbench behind the modal.

## Tidecatcher milestone evidence

- Production rules add 5 passing assertions for interval timing, chunk-size independence, cap behavior, and collection reset.
- Tidecatcher scene integration adds 8 passing assertions for unlock/construction, duplicate rejection, six-second output, proximity transfer, authoritative wood, storage reset, and visible feedback.
- Workbench integration verifies controller focus transfers to the newly unlocked construction action.
- `tests/visual/capture_tidecatcher.gd` — exit 0; captured `tidecatcher-1280x800.png` with 3/6 stored wood.
- Visual inspection verifies construction status, production cadence, storage and collection guidance, focus visibility, modal fit/layering, bounded camera, and building readability.

## Persistence milestone evidence

- Save-service unit coverage adds 8 passing assertions for versioning, round trip, malformed/unsupported/missing-state rejection, and local disk IO.
- Save/load integration adds 13 passing assertions for every scoped field, system-menu focus/feedback, stable equipment identity and damage, stored production, and mutation-free rejection.
- `tests/visual/capture_system_menu.gd` — exit 0; current `system-menu-1280x800.png` was recaptured after migration and shows successful schema-v2 save state.
- Visual inspection verifies 12/12 health, 5 wood, 4/6 stored production, Save focus, schema/result readability, modal fit/layering, and no missing assets.

## Island-shard milestone evidence

- Generator tests add 5 passing assertions for deterministic identity and exact risk/reward fields.
- Save coverage advances to schema 2 and verifies explicit migration of valid schema-1 state to empty island state.
- Integration verifies enemy shard drop, inspect/focus, install/replace/remove, physical slot state, non-stacking +1 tree yield and ×1.25 enemy speed, reset, persistence, and restoration.
- `tests/visual/capture_island_shard.gd` — exit 0; captured `island-shard-1280x800.png` with Verdant Crucible installed.
- Visual inspection verifies risk/reward distinction, seed/biome readability, Replace focus, modal fit/layering, physical eastern island visibility, and no missing assets.

## Ranged-combat milestone evidence

- Pattern tests add 5 passing assertions for ordinary/elite shot patterns, symmetry, telegraph, and cooldown constants.
- Integration covers fixed spawns, pre-fire telegraphs, one-versus-three volleys, single-hit projectile damage, deterministic death loot, and Verdant speed interaction for every enemy archetype.
- Typed signal validation initially failed because a conditional literal returned untyped `Array`; explicit `Array[float]` construction fixed the boundary and targeted suites passed.
- `tests/visual/capture_ranged_combat.gd` — exit 0; captured `ranged-combat-1280x800.png` with both attack telegraphs active.
- Initial capture found Tide Slinger partly beneath the HUD; the spawn was moved down and recaptured. Final review verifies clear silhouettes/telegraphs, elite identity, no clipping or overlap, and no missing assets.
