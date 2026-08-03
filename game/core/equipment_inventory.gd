class_name EquipmentInventory
extends RefCounted

var items: Array[Dictionary] = []
var equipped_id: String = ""
var scrap: int = 0

func collect(item: Dictionary) -> void:
	items.append(item.duplicate(true))

func comparison_delta(index: int) -> int:
	if not _is_valid_index(index):
		return 0
	return int(items[index].get("power", 0)) - _equipped_power()

func equip(index: int) -> bool:
	if not _is_valid_index(index):
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
	return 1 + _equipped_power()

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
