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
- `tests/visual/capture_system_menu.gd` — exit 0; current `system-menu-1280x800.png` was recaptured after schema 3 and shows successful saved stone/Whetstone state.
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

## Boss milestone evidence

- Boss pattern tests add 6 passing assertions for focused-lance symmetry, normalized radial coverage, explicit phase telegraphs, and deterministic legendary reward.
- Integration covers locked state, three-enemy awakening, fixed spawn, entrance feedback, phase-one and phase-two attack resolution, behavioral transition, Verdant speed multiplication, single victory emission, feedback, and reward pickup.
- `tests/visual/capture_boss_encounter.gd` — exit 0; captured `boss-encounter-1280x800.png` during the Maelstrom telegraph.
- Boss spawn was moved from y=285 to y=230 before evidence capture so all eight radial warning spokes remain within the arena.
- Visual inspection verifies phase banner, magenta boss identity, horns/ring/health bar, radial telegraph readability, no UI overlap, bounded arena, and no missing assets.

## Rift milestone evidence

- Rift rules add 5 passing assertions for exact compositions, fixed spawns, escalation, and distinct repeat rewards.
- Integration adds 14 passing assertions for portal unlock/proximity, all wave transitions, Verdant behavior, completion/reward, repeat entry, player-defeat failure, feedback, and cleanup.
- Simulation metrics: `{"first_reward_seed":8801,"runs_started":2,"second_run_status":"failed","waves_cleared":3}` with 5 assertions and 0 failures.
- `tests/visual/capture_rift_wave.gd` — exit 0; captured `rift-wave-1280x800.png` during wave three.
- First capture exposed stale boss feedback; rift entry now clears it. Final review verifies portal visibility, wave/enemy status, ordinary/elite telegraphs, no clipping or overlap, and bounded arena.

## Riftwake Pulse milestone evidence

- Unit suite: 62 assertions, 0 failures, including deterministic pulse radius, primary exclusion, distance/stable-ID ordering, and affix metadata.
- Integration suite: 109 assertions, 0 failures, including exact primary/secondary/out-of-range damage, an active boss, a live rift wave, equip/unequip, visual creation, and save/load restoration.
- Full validation: 181 assertions, 0 failures; original smoke and repeat-rift metrics remain deterministic.
- The runner now fails explicitly when a test script cannot load, compile, or instantiate; this closes a false-pass path discovered by the initial targeted run.
- Rift entry removes hidden arena combatants from the attackable group so area attacks cannot select invisible targets.
- `tests/visual/capture_legendary_pulse.gd` — exit 0; captured `legendary-pulse-1280x800.png` at 1280x800.
- Visual inspection verifies visible concentric pulse rings, readable two-line affix description, UNEQUIP controller focus, no text clipping or overlap, opaque modal layering, bounded arena, and no missing assets.
- Physical controller hardware and subjective combat feel were not exercised.

## Three island-shard milestone evidence

- Unit suite: 70 assertions, 0 failures, including stable three-seed definitions, deterministic cycling, production cadence, schema-2 extension round trip, and malformed modifier rejection.
- Integration suite: 123 assertions, 0 failures, including three deterministic enemy drops, controller selection/focus routing, Emberglass and Tempest tradeoffs, replacement/removal resets, physical biome identity, and save/load restoration.
- Full validation: 203 assertions, 0 failures; smoke and repeat-rift metrics remain deterministic.
- Per-test expected assertion counts now turn interrupted runtime tests into failures instead of accepting partial execution.
- `tests/visual/capture_three_island_shards.gd` — exit 0; captured `three-island-shards-1280x800.png` at 1280x800.
- Visual inspection verifies readable Tempest benefit/risk text, 3/3 navigation state, visible REPLACE focus, opaque modal fit/layering, a distinct cyan storm-ring eastern island, and no clipping or missing assets.
- Physical controller hardware and subjective balance of the three tradeoffs were not exercised.

## Equipment-inventory browsing milestone evidence

- Unit suite: 72 assertions, 0 failures, including authoritative non-zero-index equip and salvage behavior.
- Integration suite: 130 assertions, 0 failures, including three-item controller browsing, selected actions, protection, focus recovery, clamping, damage display, legendary detail/value, and combat outcome.
- Full validation: 212 assertions, 0 failures; smoke and repeat-rift metrics remain deterministic.
- The initial missing-selection runtime error stopped after 3 of 18 assertions and was correctly rejected by the assertion-count contract as `TEST INCOMPLETE`.
- `tests/visual/capture_equipment_inventory.gd` — exit 0; captured `equipment-inventory-1280x800.png` at 1280x800.
- Initial inspection found Riftwake Core displayed salvage value 1 while the action granted 10. The UI now consumes the same rarity rule as inventory salvage; integration verifies value 10 and the screenshot was recaptured.
- Final inspection verifies 3/3 state, readable legendary behavior, correct comparison/value, EQUIP focus, modal fit/layering, no clipping, and no missing assets.
- Physical controller hardware and subjective inventory-navigation feel were not exercised.

## Stone and Runed Whetstone milestone evidence

- Unit suite: 80 assertions, 0 failures, including Whetstone validation/result rules, schema-3 canonical round trip, malformed stone rejection, and schema-1/schema-2 migration defaults.
- Integration suite: 138 assertions, 0 failures, including progressive stone cracks, exact drop/collection, HUD state, controller recipe browsing/focus, exact Whetstone deduction, derived attack, duplicate rejection, and persistence.
- Full validation: 228 assertions, 0 failures; smoke and repeat-rift metrics remain deterministic.
- Incomplete assertion contracts now terminate the runner immediately, preventing an interrupted test's live scene from contaminating later cases.
- `tests/visual/capture_stone_whetstone.gd` — exit 0; captured `stone-whetstone-1280x800.png` at 1280x800.
- The first capture grazed the objective prompt; the modal moved down 15 pixels and the artifact was recaptured. Final review verifies stone count, visible first-hit crack, recipe 2/2, exact benefit/cost, CRAFT focus, no overlap, and no missing assets.
- `tests/visual/capture_system_menu.gd` — exit 0; recaptured `system-menu-1280x800.png` with schema 3, stone 2, derived attack 2, Save focus, and production storage.
- Physical controller hardware, hit feel, and upgrade balance were not manually exercised.
