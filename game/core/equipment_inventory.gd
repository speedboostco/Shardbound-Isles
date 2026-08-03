class_name EquipmentInventory
extends RefCounted

var items: Array[Dictionary] = []
var equipped_id: String = ""
var scrap: int = 0
var compatible_types: Array[String]

func _init(compatible_types_value: Array[String] = ["melee", "ranged", "magic"]) -> void:
	compatible_types = compatible_types_value.duplicate()

func collect(item: Dictionary) -> void:
	items.append(item.duplicate(true))

func comparison_delta(index: int) -> int:
	if not _is_valid_index(index):
		return 0
	return int(items[index].get("power", 0)) - _equipped_power()

func equip(index: int) -> bool:
	if not _is_valid_index(index):
		return false
	var base_type := String(items[index].get("base_type", items[index].get("archetype", "")))
	if base_type not in compatible_types:
		return false
	equipped_id = String(items[index].get("id", ""))
	return not equipped_id.is_empty()

func unequip() -> bool:
	if equipped_id.is_empty():
		return false
	equipped_id = ""
	return true

func salvage(index: int) -> int:
	if not _is_valid_index(index):
		return 0
	var item := items[index]
	if String(item.get("id", "")) == equipped_id:
		return 0
	var reward := salvage_value_for_rarity(String(item.get("rarity", "common")))
	items.remove_at(index)
	scrap += reward
	return reward

func attack_damage() -> int:
	return 1 + int(equipped_item().get("damage", _equipped_power()))

func attack_speed() -> float:
	return maxf(0.1, float(equipped_item().get("attack_speed", 1.0)))

func equipped_item() -> Dictionary:
	for item: Dictionary in items:
		if String(item.get("id", "")) == equipped_id:
			return item
	return {}

func _equipped_power() -> int:
	return int(equipped_item().get("power", 0))

func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < items.size()

static func salvage_value_for_rarity(rarity: String) -> int:
	match rarity:
		"uncommon":
			return 2
		"rare":
			return 4
		"legendary":
			return 10
		_:
			return 1
