class_name LegendaryBehaviorRegistry
extends RefCounted

const DEFINITIONS: Array[Dictionary] = [
	{"id": "riftwake_pulse", "name": "Riftwake Pulse", "description": "Attacks release a damaging ring around you.", "script": "res://game/core/legendary_behaviors/riftwake_pulse.gd", "allowed_base_types": ["sword", "bow", "wand", "melee", "ranged", "magic"]},
	{"id": "chain_mining", "name": "Chain Mining", "description": "Resource strikes chain half damage to four nearby targets.", "script": "res://game/core/legendary_behaviors/chain_mining.gd", "allowed_base_types": ["sword", "wand"]},
	{"id": "burning_smelter", "name": "Burning Smelter", "description": "Burning deaths smelt nearby ore or create one charge.", "script": "res://game/core/legendary_behaviors/burning_smelter.gd", "allowed_base_types": ["wand"]},
	{"id": "living_arrows", "name": "Living Arrows", "description": "Some arrows grow temporary attacking plants (maximum three).", "script": "res://game/core/legendary_behaviors/living_arrows.gd", "allowed_base_types": ["bow"]},
]

static func ids() -> Array[String]:
	var result: Array[String] = []
	for value: Dictionary in DEFINITIONS:
		result.append(String(value.id))
	return result

static func definition(effect_id: String) -> Dictionary:
	for value: Dictionary in DEFINITIONS:
		if String(value.id) == effect_id:
			return value.duplicate(true)
	return {}

static func eligible_ids(item_base: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var base_type := String(item_base.get("base_type", ""))
	for value: Dictionary in DEFINITIONS:
		if base_type in (value.allowed_base_types as Array):
			result.append(String(value.id))
	return result

static func create(effect_id: String) -> Variant:
	var value := definition(effect_id)
	if value.is_empty():
		return null
	var script_value: Variant = load(String(value.script))
	if script_value == null or not script_value is Script or not (script_value as Script).can_instantiate():
		return null
	return (script_value as Script).new()

static func validate(definitions: Array[Dictionary] = DEFINITIONS) -> Array[String]:
	var errors: Array[String] = []
	var seen: Dictionary = {}
	for value: Dictionary in definitions:
		var effect_id := String(value.get("id", ""))
		if effect_id.is_empty() or seen.has(effect_id):
			errors.append("legendary behavior ID must be non-empty and unique: %s" % effect_id)
		seen[effect_id] = true
		if String(value.get("name", "")).is_empty() or String(value.get("description", "")).is_empty() or not value.get("allowed_base_types") is Array:
			errors.append("legendary behavior metadata invalid: %s" % effect_id)
		var instance: Variant = create(effect_id)
		if instance == null or not instance.has_method("activate") or not instance.has_method("deactivate"):
			errors.append("legendary behavior script invalid: %s" % effect_id)
	return errors
