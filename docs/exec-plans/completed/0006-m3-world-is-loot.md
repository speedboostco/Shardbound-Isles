# M3 — The World Is Loot

## Goal

Implement WORLD-001 through ISL-006 and pass Gate M3: a shard is readable loot, the player chooses a stable world slot, installation physically changes the archipelago, island modifiers alter play, adjacency creates a meaningful tradeoff, and the complete state survives save/load.

## Compatibility and scope

- Advance saves from schema 4 to schema 5. Schema-1 through schema-4 payloads remain accepted; a legacy installed island migrates to the eastern slot.
- Preserve seed-based shard identity and the existing early arena drops. Seeds `9001`, `9002`, and `9003` become Forest, Volcano, and Frozen definitions while retaining their proven gathering/combat/production tradeoffs.
- Use three stable installable axial slots in the M3 scene. The data model can serialize any authored slot set, but no empty generalized world graph is introduced.
- Replacement and removal return the shard definition to inventory; runtime progress stays on the installed island only. Installation consumes the selected shard only after validation and materialization succeed.
- A player standing on a materialized island blocks removal/replacement of that slot.
- Runtime island schema version 1 stores destroyed resource IDs, collected reward IDs, and encounter completion. Temporary enemies and Node references are never serialized.
- Adjacency recomputes only after install/remove/replace/load mutations and each unordered pair contributes at most one synergy.

## Acceptance tests defined before implementation

- Unit: archipelago world seed, stable axial coordinates, deterministic neighbors, add/remove/replace mutation, JSON round trip, and no Node references.
- Unit: shard definition/runtime separation, all required fields, validation failures, pre-install serialization, deterministic 10,000-shard generation, biome/level pools, paired risk/reward, and impossible-combination rejection.
- Unit: six modifier registry components across all requested categories, attach/clear lifecycle, aggregate gameplay effects, and no ID switch in consumers.
- Unit: three adjacency synergies, preview before installation, bounded stacking, and refresh after add/remove/replace.
- Unit/save: schema-5 archipelago and island runtime round trip, schema-4 migration, resource/reward persistence, and unsupported-version rejection.
- Integration: controller preview shows biome/level/resources/enemies/modifiers/encounter/rewards, stable slot selection, explicit install/cancel, and replacement/removal warning.
- Integration: failed generation preserves inventory; successful install consumes one shard and creates a material island; removal clears entities/references; player occupancy blocks removal.
- Integration: Forest island contains tree, stone, Moonleaf, Slime, ranged forest enemy, and Grove Shrine event; Moonleaf is used by a concrete upgrade.
- Integration: Dense Growth, Predatory, Volatile Ore, Arcane Saturation, Nightbound, and Overgrown each expose a gameplay effect and indicator.
- Simulation: obtain, inspect, place, exploit adjacency, destroy a resource, collect a reward, save/load identically, replace, and remove with deterministic metrics.
- Visual: capture the 1280x800 controller preview and physical three-slot archipelago.

## Implementation sequence

- [x] Inspect the current shard, world, UI, save, product, and engineering contracts.
- [x] Add red M3 unit/integration/simulation contracts.
- [x] Implement shard definition/runtime, deterministic generator, archipelago, modifiers, and adjacency domain rules.
- [x] Materialize Forest islands and connect atomic install/remove/replace lifecycle.
- [x] Integrate controller preview, warnings, slot choice, indicators, Moonleaf upgrade, and schema-5 persistence.
- [x] Add 10,000-generation/stress metrics and 1280x800 visual evidence.
- [x] Run targeted/full validation, exports, smoke test, diff review, and synchronize documentation/evidence.

## Outcome

Completed on 2026-08-03. Full validation passed with 24 static checks and 597 assertions. Windows and Linux exports succeeded, and the Windows artifact passed a headless launch smoke test. Acceptance mapping, deterministic metrics, visual review, artifact hashes, and the required human-delight limitation are recorded in `evidence/2026-08-03-m3-world-is-loot.md`.
