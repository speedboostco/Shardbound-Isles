# World Generation

All domain generation receives an explicit seed or RNG. `ArchipelagoModel` owns the world seed, stable axial slot coordinates, deterministic hex neighbors, installed island data, and a mutation revision. It contains only serializable values and never references visual Nodes.

`IslandShardGenerator` derives biome from seed and modifier opportunity from biome and level. Every positive modifier is paired with an authored risk; duplicate, unknown, conflicting, or biome-impossible rolls are rejected by definition validation. A fixed-seed 10,000-generation contract exercises all six biomes.

Scene materialization consumes model data after validation. Visual `IslandSlot` and `MaterializedIsland` nodes are replaceable projections; authoritative coordinates, neighbors, definitions, and runtime progress remain in the model.
