class_name AdjacencySynergyRegistry
extends RefCounted

const DEFINITIONS: Array[Dictionary] = [
	{"id": "rare_spores", "biomes": ["forest", "swamp"], "name": "Rare Spores", "benefit": "Moonleaf nodes can yield rare spores.", "price": "Spore enemies gain movement speed.", "effects": {"rare_spore_yield": 1, "spore_enemy_speed_bonus": 0.15}},
	{"id": "obsidian_front", "biomes": ["volcano", "frozen"], "name": "Obsidian Front", "benefit": "Volatile ore also yields obsidian.", "price": "Ore explosions gain a larger radius.", "effects": {"obsidian_yield": 1, "ore_radius_bonus": 20.0}},
	{"id": "spirit_siege", "biomes": ["graveyard", "settlement"], "name": "Spirit Siege", "benefit": "Shrines grant bonus spirit energy.", "price": "Spirit attacks periodically pressure the settlement.", "effects": {"spirit_energy_bonus": 2, "spirit_attack_count": 1}},
]

static func match(first_biome: String, second_biome: String) -> Dictionary:
	for definition: Dictionary in DEFINITIONS:
		var biomes := definition.biomes as Array
		if first_biome in biomes and second_biome in biomes and first_biome != second_biome:
			return definition.duplicate(true)
	return {}

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	for definition: Dictionary in DEFINITIONS:
		if ids.has(definition.id) or (definition.biomes as Array).size() != 2 or String(definition.benefit).is_empty() or String(definition.price).is_empty():
			errors.append("invalid adjacency definition: %s" % String(definition.get("id", "")))
		ids[definition.id] = true
	return errors
