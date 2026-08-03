class_name WeaponInstance
extends RefCounted

var instance_id: String
var definition_id: String
var display_name: String
var base_type: String
var damage: int
var attack_speed: float
var rarity: String
var seed: int

static func from_definition(definition: Resource, seed_value: int, context: String) -> Variant:
	var instance: Variant = (load("res://game/core/weapon_instance.gd") as Script).new()
	instance.instance_id = "%s_%s_%d" % [context, String(definition.get("base_type")), seed_value]
	instance.definition_id = String(definition.get("item_id"))
	instance.display_name = String(definition.get("display_name"))
	instance.base_type = String(definition.get("base_type"))
	instance.damage = maxi(0, int(definition.get("damage")))
	instance.attack_speed = maxf(0.1, float(definition.get("attack_speed")))
	instance.rarity = String(definition.get("rarity"))
	instance.seed = seed_value
	return instance

static func from_dictionary(payload: Dictionary) -> Variant:
	var instance: Variant = (load("res://game/core/weapon_instance.gd") as Script).new()
	instance.instance_id = String(payload.get("item_id", payload.get("id", "")))
	instance.definition_id = String(payload.get("definition_id", ""))
	instance.display_name = String(payload.get("name", "Unknown Weapon"))
	instance.base_type = String(payload.get("base_type", payload.get("archetype", "melee")))
	instance.damage = maxi(0, int(payload.get("damage", payload.get("power", 0))))
	instance.attack_speed = maxf(0.1, float(payload.get("attack_speed", 1.0)))
	instance.rarity = String(payload.get("rarity", "common"))
	instance.seed = int(payload.get("seed", 0))
	return instance

func to_dictionary() -> Dictionary:
	return {
		"item_id": instance_id,
		"id": instance_id,
		"definition_id": definition_id,
		"name": display_name,
		"base_type": base_type,
		"archetype": base_type,
		"damage": damage,
		"power": damage,
		"attack_speed": attack_speed,
		"rarity": rarity,
		"seed": seed,
	}
