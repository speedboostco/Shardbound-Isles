class_name ArchipelagoModel
extends RefCounted

const DEFAULT_COORDINATES: Dictionary = {
	"east": {"q": 1, "r": 0},
	"north_east": {"q": 1, "r": -1},
	"south_east": {"q": 2, "r": -1},
}

var world_seed: int
var slots: Dictionary = {}
var revision: int = 0

func _init(seed_value: int = 0) -> void:
	world_seed = seed_value

func initialize_default_slots() -> void:
	slots.clear()
	for slot_id: String in ["east", "north_east", "south_east"]:
		slots[slot_id] = {"slot_id": slot_id, "coordinate": DEFAULT_COORDINATES[slot_id].duplicate(), "neighbors": [], "installed_island": {}}
	_rebuild_neighbors()

func slot_ids() -> Array[String]:
	var result: Array[String] = []
	for slot_id: String in slots:
		result.append(slot_id)
	result.sort()
	# Preserve controller-facing authored order.
	return ["east", "north_east", "south_east"].filter(func(slot_id: String) -> bool: return slot_id in result)

func slot(slot_id: String) -> Dictionary:
	return (slots.get(slot_id, {}) as Dictionary)

func neighbor_ids(slot_id: String) -> Array[String]:
	if not slots.has(slot_id):
		return []
	var result: Array[String] = []
	for value: Variant in (slots[slot_id] as Dictionary).neighbors:
		result.append(String(value))
	result.sort()
	return result

func install(slot_id: String, definition: Dictionary, runtime_state: Dictionary) -> bool:
	if not slots.has(slot_id) or not IslandShardDefinition.validate_dictionary(definition).is_empty() or not IslandRuntimeState.validate_dictionary(runtime_state).is_empty():
		return false
	var progress := IslandRuntimeState.progress_only(runtime_state)
	(slots[slot_id] as Dictionary)["installed_island"] = {"definition": definition.duplicate(true), "runtime": progress}
	revision += 1
	return true

func remove(slot_id: String) -> Dictionary:
	if not slots.has(slot_id):
		return {}
	var installed := ((slots[slot_id] as Dictionary).installed_island as Dictionary).duplicate(true)
	if installed.is_empty():
		return {}
	(slots[slot_id] as Dictionary)["installed_island"] = {}
	revision += 1
	return installed

func active_synergies() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen_pairs: Dictionary = {}
	for slot_id: String in slot_ids():
		var installed := (slots[slot_id] as Dictionary).installed_island as Dictionary
		if installed.is_empty():
			continue
		for neighbor_id: String in neighbor_ids(slot_id):
			var pair_ids: Array[String] = [slot_id, neighbor_id]
			pair_ids.sort()
			var pair_key := "|".join(pair_ids)
			if seen_pairs.has(pair_key):
				continue
			seen_pairs[pair_key] = true
			var neighbor := (slots[neighbor_id] as Dictionary).installed_island as Dictionary
			if neighbor.is_empty():
				continue
			var synergy := AdjacencySynergyRegistry.match(String(installed.definition.biome), String(neighbor.definition.biome))
			if not synergy.is_empty():
				synergy["slots"] = [slot_id, neighbor_id]
				result.append(synergy)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a.id) < String(b.id))
	return result

func preview_synergies(definition: Dictionary, slot_id: String) -> Array[Dictionary]:
	if not slots.has(slot_id):
		return []
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	for neighbor_id: String in neighbor_ids(slot_id):
		var neighbor := (slots[neighbor_id] as Dictionary).installed_island as Dictionary
		if neighbor.is_empty():
			continue
		var synergy := AdjacencySynergyRegistry.match(String(definition.get("biome", "")), String(neighbor.definition.biome))
		if not synergy.is_empty() and not seen.has(synergy.id):
			seen[synergy.id] = true
			synergy["slots"] = [slot_id, neighbor_id]
			result.append(synergy)
	return result

func to_dictionary() -> Dictionary:
	var serialized_slots: Dictionary = {}
	for slot_id: String in slot_ids():
		serialized_slots[slot_id] = (slots[slot_id] as Dictionary).duplicate(true)
	return {"world_seed": world_seed, "revision": revision, "slots": serialized_slots}

static func from_dictionary(data: Dictionary) -> ArchipelagoModel:
	if not data.get("slots") is Dictionary or not (data.get("world_seed") is int or data.get("world_seed") is float):
		return null
	var model := ArchipelagoModel.new(int(data.world_seed))
	model.slots = (data.slots as Dictionary).duplicate(true)
	model.revision = int(data.get("revision", 0))
	for slot_id: String in model.slots:
		var slot_data := model.slots[slot_id] as Dictionary
		if not slot_data.get("coordinate") is Dictionary or not slot_data.get("installed_island") is Dictionary:
			return null
		var installed := slot_data.installed_island as Dictionary
		if not installed.is_empty():
			if not installed.get("definition") is Dictionary or not installed.get("runtime") is Dictionary:
				return null
			if not IslandShardDefinition.validate_dictionary(installed.definition).is_empty() or not IslandRuntimeState.validate_dictionary(installed.runtime).is_empty():
				return null
	model._rebuild_neighbors()
	return model

func _rebuild_neighbors() -> void:
	for slot_id: String in slots:
		(slots[slot_id] as Dictionary)["neighbors"] = []
	for first_id: String in slots:
		for second_id: String in slots:
			if first_id == second_id:
				continue
			var first := (slots[first_id] as Dictionary).coordinate as Dictionary
			var second := (slots[second_id] as Dictionary).coordinate as Dictionary
			var dq := int(first.q) - int(second.q)
			var dr := int(first.r) - int(second.r)
			var distance := (absi(dq) + absi(dr) + absi(dq + dr)) / 2
			if distance == 1:
				((slots[first_id] as Dictionary).neighbors as Array).append(second_id)
	for slot_id: String in slots:
		((slots[slot_id] as Dictionary).neighbors as Array).sort()
