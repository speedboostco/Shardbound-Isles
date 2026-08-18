class_name RecipeRegistry
extends RefCounted

const KNOWN_RESOURCES: Array[String] = ["wood", "stone", "moonleaf", "scrap", "plank", "fiber", "emberberry"]
const KNOWN_OUTPUTS: Array[String] = ["reinforced_heart", "runed_whetstone", "herbal_compass", "lumber_mill_kit", "collector_kit", "mana_vessel", "arcane_conduit", "ranger_fletching", "harvest_charm", "wayfinder_boots", "precision_quiver", "foresters_toolkit", "surveyors_lens", "duelist_grip", "reinforced_axe", "precision_gearbox", "shard_prism", "ley_capacitor", "trail_ration"]
const KNOWN_STATIONS: Array[String] = ["workbench"]
const KNOWN_UNLOCKS: Array[String] = ["always", "reinforced_heart", "forest_island", "fieldcraft", "combat_training", "mana_channeling", "arcane_mastery", "ranger_instinct", "efficient_harvest", "island_cartography", "weapon_mastery", "master_foraging", "island_industry", "shard_attunement", "ley_resonance"]

const DEFINITIONS: Array[Dictionary] = [
	{"id": "reinforced_heart", "name": "Reinforced Heart", "inputs": {"wood": 3, "scrap": 2}, "output": {"id": "reinforced_heart", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["always"], "unique": true, "effect_text": "Permanently gain +2 maximum health"},
	{"id": "runed_whetstone", "name": "Runed Whetstone", "inputs": {"stone": 2}, "output": {"id": "runed_whetstone", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["always"], "unique": true, "effect_text": "Permanently gain +1 base attack damage"},
	{"id": "herbal_compass", "name": "Herbal Compass", "inputs": {"moonleaf": 3}, "output": {"id": "herbal_compass", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["always"], "unique": true, "effect_text": "Permanently gain +40 pickup radius"},
	{"id": "lumber_mill_kit", "name": "Lumber Mill Kit", "inputs": {"wood": 4, "stone": 2}, "output": {"id": "lumber_mill_kit", "amount": 1, "kind": "building"}, "station": "workbench", "unlock_requirements": ["reinforced_heart"], "unique": true, "effect_text": "Processes 2 wood into 1 plank"},
	{"id": "collector_kit", "name": "Collector Kit", "inputs": {"wood": 3, "plank": 1}, "output": {"id": "collector_kit", "amount": 1, "kind": "building"}, "station": "workbench", "unlock_requirements": ["reinforced_heart"], "unique": true, "effect_text": "Collects ordinary nearby resources in bounded batches"},
	{"id": "mana_vessel", "name": "Moonleaf Mana Vessel", "inputs": {"moonleaf": 3, "stone": 2}, "output": {"id": "mana_vessel", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["mana_channeling"], "unique": true, "effect_text": "Permanently gain +10 maximum mana"},
	{"id": "arcane_conduit", "name": "Arcane Conduit", "inputs": {"moonleaf": 4, "plank": 1}, "output": {"id": "arcane_conduit", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["arcane_mastery"], "unique": true, "effect_text": "Permanently gain +2 mana regeneration"},
	{"id": "ranger_fletching", "name": "Ranger Fletching", "inputs": {"wood": 4, "moonleaf": 2}, "output": {"id": "ranger_fletching", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["combat_training"], "unique": true, "effect_text": "Permanently gain +3% critical chance"},
	{"id": "harvest_charm", "name": "Harvest Charm", "inputs": {"wood": 3, "stone": 3}, "output": {"id": "harvest_charm", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["fieldcraft"], "unique": true, "effect_text": "Permanently gain +0.25 gathering power"},
	{"id": "wayfinder_boots", "name": "Wayfinder Boots", "inputs": {"wood": 4, "plank": 1}, "output": {"id": "wayfinder_boots", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["fieldcraft"], "unique": true, "effect_text": "Permanently gain +15 movement speed"},
	{"id": "precision_quiver", "name": "Precision Quiver", "inputs": {"wood": 4, "moonleaf": 3}, "output": {"id": "precision_quiver", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["ranger_instinct"], "unique": true, "effect_text": "Permanently gain +8% attack speed"},
	{"id": "foresters_toolkit", "name": "Forester's Toolkit", "inputs": {"wood": 5, "stone": 2}, "output": {"id": "foresters_toolkit", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["efficient_harvest"], "unique": true, "effect_text": "Permanently gain +0.35 gathering power"},
	{"id": "surveyors_lens", "name": "Surveyor's Lens", "inputs": {"moonleaf": 3, "plank": 2}, "output": {"id": "surveyors_lens", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["island_cartography"], "unique": true, "effect_text": "Permanently gain +30 pickup radius"},
	{"id": "duelist_grip", "name": "Duelist Grip", "inputs": {"scrap": 5, "plank": 2}, "output": {"id": "duelist_grip", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["weapon_mastery"], "unique": true, "effect_text": "Permanently gain +1 reliable base attack damage"},
	{"id": "reinforced_axe", "name": "Reinforced Axe", "inputs": {"stone": 6, "plank": 2}, "output": {"id": "reinforced_axe", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["master_foraging"], "unique": true, "effect_text": "Permanently gain +0.4 gathering power"},
	{"id": "precision_gearbox", "name": "Precision Gearbox", "inputs": {"scrap": 8, "plank": 3}, "output": {"id": "precision_gearbox", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["island_industry"], "unique": true, "effect_text": "Permanently gain +20% production speed"},
	{"id": "shard_prism", "name": "Shard Prism", "inputs": {"moonleaf": 6, "scrap": 6}, "output": {"id": "shard_prism", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["shard_attunement"], "unique": true, "effect_text": "Permanently gain +5% critical chance"},
	{"id": "ley_capacitor", "name": "Ley Capacitor", "inputs": {"moonleaf": 8, "plank": 3}, "output": {"id": "ley_capacitor", "amount": 1, "kind": "permanent_upgrade"}, "station": "workbench", "unlock_requirements": ["ley_resonance"], "unique": true, "effect_text": "Permanently gain +20 maximum mana"},
	{"id": "trail_ration", "name": "Trail Ration", "inputs": {"fiber": 2, "emberberry": 2}, "output": {"id": "trail_ration", "amount": 1, "kind": "consumable"}, "station": "workbench", "unlock_requirements": ["always"], "unique": false, "effect_text": "Rest at the field camp: recover health and mana, then gain +1 yield for 6 harvests"},
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
