class_name IslandModifierRegistry
extends RefCounted

const DEFINITIONS: Array[Dictionary] = [
	{"id": "dense_growth", "name": "Dense Growth", "category": "resource", "description": "More resource nodes grow on this island.", "indicator": "DENSE", "script_path": "res://game/core/island_modifiers/dense_growth.gd"},
	{"id": "predatory", "name": "Predatory", "category": "enemy", "description": "An additional elite hunts the island.", "indicator": "ELITE", "script_path": "res://game/core/island_modifiers/predatory.gd"},
	{"id": "volatile_ore", "name": "Volatile Ore", "category": "resource", "description": "Broken ore explodes around its node.", "indicator": "VOLATILE", "script_path": "res://game/core/island_modifiers/volatile_ore.gd"},
	{"id": "arcane_saturation", "name": "Arcane Saturation", "category": "reward", "description": "Magical rewards are more likely.", "indicator": "ARCANE", "script_path": "res://game/core/island_modifiers/arcane_saturation.gd"},
	{"id": "nightbound", "name": "Nightbound", "category": "weather", "description": "Night strengthens enemies and rewards.", "indicator": "NIGHT", "script_path": "res://game/core/island_modifiers/nightbound.gd"},
	{"id": "overgrown", "name": "Overgrown", "category": "adjacency", "description": "Growth spreads to one neighboring island.", "indicator": "SPREAD", "script_path": "res://game/core/island_modifiers/overgrown.gd"},
	{"id": "harmonic_machinery", "name": "Harmonic Machinery", "category": "production", "description": "Local production completes faster.", "indicator": "HARMONIC", "script_path": "res://game/core/island_modifiers/harmonic_machinery.gd"},
	{"id": "restless_shrine", "name": "Restless Shrine", "category": "encounter", "description": "Adds a repeatable dangerous shrine event.", "indicator": "SHRINE", "script_path": "res://game/core/island_modifiers/restless_shrine.gd"},
]

static func all() -> Array[Dictionary]:
	return DEFINITIONS.duplicate(true)

static func definition(modifier_id: String) -> Dictionary:
	for value: Dictionary in DEFINITIONS:
		if String(value.id) == modifier_id:
			return value.duplicate(true)
	return {}

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	var valid_categories := ["enemy", "resource", "weather", "reward", "production", "adjacency", "encounter"]
	for value: Dictionary in DEFINITIONS:
		var modifier_id := String(value.get("id", ""))
		if modifier_id.is_empty() or ids.has(modifier_id):
			errors.append("modifier IDs must be non-empty and unique")
		ids[modifier_id] = true
		if String(value.get("category", "")) not in valid_categories:
			errors.append("invalid modifier category: %s" % modifier_id)
		var script := load(String(value.get("script_path", "")))
		if script == null or not script is Script or not (script as Script).can_instantiate():
			errors.append("modifier component cannot load: %s" % modifier_id)
	return errors
