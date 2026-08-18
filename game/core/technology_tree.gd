class_name TechnologyTree
extends RefCounted

const DEFINITIONS: Array[Dictionary] = [
	{"id": "fieldcraft", "name": "Fieldcraft", "cost": {"wood": 2, "stone": 1}, "prerequisites": [], "effect": "Read the island, gather deliberately, and reveal practical disciplines.", "category": "exploration", "icon_id": "axe", "column": 0, "row": 1, "unlocks_recipes": ["harvest_charm", "wayfinder_boots"]},
	{"id": "combat_training", "name": "Combat Training", "cost": {"wood": 3, "stone": 2}, "prerequisites": ["fieldcraft"], "effect": "Awakens island threats and enables combat rewards.", "category": "combat", "icon_id": "sword", "column": 1, "row": 0, "unlocks_recipes": ["ranger_fletching"]},
	{"id": "efficient_harvest", "name": "Efficient Harvest", "cost": {"wood": 5, "stone": 4}, "prerequisites": ["fieldcraft"], "effect": "+0.5 gathering power before crafted tool bonuses.", "category": "exploration", "icon_id": "gathering", "column": 1, "row": 1, "unlocks_recipes": ["foresters_toolkit"]},
	{"id": "mana_channeling", "name": "Mana Channeling", "cost": {"moonleaf": 2, "stone": 1}, "prerequisites": ["fieldcraft"], "effect": "+20 maximum mana and access to stable magical vessels.", "category": "arcane", "icon_id": "wand", "column": 1, "row": 3, "unlocks_recipes": ["mana_vessel"]},
	{"id": "ranger_instinct", "name": "Ranger Instinct", "cost": {"wood": 4, "moonleaf": 2}, "prerequisites": ["combat_training"], "effect": "+5% critical chance and clearer ranged intent.", "category": "combat", "icon_id": "bow", "column": 2, "row": 0, "unlocks_recipes": ["precision_quiver"]},
	{"id": "master_foraging", "name": "Master Foraging", "cost": {"wood": 8, "stone": 6}, "prerequisites": ["efficient_harvest"], "effect": "+0.25 gathering power and access to reinforced tools.", "category": "exploration", "icon_id": "pickaxe", "column": 2, "row": 1, "unlocks_recipes": ["reinforced_axe"]},
	{"id": "island_cartography", "name": "Island Cartography", "graph_label": "Island Mapping", "cost": {"moonleaf": 5, "plank": 2}, "prerequisites": ["fieldcraft", "combat_training"], "effect": "Reveals deeper shard routes and adjacency knowledge.", "category": "world", "icon_id": "forest_shard", "column": 2, "row": 2, "unlocks_recipes": ["surveyors_lens"]},
	{"id": "arcane_mastery", "name": "Arcane Mastery", "cost": {"moonleaf": 4, "plank": 1}, "prerequisites": ["mana_channeling"], "effect": "+3 mana regeneration per second.", "category": "arcane", "icon_id": "arcane_shard", "column": 2, "row": 3, "unlocks_recipes": ["arcane_conduit"]},
	{"id": "weapon_mastery", "name": "Weapon Mastery", "cost": {"moonleaf": 4, "plank": 3}, "prerequisites": ["ranger_instinct"], "effect": "+25% critical damage and access to precision grips.", "category": "combat", "icon_id": "rare_sword", "column": 3, "row": 0, "unlocks_recipes": ["duelist_grip"]},
	{"id": "island_industry", "name": "Island Industry", "cost": {"wood": 10, "stone": 8, "plank": 4}, "prerequisites": ["master_foraging", "island_cartography"], "effect": "+10% production speed across live and offline automation.", "category": "exploration", "icon_id": "lumber_mill_kit", "column": 3, "row": 1, "unlocks_recipes": ["precision_gearbox"]},
	{"id": "shard_attunement", "name": "Shard Attunement", "cost": {"moonleaf": 8, "plank": 3}, "prerequisites": ["island_cartography"], "effect": "+20 pickup radius and stronger shard-focused crafting.", "category": "world", "icon_id": "island_shard", "column": 3, "row": 2, "unlocks_recipes": ["shard_prism"]},
	{"id": "ley_resonance", "name": "Ley Resonance", "cost": {"moonleaf": 10, "plank": 4}, "prerequisites": ["arcane_mastery"], "effect": "+2 mana regeneration per second and deeper mana storage.", "category": "arcane", "icon_id": "riftwake_pulse", "column": 3, "row": 3, "unlocks_recipes": ["ley_capacitor"]},
]

