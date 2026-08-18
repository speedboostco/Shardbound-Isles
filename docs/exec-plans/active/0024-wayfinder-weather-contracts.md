# Wayfinder Weather Contracts

## Goal

Build one polished, repeatable expedition-contract slice that connects an NPC, biome/weather quest logic, world events, ordinary inventory, procedural loot, island shards, controller UI, deterministic persistence, and weather presentation.

## Acceptance criteria

- Mira the Cartographer offers one deterministic contract for the current day, biome, and weather.
- Accept, decline, active progress, completion, and claim are explicit controller-first states.
- Clear, rain, fog, and gale author different objectives and named event presentation.
- Resource gathering and stable weather-event interactions advance only the matching active objective.
- Contract events use stable IDs, cannot grant progress or rewards twice, and cleanly refresh on day/weather changes.
- Claiming awards one Expedition Mark plus visible seeded equipment and island-shard loot through the normal pickup pipeline.
- The field HUD shows one concise active contract; the inventory summary owns the numeric Expedition Mark count.
- Contract status, progress, claimed event IDs, and currency persist in save schema 10; schema 9 migrates safely.
- Weather overlay remains bounded, non-interactive, and visually distinct at 1280x800.
- Unit, integration, full validation, Windows export, and exported-build smoke pass.

## Test-first plan

- Unit-test definition validation, seeded generation, weather variation, state transitions, event-token deduplication, exact completion, one-shot claim, and restore rejection.
- Integration-test Mira offer/focus, controller acceptance, resource and event progress, reward spawning/collection, day refresh, HUD, schema-10 round-trip, and schema-9 migration.
- Capture clear contract offer and active weather event at 1280x800.

## Status

Implemented and validated on 2026-08-18.

- Unit tests: 634 assertions, 0 failures.
- Integration tests: 462 assertions, 0 failures.
- Full validation: 1191 assertions and 26 static checks, 0 failures.
- Windows export and exported-build headless smoke: passed.
- Visual evidence: contract offer and active fog-event route captured at 1280x800.
