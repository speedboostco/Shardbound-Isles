# Island Shards

Island shards are procedural loot carrying biome, risk, reward, resources, enemies, encounters, modifiers, and adjacency implications. Installation uses stable IDs, explicit seeds, and deterministic state.

The first implemented shard is Verdant Crucible, seed `9001`. The first enemy drops it alongside equipment. Installing it in the eastern neighboring slot increases tree yield by 1 wood while multiplying enemy movement speed by 1.25. Replace/reinstall always recomputes from immutable baselines, preventing modifier stacking. Removal restores baseline yield and speed.
