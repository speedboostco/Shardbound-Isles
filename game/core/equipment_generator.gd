class_name EquipmentGenerator
extends RefCounted

const SeededRngStreamsScript := preload("res://game/core/seeded_rng_streams.gd")
const WeaponDefinitionScript := preload("res://game/core/weapon_definition.gd")
const WeaponInstanceScript := preload("res://game/core/weapon_instance.gd")
const BASE_NAMES: Array[String] = ["Driftwood Blade", "Tideglass Bow", "Ember Wand"]
const ARCHETYPES: Array[String] = ["melee", "ranged", "magic"]
const ATTACK_SPEEDS: Array[float] = [1.1, 1.35, 0.9]

static func generate(seed_value: int, context: String = "starter") -> Dictionary:
	var rng: RandomNumberGenerator = SeededRngStreamsScript.from_seed(seed_value)
	var index := rng.randi_range(0, BASE_NAMES.size() - 1)
	var definition: Resource = WeaponDefinitionScript.new()
	definition.set("item_id", BASE_NAMES[index].to_snake_case())
	definition.set("display_name", BASE_NAMES[index])
	definition.set("base_type", ARCHETYPES[index])
	definition.set("damage", rng.randi_range(4, 7))
	definition.set("attack_speed", ATTACK_SPEEDS[index])
	definition.set("rarity", "magic")
	var item: Dictionary = WeaponInstanceScript.from_definition(definition, seed_value, context).to_dictionary()
	item["slot"] = "weapon"
	item["icon_id"] = ["sword", "bow", "wand"][index]
	item["item_level"] = 1
	item["base_stats"] = {}
	item["affixes"] = []
	item["legendary_effects"] = []
	item["rarity_color"] = RarityRules.color("magic")
	item["favorite"] = false
	return item
