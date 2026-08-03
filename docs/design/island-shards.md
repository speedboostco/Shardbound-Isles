# Island Shards

Island shards are procedural world loot. An inventory definition contains stable `shard_id`, seed, biome, level, size, paired positive/negative modifiers, encounter, reward tags, and rarity, plus explicit preview lists for resources, enemies, and expected rewards. It has no runtime progress or scene references, so the controller UI can explain the island before installation.

The M3 archipelago exposes three stable axial slots: East `(1,0)`, North East `(1,-1)`, and South East `(2,-1)`. Installation validates and materializes a candidate before consuming the shard. Replacing or removing an unoccupied island returns its definition to inventory and clears all active entities. A slot containing the player cannot be removed.

Installed runtime state is separate: runtime schema version, destroyed resource IDs, collected reward IDs, and encounter completion. Load rebuilds the same island from its saved definition/seed and suppresses destroyed resources and claimed rewards.

## Biomes and adjacency

Seed selection cycles deterministically through Forest, Volcano, Frozen, Swamp, Graveyard, and Settlement. The first three arena rewards remain Verdant Crucible (`9001`, Forest), Emberglass Reach (`9002`, Volcano), and Tempest Loom (`9003`, Frozen).

Each neighboring unordered pair contributes at most one displayed tradeoff:

- Forest + Swamp: Rare Spores and faster spore enemies.
- Volcano + Frozen: Obsidian and larger ore blasts.
- Graveyard + Settlement: bonus spirit energy and spirit attacks.

Synergies are previewed for the selected slot before confirmation and recomputed only when the archipelago mutates.

## Forest value

A Forest island physically contains trees, stone, Moonleaf herbs, a Slime, a ranged forest enemy, and a Grove Shrine. Moonleaf crafts the one-time Herbal Compass for +40 pickup radius. Dense Growth adds a resource node; Predatory adds an elite. This makes Forest mechanically valuable beyond presentation.

## Modifier composition

`IslandModifierRegistry` loads independent behavior components. The first six are Dense Growth, Predatory, Volatile Ore, Arcane Saturation, Nightbound, and Overgrown. Their concrete effects are extra resources, extra elites, damaging ore explosions, magical event loot, stronger night enemies/rewards, and neighboring growth. Every modifier is named and explained in preview and has a physical marker on the island. Components aggregate on install/load and disappear when their island is removed.
