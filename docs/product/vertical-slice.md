# Vertical Slice

The target slice covers movement, gathering, combat, procedural equipment, crafting and compact automation, installable island shards, a repeatable rift, versioned persistence, and controller-first UX.

## Current milestone

M4 proves crafting, a compact base, and automation. Five data-driven workbench recipes include three useful permanent objects and two placeable building kits. Four stable sockets provide controller-first preview, rotation, invalid-zone feedback, atomic placement, and preview-free persistence.

An ordinary-resource collector, bounded shared storage, and lumber mill form the visible flow `collector → storage → mill → planks`. Work is timer/batch driven rather than per-building frame simulation; storage, offline time, target count, and output are capped. A +0…+10 upgrade station previews exact cost and outcome, requires double confirmation, preserves affixes/legendary behavior, and contributes at most +5 power.

Schema 6 persists the committed base, local inventories, production progress, planks, upgrade state, and bounded catch-up timestamp while migrating schema 5 safely. Deterministic layered tests and three 1280×800 artifacts cover the complete M4 route.

## Previous milestone

M3 proves the defining product promise: the world itself is loot. The player receives a fully previewable shard, understands resources/enemies/encounter/reward and paired risk, chooses one of three stable world slots, installs it atomically, and sees a physical island containing gameplay entities. Removal and replacement are warned, occupancy-safe, and clean.

The deterministic Node-free archipelago supports saved world seed, stable axial coordinates, neighbors, runtime resource/reward progress, and schema-4 migration. Eight component modifiers cover enemy, resource, weather, reward, production, adjacency, and encounter effects. Forest is a concrete biome with Moonleaf and Herbal Compass progression. Rare Spores, Obsidian Front, and Spirit Siege give neighboring biomes bounded benefits and prices previewed before placement.

The M1/M2 gather-fight-loot, equipment, legendary behaviors, boss, rift, crafting, and automation remain operational. M3 is guarded by 10,000 shard generations, layered tests, schema-5 round trips, a full deterministic product-route simulation, 1280x800 visual artifacts, and platform exports.
