class_name IslandShardGenerator
extends RefCounted

const FIRST_DEFINITION_SEED: int = 9001
const BIOMES: Array[String] = ["forest", "volcano", "frozen", "swamp", "graveyard", "settlement"]
const BIOME_DATA: Dictionary = {
	"forest": {"slug": "verdant_crucible", "name": "Verdant Crucible", "resources": ["wood", "stone", "moonleaf"], "enemies": ["slime", "forest_ranger"], "encounter": "Grove Shrine", "reward_tags": ["herbal", "gathering", "forest"], "rewards": ["Moonleaf", "Herbal Compass parts"], "positive": ["dense_growth", "overgrown", "harmonic_machinery"]},
	"volcano": {"slug": "emberglass_reach", "name": "Emberglass Reach", "resources": ["stone", "volatile_ore"], "enemies": ["ember_slime", "fire_ranger"], "encounter": "Magma Vent", "reward_tags": ["ore", "combat", "fire"], "rewards": ["Volatile ore", "Magical equipment"], "positive": ["volatile_ore", "arcane_saturation", "harmonic_machinery"]},
	"frozen": {"slug": "tempest_loom", "name": "Tempest Loom", "resources": ["stone", "frost_crystal"], "enemies": ["frost_slime", "storm_ranger"], "encounter": "Frozen Conduit", "reward_tags": ["production", "frost", "storm"], "rewards": ["Frost crystal", "Fast production"], "positive": ["harmonic_machinery", "arcane_saturation", "volatile_ore"]},
	"swamp": {"slug": "sporefen", "name": "Sporefen Mire", "resources": ["moonleaf", "spores", "wood"], "enemies": ["bog_slime", "spore_ranger"], "encounter": "Sunken Bloom", "reward_tags": ["spore", "herbal", "poison"], "rewards": ["Rare spores", "Herbal equipment"], "positive": ["overgrown", "dense_growth", "arcane_saturation"]},
	"graveyard": {"slug": "hollow_rest", "name": "Hollow Rest", "resources": ["stone", "spirit_dust"], "enemies": ["restless_slime", "spirit_ranger"], "encounter": "Restless Shrine", "reward_tags": ["spirit", "undead", "magic"], "rewards": ["Spirit energy", "Cursed equipment"], "positive": ["arcane_saturation", "restless_shrine", "dense_growth"]},
	"settlement": {"slug": "lantern_haven", "name": "Lantern Haven", "resources": ["wood", "stone", "trade_goods"], "enemies": ["raider_slime", "outlaw_ranger"], "encounter": "Besieged Workshop", "reward_tags": ["production", "spirit", "trade"], "rewards": ["Trade goods", "Production parts"], "positive": ["harmonic_machinery", "dense_growth", "restless_shrine"]},
}
const PAIRED_RISKS: Dictionary = {
	"dense_growth": "predatory",
	"overgrown": "nightbound",
	"volatile_ore": "predatory",
	"arcane_saturation": "nightbound",
	"harmonic_machinery": "predatory",
	"restless_shrine": "nightbound",
}

static func generate(seed_value: int, item_level: int = 1) -> Dictionary:
	return generate_for_biome(seed_value, BIOMES[posmod(seed_value - FIRST_DEFINITION_SEED, BIOMES.size())], item_level)

static func generate_for_biome(seed_value: int, biome: String, item_level: int) -> Dictionary:
	if biome not in BIOMES:
		return {}
	var data := BIOME_DATA[biome] as Dictionary
	var level := maxi(1, item_level)
	var rng := SeededRngStreams.from_seed(seed_value ^ (level * 8191))
	var requested := 1 + int(level >= 10) + int(level >= 20)
	var pool := (data.positive as Array).duplicate()
	var positives: Array[String] = []
	var negatives: Array[String] = []
	# Every biome has a signature modifier so its authored gameplay value is stable;
	# additional high-level rolls still use deterministic weighted-like selection.
	if not pool.is_empty():
		var signature := String(pool.pop_front())
		positives.append(signature)
		negatives.append(String(PAIRED_RISKS.get(signature, "nightbound")))
	while positives.size() < requested and not pool.is_empty():
		var index := rng.randi_range(0, pool.size() - 1)
		var modifier_id := String(pool.pop_at(index))
		var risk_id := String(PAIRED_RISKS.get(modifier_id, "nightbound"))
		if risk_id in negatives:
			var alternate := "nightbound" if risk_id == "predatory" else "predatory"
			if alternate in negatives:
				continue
			risk_id = alternate
		positives.append(modifier_id)
		negatives.append(risk_id)
	var rarity_index := clampi((level - 1) / 7 + rng.randi_range(0, 1), 0, RarityRules.ORDER.size() - 1)
	var size_id: String = ["small", "medium", "large"][clampi((level - 1) / 10, 0, 2)]
	var slug := String(data.slug)
	var shard_id := "%s_%d" % [slug, seed_value]
	var definition := {
		"shard_id": shard_id,
		"id": shard_id,
		"seed": seed_value,
		"name": String(data.name),
		"biome": biome,
		"level": level,
		"size": size_id,
		"positive_modifiers": positives,
		"negative_modifiers": negatives,
		"encounter": String(data.encounter),
		"reward_tags": (data.reward_tags as Array).duplicate(),
		"rarity": RarityRules.ORDER[rarity_index],
		"resources": (data.resources as Array).duplicate(),
		"enemies": (data.enemies as Array).duplicate(),
		"expected_rewards": (data.rewards as Array).duplicate(),
		"reward_description": _describe_modifiers(positives),
		"risk_description": _describe_modifiers(negatives),
		"tree_yield_bonus": 1 if biome == "forest" else (-1 if biome == "volcano" else 0),
		"enemy_speed_multiplier": 1.25 if biome == "forest" else 1.0,
		"player_attack_bonus": 2 if biome == "volcano" else 0,
		"production_interval_multiplier": 0.5 if biome == "frozen" else 1.0,
		"enemy_projectile_damage_bonus": 1 if biome == "frozen" else 0,
	}
	return definition

static func _describe_modifiers(ids: Array[String]) -> String:
	var names: Array[String] = []
	for modifier_id: String in ids:
		var definition := IslandModifierRegistry.definition(modifier_id)
		names.append(String(definition.get("name", modifier_id.capitalize())))
	return ", ".join(names)
