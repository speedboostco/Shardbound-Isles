# Vertical Slice

The target slice covers movement, gathering, combat, procedural equipment, crafting and compact automation, installable island shards, a repeatable rift, versioned persistence, and controller-first UX.

## Current milestone

The cohesive-world pass uses Shade's reviewed CC0 Puny family for one main hero, melee/ranged/caster enemies, terrain, trees, and flora. The hero preserves eight authored directions plus idle, walk, sword, bow, staff/magic, throw, hurt, and death motion on one 32px body sheet. One deterministic transform enforces a 16-color binary-alpha runtime palette without mirroring or synthesizing actor frames. The normal 1280x800 HUD stays inside its compact safe area, and old procedural weapon lines remain replaced by authored clips, physical projectiles, and bounded hit VFX.

The active presentation system combines Puny combatants and terrain with project-original Emberwood structures, 64-icon loot, interaction props, and animated VFX while preserving nearest-filtered contracts and authoritative gameplay timing. Fifty non-colliding flora details, sixteen solid border props, solid gatherables/workstations/buildings, and seven interactive living props keep the arena populated without blocking core combat routes. Solid objects stop movement through explicit shapes and cannot deal contact damage. The upgrade is exercised through semantic lookup, deterministic validation, physics integration tests, and reproducible 1280x800 direction/action/world captures; final physical Steam Deck animation feel remains a human gate.

Tasks 31-45 establish the Emberwood visual foundation and harden the first three behavior-changing Legendary effects. Its registered project-original assets now supply resources, drops, structures, interactive props, icons, and VFX under a numeric Art Bible and deterministic import validator; the later reviewed CC0 pass replaces terrain and combatant silhouettes. The arena uses crisp nearest-filtered terrain, animated presentation sprites, sparse non-colliding decoration, distinct hit/reward/death feedback, and one controller-first UI skin at 1280x800.

The shared Legendary lifecycle is duplicate-safe and exposes attack/hit/critical/kill/resource/world hooks. Chain Mining selects four unique targets inside 150 px; Burning Smelter resolves an eligible burning death once and visibly converts one stored charge into one bonus Stone without a resource loop; Living Arrows starts only from confirmed bow impacts, deterministically caps temporary six-second plants at three, and removes them on unequip. Seed `314159` exercises the automated gate with bounded dense drops/VFX, a three-plant cap measurement, and eight 1280x800 visual artifacts.

Repository-side acceptance is complete only after full validation/export evidence and independent review are recorded. The physical Steam Deck/controller feel test and subjective voluntary play-style change remain human product gates and must not be inferred from desktop automation.

M4 proves crafting, a compact base, and automation. Five data-driven workbench recipes include three useful permanent objects and two placeable building kits. Four stable sockets provide controller-first preview, rotation, invalid-zone feedback, atomic placement, and preview-free persistence.

The Tasks 16-30 conformance pass hardens the retained M1/M2 loop: seeded optional drops, canonical item identity and validation, physical bow projectiles, complete affix eligibility diagnostics, atomic equipment/salvage events, pure item presentation, same-slot comparison, and destructive confirmation. Repository-side checks are complete; the source task's real Steam Deck controller playtest remains a human hardware gate.

An ordinary-resource collector, bounded shared storage, and lumber mill form the visible flow `collector → storage → mill → planks`. Work is timer/batch driven rather than per-building frame simulation; storage, offline time, target count, and output are capped. A +0…+10 upgrade station previews exact cost and outcome, requires double confirmation, preserves affixes/legendary behavior, and contributes at most +5 power.

Schema 6 persists the committed base, local inventories, production progress, planks, upgrade state, and bounded catch-up timestamp while migrating schema 5 safely. Deterministic layered tests and three 1280×800 artifacts cover the complete M4 route.

## Previous milestone

M3 proves the defining product promise: the world itself is loot. The player receives a fully previewable shard, understands resources/enemies/encounter/reward and paired risk, chooses one of three stable world slots, installs it atomically, and sees a physical island containing gameplay entities. Removal and replacement are warned, occupancy-safe, and clean.

The deterministic Node-free archipelago supports saved world seed, stable axial coordinates, neighbors, runtime resource/reward progress, and schema-4 migration. Eight component modifiers cover enemy, resource, weather, reward, production, adjacency, and encounter effects. Forest is a concrete biome with Moonleaf and Herbal Compass progression. Rare Spores, Obsidian Front, and Spirit Siege give neighboring biomes bounded benefits and prices previewed before placement.

The M1/M2 gather-fight-loot, equipment, legendary behaviors, boss, rift, crafting, and automation remain operational. M3 is guarded by 10,000 shard generations, layered tests, schema-5 round trips, a full deterministic product-route simulation, 1280x800 visual artifacts, and platform exports.