var learned: Array[String] = []

func definition(technology_id: String) -> Dictionary:
	for entry: Dictionary in DEFINITIONS:
		if String(entry.id) == technology_id:
			return entry.duplicate(true)
	return {}

func all_definitions() -> Array[Dictionary]:
	return DEFINITIONS.duplicate(true)

func evaluate(technology_id: String, resources: Dictionary) -> Dictionary:
	var entry := definition(technology_id)
	if entry.is_empty():
		return {"success": false, "reason": "unknown_technology"}
	if technology_id in learned:
		return {"success": false, "reason": "already_learned"}
	for prerequisite_value: Variant in entry.prerequisites:
		var prerequisite := String(prerequisite_value)
		if prerequisite not in learned:
			return {"success": false, "reason": "missing_prerequisite", "prerequisite": prerequisite}
	var missing: Dictionary = {}
	for resource_value: Variant in entry.cost:
		var resource_id := String(resource_value)
		var amount := int(entry.cost[resource_value])
		if int(resources.get(resource_id, 0)) < amount:
			missing[resource_id] = amount - int(resources.get(resource_id, 0))
	if not missing.is_empty():
		return {"success": false, "reason": "insufficient_resources", "missing": missing}
	var resources_after := resources.duplicate(true)
	for resource_value: Variant in entry.cost:
		var resource_id := String(resource_value)
		resources_after[resource_id] = int(resources_after.get(resource_id, 0)) - int(entry.cost[resource_value])
	return {"success": true, "technology": entry, "resources_after": resources_after}

func learn(technology_id: String, resources: Dictionary) -> Dictionary:
	var result := evaluate(technology_id, resources)
	if bool(result.get("success", false)):
		learned.append(technology_id)
	return result

func restore(values: Array) -> bool:
	var restored: Array[String] = []
	for value: Variant in values:
		var technology_id := String(value)
		if definition(technology_id).is_empty() or technology_id in restored:
			return false
		restored.append(technology_id)
	for technology_id: String in restored:
		for prerequisite_value: Variant in definition(technology_id).prerequisites:
			if String(prerequisite_value) not in restored:
				return false
	learned = restored
	return true

func is_learned(technology_id: String) -> bool:
	return technology_id in learned

func available() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in DEFINITIONS:
		if String(entry.id) in learned:
			continue
		var unlocked := true
		for prerequisite_value: Variant in entry.prerequisites:
			if String(prerequisite_value) not in learned:
				unlocked = false
		if unlocked:
			result.append(entry.duplicate(true))
	return result

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	for entry: Dictionary in DEFINITIONS:
		var technology_id := String(entry.get("id", ""))
		if technology_id.is_empty() or ids.has(technology_id):
			errors.append("technology IDs must be non-empty and unique")
		ids[technology_id] = true
		if not entry.get("cost") is Dictionary or (entry.cost as Dictionary).is_empty():
			errors.append("technology cost must be non-empty: %s" % technology_id)
		if String(entry.get("icon_id", "")).is_empty() or int(entry.get("column", -1)) < 0 or int(entry.get("row", -1)) < 0:
			errors.append("technology visual metadata is incomplete: %s" % technology_id)
		if not entry.get("unlocks_recipes") is Array:
			errors.append("technology recipe unlocks must be an array: %s" % technology_id)
	for entry: Dictionary in DEFINITIONS:
		for prerequisite_value: Variant in entry.prerequisites:
			if not ids.has(String(prerequisite_value)):
				errors.append("unknown prerequisite: %s" % String(prerequisite_value))
		for recipe_value: Variant in entry.get("unlocks_recipes", []):
			if RecipeRegistry.get_definition(String(recipe_value)).is_empty():
				errors.append("unknown technology recipe unlock: %s/%s" % [String(entry.id), String(recipe_value)])
	return errors
