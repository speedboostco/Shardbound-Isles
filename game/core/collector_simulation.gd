class_name CollectorSimulation
extends RefCounted

const RADIUS: float = 180.0
const BATCH_LIMIT: int = 8
const STORAGE_CAPACITY: int = 12
const ORDINARY_RESOURCES: Array[String] = ["wood", "stone", "moonleaf"]

var stored: Dictionary = {}

func eligible(candidate: Dictionary, origin: Vector2) -> bool:
	return String(candidate.get("resource_id", "")) in ORDINARY_RESOURCES \
		and String(candidate.get("rarity", "ordinary")) == "ordinary" \
		and String(candidate.get("owner", "world")) == "world" \
		and not bool(candidate.get("encounter_reward", false)) \
		and candidate.get("position") is Vector2 \
		and origin.distance_to(candidate.position as Vector2) <= RADIUS

func collect_batch(candidates: Array[Dictionary], origin: Vector2) -> Dictionary:
	var ordered := candidates.duplicate(true)
	ordered.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return String(left.get("id", "")) < String(right.get("id", "")))
	var collected_ids: Array[String] = []
	var collected_total := 0
	for candidate: Dictionary in ordered:
		if collected_ids.size() >= BATCH_LIMIT or total_stored() >= STORAGE_CAPACITY:
			break
		if not eligible(candidate, origin):
			continue
		var amount := mini(maxi(0, int(candidate.get("amount", 0))), STORAGE_CAPACITY - total_stored())
		if amount <= 0:
			continue
		var resource_id := String(candidate.resource_id)
		stored[resource_id] = int(stored.get(resource_id, 0)) + amount
		collected_total += amount
		collected_ids.append(String(candidate.get("id", "")))
	return {"collected_ids": collected_ids, "amount": collected_total, "stored": stored.duplicate(true)}

func total_stored() -> int:
	var result := 0
	for value: Variant in stored.values():
		result += int(value)
	return result

func flush_to(storage: RefCounted) -> Dictionary:
	var transferred: Dictionary = {}
	for resource_id: String in stored.keys():
		var result: Dictionary = storage.add(resource_id, int(stored[resource_id]))
		var accepted := int(result.accepted)
		if accepted > 0:
			transferred[resource_id] = accepted
			stored[resource_id] = int(stored[resource_id]) - accepted
		if int(stored[resource_id]) <= 0:
			stored.erase(resource_id)
	return transferred

func to_dictionary() -> Dictionary:
	return {"stored": stored.duplicate(true)}

func restore(data: Dictionary) -> bool:
	if not data.get("stored", {}) is Dictionary:
		return false
	stored = (data.stored as Dictionary).duplicate(true)
	return total_stored() <= STORAGE_CAPACITY
