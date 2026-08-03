class_name EquipmentGenerator
extends RefCounted

const BASE_NAMES: Array[String] = ["Driftwood Blade", "Tideglass Bow", "Ember Wand"]
const ARCHETYPES: Array[String] = ["melee", "ranged", "magic"]

static func generate(seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var index := rng.randi_range(0, BASE_NAMES.size() - 1)
	return {
		"id": "starter_%s_%d" % [ARCHETYPES[index], seed_value],
		"name": BASE_NAMES[index],
		"archetype": ARCHETYPES[index],
		"rarity": "uncommon",
		"power": rng.randi_range(4, 7),
		"seed": seed_value,
	}

