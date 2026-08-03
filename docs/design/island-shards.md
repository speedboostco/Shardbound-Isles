# Island Shards

Island shards are procedural loot carrying biome, risk, reward, resources, enemies, encounters, modifiers, and adjacency implications. Installation uses stable IDs, explicit seeds, and deterministic state. The three current definitions cycle from seed `9001`:

- Verdant Crucible: tree nodes yield +1 wood; enemies move 25% faster.
- Emberglass Reach: player attacks deal +2 damage; tree nodes yield -1 wood.
- Tempest Loom: Tidecatcher production time is halved; enemy projectiles deal +1 damage.

The chaser, Tide Slinger, and Stormcaller drop seeds `9001`, `9002`, and `9003`, respectively. Previous/Next controls inspect owned shards before installing or replacing the eastern neighbor. The physical island uses a biome-specific green grove, orange crystal, or cyan storm-ring silhouette.

Every install, replacement, removal, or load recomputes all modifiers from immutable baselines, preventing stacking and stale derived state. The optional new modifier fields remain compatible with schema-2 Verdant-only saves.
