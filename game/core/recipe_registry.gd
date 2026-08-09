class_name RecipeRegistry
extends RefCounted

const KNOWN_RESOURCES: Array[String] = ["wood", "stone", "moonleaf", "scrap", "plank"]
const KNOWN_OUTPUTS: Array[String] = ["reinforced_heart", "runed_whetstone", "herbal_compass", "lumber_mill_kit", "collector_kit"]
const KNOWN_STATIONS: Array[String] = ["workbench"]
const KNOWN_UNLOCKS: Array[String] = ["always", "reinforced_heart", "forest_island"]

const DEFINITIONS: Array[Dictionary] = [
	{"id": "reinforced_heart", "name": "Reinforced Heart", "inputs": {"wood": 3, "scrap": 2}, "output": {"id": "reinforced_heart", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["always"], "unique": true, "effect_text": "Permanently gain +2 maximum health"},
	{"id": "runed_whetstone", "name": "Runed Whetstone", "inputs": {"stone": 2}, "output": {"id": "runed_whetstone", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["always"], "unique": true, "effect_text": "Permanently gain +1 base attack damage"},
	{"id": "herbal_compass", "name": "Herbal Compass", "inputs": {"moonleaf": 3}, "output": {"id": "herbal_compass", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["always"], "unique": true, "effect_text": "Permanently gain +40 pickup radius"},
	{"id": "lumber_mill_kit", "name": "Lumber Mill Kit", "inputs": {"wood": 4, "stone": 2}, "output": {"id": "lumber_mill_kit", "amount": 1, "kind": "building"}, "station": "workbench", "unlock_requirements": ["reinforced_heart"], "unique": true, "effect_text": "Processes 2 wood into 1 plank"},
	{"id": "collector_kit", "name": "Collector Kit", "inputs": {"wood": 3, "plank": 1}, "output": {"id": "collector_kit", "amount": 1, "kind": "building"}, "station": "workbench", "unlock_requirements": ["reinforced_heart"], "unique": true, "effect_text": "Collects ordinary nearby resources in bounded batches"},
]

static func all() -> Array[Dictionary]:
	return DEFINITIONS.duplicate(true)

static func get_definition(recipe_id: String) -> Dictionary:
	for definition: Dictionary in DEFINITIONS:
		if String(definition.get("id", "")) == recipe_id:
			return definition.duplicate(true)
	return {}

static func validate(definitions: Array[Dictionary] = DEFINITIONS) -> Array[String]:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	for definition: Dictionary in definitions:
		var recipe_id := String(definition.get("id", ""))
		if recipe_id.is_empty() or ids.has(recipe_id):
			errors.append("recipe ID must be non-empty and unique: %s" % recipe_id)
		ids[recipe_id] = true
		if not definition.get("inputs") is Dictionary or (definition.get("inputs") as Dictionary).is_empty():
			errors.append("recipe inputs must be a non-empty dictionary: %s" % recipe_id)
		else:
			for resource_value: Variant in definition.inputs:
				var resource_id := String(resource_value)
				if resource_id not in KNOWN_RESOURCES or int(definition.inputs[resource_value]) <= 0:
					errors.append("recipe has unknown or invalid input: %s/%s" % [recipe_id, resource_id])
		if not definition.get("output") is Dictionary:
			errors.append("recipe output must be a dictionary: %s" % recipe_id)
		else:
			var output := definition.output as Dictionary
			if String(output.get("id", "")) not in KNOWN_OUTPUTS or int(output.get("amount", 0)) <= 0:
				errors.append("recipe has unknown or invalid output: %s" % recipe_id)
		if String(definition.get("station", "")) not in KNOWN_STATIONS:
			errors.append("recipe has unknown station: %s" % recipe_id)
		if not definition.get("unlock_requirements") is Array:
			errors.append("recipe unlock requirements must be an array: %s" % recipe_id)
		else:
			for unlock_value: Variant in definition.unlock_requirements:
				if String(unlock_value) not in KNOWN_UNLOCKS:
					errors.append("recipe has unknown unlock: %s/%s" % [recipe_id, String(unlock_value)])
	return errors
