# 0019 — Exploration progression, mana, targeting, and terrain presentation

Status: complete (2026-08-18)

## Goal

Turn the opening into an exploration-and-gathering phase that teaches the island before combat, then let the player deliberately awaken threats through a small technology tree. Consolidate detailed statistics in the inventory, add a readable mana resource, and make bow and magic attacks visually aimable and causally legible.

## Assumptions

- “All stats in inventory” means the field HUD keeps only compact survival resources needed during action (health and mana bars); numeric resources, equipment, and derived attributes live in the inventory panel.
- “AAA” is treated as production discipline, readable feedback, extensible authored data, and coherent progression—not an unbounded content-count promise.
- The first combat unlock requires two deliberate technology unlocks so a new save begins safely, while migrated saves retain their existing combat state.
- Technology costs use existing resources to avoid adding speculative currencies.

## Acceptance criteria

- The normal HUD has no game title or numeric resource/stat list; inventory shows resources and derived stats.
- Mana is a tested gameplay resource, is shown as a compact field bar, is saved, and magic attacks consume it and regenerate it.
- Bow and magic weapons show directional range/impact previews; firing into empty space still has a visible launch/cast result.
- A new save starts with authored enemies dormant. Learning Fieldcraft followed by Combat Training awakens them once, event-driven.
- The technology tree is prerequisite/cost validated, controller-operable from inventory, serialized, and extensible as data.
- The workbench offers additional meaningful recipes tied to mana, ranged play, exploration, and harvesting.
- Terrain has visibly distinct authored micro-biomes, richer edge dressing, and ambient motion without collision clutter.
- Existing saves migrate safely; deterministic and integration suites remain green.
- The affected flow is captured at 1280×800 and Windows export still runs.

## Test plan

1. Unit-test mana spend/regeneration/caps and technology prerequisites, costs, deterministic availability, and effects.
2. Integration-test compact HUD/inventory stats, controller tech learning, dormant-to-awakened enemies, and empty-space bow/magic presentation.
3. Save-test schema migration, learned technologies, and current mana.
4. Run static validation, targeted suites, full validation, 1280×800 capture, Windows export, and exported executable smoke.

## Progress

- [x] Inspect product, architecture, controls, UI, combat, current HUD/combat/save/recipe implementations.
- [x] Add failing unit and integration coverage.
- [x] Implement mana and technology domain models.
- [x] Implement HUD consolidation and controller technology UI.
- [x] Implement exploration phase and save migration.
- [x] Implement targeting/launch/cast visuals.
- [x] Expand recipes and terrain presentation.
- [x] Validate, capture evidence, export, review diff, and close plan.

## Evidence

- `make validate` equivalent (`tools/dev.ps1 validate` with configured Godot): 995 assertions, 0 failures; static checks 26/0.
- Fixed opening simulation: two resource nodes plus two firefly caches, 536 movement steps, 5 wood and 4 stone gathered, Fieldcraft and Combat Training learned, then two enemies defeated.
- Four reviewed 1280×800 captures: exploration/HUD, inventory/technology, bow targeting, and magic targeting.
- Windows debug export succeeded; the exported executable completed a headless startup smoke with exit code 0.
