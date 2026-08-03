class_name IslandShardGenerator
extends RefCounted

const FIRST_DEFINITION_SEED: int = 9001
const DEFINITIONS: Array[Dictionary] = [
	{
		"slug": "verdant_crucible",
		"name": "Verdant Crucible",
		"biome": "verdant",
		"reward_description": "Tree nodes yield +1 wood",
		"risk_description": "Enemies move 25% faster",
		"tree_yield_bonus": 1,
		"enemy_speed_multiplier": 1.25,
		"player_attack_bonus": 0,
		"production_interval_multiplier": 1.0,
		"enemy_projectile_damage_bonus": 0,
	},
	{
		"slug": "emberglass_reach",
		"name": "Emberglass Reach",
		"biome": "ember",
		"reward_description": "Player attacks deal +2 damage",
		"risk_description": "Tree nodes yield -1 wood",
		"tree_yield_bonus": -1,
		"enemy_speed_multiplier": 1.0,
		"player_attack_bonus": 2,
		"production_interval_multiplier": 1.0,
		"enemy_projectile_damage_bonus": 0,
	},
	{
		"slug": "tempest_loom",
		"name": "Tempest Loom",
		"biome": "tempest",
		"reward_description": "Tidecatcher produces twice as fast",
		"risk_description": "Enemy projectiles deal +1 damage",
		"tree_yield_bonus": 0,
		"enemy_speed_multiplier": 1.0,
		"player_attack_bonus": 0,
		"production_interval_multiplier": 0.5,
		"enemy_projectile_damage_bonus": 1,
	},
]

static func generate(seed_value: int) -> Dictionary:
	var definition := DEFINITIONS[posmod(seed_value - FIRST_DEFINITION_SEED, DEFINITIONS.size())].duplicate(true)
	var slug := String(definition.get("slug"))
	definition.erase("slug")
	definition["id"] = "%s_%d" % [slug, seed_value]
	definition["seed"] = seed_value
	return definition
