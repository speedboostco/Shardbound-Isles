class_name SharedStorage
extends RefCounted

const RecipeRegistryScript := preload("res://game/core/recipe_registry.gd")

const DEFAULT_CAPACITY: int = 24

var capacity: int
var amounts: Dictionary = {}

func _init(capacity_value: int = DEFAULT_CAPACITY) -> void:
	capacity = maxi(1, capacity_value)

func total() -> int:
	var result := 0
	for value: Variant in amounts.values():
		result += int(value)
	return result

func amount(resource_id: String) -> int:
	return int(amounts.get(resource_id, 0))

func free_space() -> int:
	return maxi(0, capacity - total())

func add(resource_id: String, requested: int) -> Dictionary:
	if resource_id.is_empty() or requested <= 0:
		return {"accepted": 0, "remainder": maxi(0, requested)}
	var accepted := mini(requested, free_space())
	if accepted > 0:
		amounts[resource_id] = amount(resource_id) + accepted
	return {"accepted": accepted, "remainder": requested - accepted}

func remove(resource_id: String, requested: int) -> int:
	var removed := mini(maxi(0, requested), amount(resource_id))
	if removed <= 0:
		return 0
	var remaining := amount(resource_id) - removed
	if remaining == 0:
		amounts.erase(resource_id)
	else:
		amounts[resource_id] = remaining
	return removed

func to_dictionary() -> Dictionary:
	return {"capacity": capacity, "amounts": amounts.duplicate(true)}

static func from_dictionary(data: Dictionary) -> SharedStorage:
	if not data.get("amounts", {}) is Dictionary or int(data.get("capacity", 0)) <= 0:
		return null
	var result := SharedStorage.new(int(data.capacity))
	for key: Variant in (data.amounts as Dictionary):
		var resource_id := String(key)
		var quantity := int(data.amounts[key])
		if resource_id not in RecipeRegistryScript.KNOWN_RESOURCES or quantity < 0:
			return null
		result.amounts[resource_id] = quantity
	if result.total() > result.capacity:
		return null
	return result
