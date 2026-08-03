class_name IslandShardGenerator
extends RefCounted

static func generate(seed_value: int) -> Dictionary:
	return {
		"id": "verdant_crucible_%d" % seed_value,
		"name": "Verdant Crucible",
		"biome": "verdant",
		"seed": seed_value,
		"tree_yield_bonus": 1,
		"enemy_speed_multiplier": 1.25,
	}

