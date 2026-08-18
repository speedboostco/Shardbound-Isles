class_name JourneyJournal
extends RefCounted

const DEFINITIONS: Array[Dictionary] = [
	{"id": "gather_wood", "name": "Shelter Materials", "description": "Harvest 3 Wood for tools and shelter.", "target": 3, "reward": {"fiber": 1}},
	{"id": "gather_stone", "name": "Working Stone", "description": "Harvest 2 Stone for durable equipment.", "target": 2, "reward": {"emberberry": 1}},
	{"id": "forage_supplies", "name": "Forage Supplies", "description": "Collect 4 combined Fiber and Emberberries.", "target": 4, "reward": {"fiber": 1}},
	{"id": "craft_ration", "name": "Prepare a Ration", "description": "Craft a Trail Ration at the workbench.", "target": 1, "reward": {"emberberry": 1}},
	{"id": "rest_at_camp", "name": "Ready the Expedition", "description": "Consume a ration and rest at the field camp.", "target": 1, "reward": {"fiber": 1}},
	{"id": "learn_fieldcraft", "name": "Learn Fieldcraft", "description": "Open Inventory and learn Fieldcraft.", "target": 1, "reward": {"emberberry": 1}},
	{"id": "awaken_combat", "name": "Awaken the Wilds", "description": "Learn Combat Training when prepared.", "target": 1, "reward": {"rations": 1}},
	{"id": "discover_loot", "name": "Claim Better Gear", "description": "Collect one procedural equipment item.", "target": 1, "reward": {"fiber": 1}},
	{"id": "recover_shard", "name": "The World Is Loot", "description": "Recover and inspect an island shard.", "target": 1, "reward": {"emberberry": 1}},
	{"id": "install_island", "name": "Expand the Archipelago", "description": "Install an island shard in a stable slot.", "target": 1, "reward": {"fiber": 2}},
	{"id": "establish_base", "name": "Establish Production", "description": "Place the first automation building.", "target": 1, "reward": {"emberberry": 2}},
]

var progress: Dictionary = {}
var completed: Array[String] = []
var rewarded: Array[String] = []

func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for definition: Dictionary in DEFINITIONS:
		var entry := definition.duplicate(true)
		entry["progress"] = mini(int(progress.get(String(entry.id), 0)), int(entry.target))
		entry["completed"] = String(entry.id) in completed
		entry["rewarded"] = String(entry.id) in rewarded
		result.append(entry)
	return result

func record(milestone_id: String, amount: int = 1, absolute: bool = false) -> Dictionary:
	var definition := definition(milestone_id)
	if definition.is_empty() or amount < 0:
		return {"valid": false, "completed_now": false, "reward": {}}
	var previous := int(progress.get(milestone_id, 0))
	var current := amount if absolute else previous + amount
	progress[milestone_id] = clampi(current, 0, int(definition.target))
	var completed_now := int(progress[milestone_id]) >= int(definition.target) and milestone_id not in completed
	if completed_now:
		completed.append(milestone_id)
	var reward: Dictionary = {}
	if completed_now and milestone_id not in rewarded:
		rewarded.append(milestone_id)
		reward = (definition.reward as Dictionary).duplicate(true)
	return {"valid": true, "completed_now": completed_now, "reward": reward, "entry": entry(milestone_id)}

func next_entry() -> Dictionary:
	for value: Dictionary in entries():
		if not bool(value.completed):
			return value
	return {}

func entry(milestone_id: String) -> Dictionary:
	for value: Dictionary in entries():
		if String(value.id) == milestone_id:
			return value
	return {}

func definition(milestone_id: String) -> Dictionary:
	for value: Dictionary in DEFINITIONS:
		if String(value.id) == milestone_id:
			return value.duplicate(true)
	return {}

func to_dictionary() -> Dictionary:
	return {"progress": progress.duplicate(true), "completed": completed.duplicate(), "rewarded": rewarded.duplicate()}

func restore(data: Dictionary) -> bool:
	if not data.get("progress") is Dictionary or not data.get("completed") is Array or not data.get("rewarded") is Array:
		return false
	var valid_ids: Array[String] = []
	for definition_value: Dictionary in DEFINITIONS:
		valid_ids.append(String(definition_value.id))
	var restored_progress: Dictionary = {}
	for id_value: Variant in data.progress:
		var milestone_id := String(id_value)
		var progress_value: Variant = data.progress[id_value]
		if milestone_id not in valid_ids or not (progress_value is int or progress_value is float):
			return false
		if not is_equal_approx(float(progress_value), float(int(progress_value))):
			return false
		var amount := int(progress_value)
		if amount < 0 or amount > int(definition(milestone_id).target):
			return false
		restored_progress[milestone_id] = amount
	var restored_completed: Array[String] = []
	var restored_rewarded: Array[String] = []
	for value: Variant in data.completed:
		var milestone_id := String(value)
		if milestone_id not in valid_ids or milestone_id in restored_completed:
			return false
		restored_completed.append(milestone_id)
	for value: Variant in data.rewarded:
		var milestone_id := String(value)
		if milestone_id not in restored_completed or milestone_id in restored_rewarded:
			return false
		restored_rewarded.append(milestone_id)
	progress = restored_progress
	completed = restored_completed
	rewarded = restored_rewarded
	return true

static func default_state() -> Dictionary:
	return {"progress": {}, "completed": [], "rewarded": []}

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	for definition_value: Dictionary in DEFINITIONS:
		var milestone_id := String(definition_value.get("id", ""))
		if milestone_id.is_empty() or ids.has(milestone_id):
			errors.append("journey milestone IDs must be non-empty and unique")
		ids[milestone_id] = true
		if String(definition_value.get("name", "")).is_empty() or String(definition_value.get("description", "")).is_empty() or int(definition_value.get("target", 0)) <= 0:
			errors.append("journey milestone is incomplete: %s" % milestone_id)
		if not definition_value.get("reward") is Dictionary:
			errors.append("journey reward must be a dictionary: %s" % milestone_id)
	return errors
