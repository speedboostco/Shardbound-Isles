class_name EquipmentInventory
extends RefCounted

const SLOTS: Array[String] = ["weapon", "helmet", "body", "boots", "ring", "amulet"]

var items: Array[Dictionary] = []
var equipped_slots: Dictionary = {}
var equipped_id: String:
	get: return String(equipped_slots.get("weapon", ""))
	set(value):
		if value.is_empty():
			equipped_slots.erase("weapon")
		else:
			equipped_slots["weapon"] = value
var scrap: int = 0
var compatible_types: Array[String]

func _init(compatible_types_value: Array[String] = ["melee", "ranged", "magic", "sword", "bow", "wand"]) -> void:
	compatible_types = compatible_types_value.duplicate()

func collect(item: Dictionary) -> void:
	var owned := item.duplicate(true)
	if not owned.has("favorite"):
		owned["favorite"] = false
	items.append(owned)

func comparison_delta(index: int) -> int:
	if not _is_valid_index(index):
		return 0
	return int(items[index].get("power", 0)) - _equipped_power()

func comparison(index: int) -> Dictionary:
	if not _is_valid_index(index):
		return {"stat_deltas": {}, "behavior_changes": []}
	var candidate := items[index]
	var slot := _item_slot(candidate)
	var current := equipped_item(slot)
	var candidate_modifiers := _item_modifiers(candidate)
	var current_modifiers := _item_modifiers(current)
	var candidate_stats := StatBlock.calculate({}, candidate_modifiers)
	var current_stats := StatBlock.calculate({}, current_modifiers)
	var deltas: Dictionary = {}
	for stat_id: String in StatBlock.STATS:
		var delta := float(candidate_stats[stat_id]) - float(current_stats[stat_id])
		if not is_zero_approx(delta):
			deltas[stat_id] = delta
	var behaviors: Array[String] = []
	for effect_value: Variant in candidate.get("legendary_effects", []):
		if effect_value not in current.get("legendary_effects", []):
			behaviors.append(String(effect_value))
	return {"stat_deltas": deltas, "behavior_changes": behaviors}

func equip(index: int) -> bool:
	if not _is_valid_index(index):
		return false
	return equip_item_in_slot(index, _item_slot(items[index]))

func equip_item_in_slot(index: int, slot: String) -> bool:
	if not _is_valid_index(index) or slot not in SLOTS:
		return false
	var item := items[index]
	if _item_slot(item) != slot:
		return false
	if slot == "weapon":
		var family := String(item.get("archetype", item.get("base_type", "")))
		var base_type := String(item.get("base_type", family))
		if family not in compatible_types and base_type not in compatible_types:
			return false
	var item_id := String(item.get("id", ""))
	if item_id.is_empty():
		return false
	equipped_slots[slot] = item_id
	return true

func unequip(slot: String = "weapon") -> bool:
	if slot not in equipped_slots:
		return false
	equipped_slots.erase(slot)
	return true

func restore_slots(saved_slots: Dictionary) -> bool:
	equipped_slots.clear()
	for slot_value: Variant in saved_slots:
		var slot := String(slot_value)
		var item_id := String(saved_slots[slot_value])
		if slot not in SLOTS or not items.any(func(item: Dictionary) -> bool: return String(item.get("id", "")) == item_id and _item_slot(item) == slot):
			return false
		equipped_slots[slot] = item_id
	return true

func set_favorite(index: int, favorite: bool) -> bool:
	if not _is_valid_index(index):
		return false
	items[index]["favorite"] = favorite
	return true

func salvage(index: int) -> int:
	if not _is_valid_index(index):
		return 0
	var item := items[index]
	if String(item.get("id", "")) in equipped_slots.values() or bool(item.get("favorite", false)):
		return 0
	var reward := salvage_value(item)
	if reward <= 0:
		return 0
	items.remove_at(index)
	scrap += reward
	return reward

func attack_damage() -> int:
	return 1 + int(equipped_item("weapon").get("damage", _equipped_power()))

func attack_speed() -> float:
	return maxf(0.1, float(equipped_item("weapon").get("attack_speed", 1.0)))

func equipped_item(slot: String = "weapon") -> Dictionary:
	var target_id := String(equipped_slots.get(slot, ""))
	for item: Dictionary in items:
		if String(item.get("id", "")) == target_id:
			return item
	return {}

func equipped_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for slot: String in SLOTS:
		var item := equipped_item(slot)
		if not item.is_empty():
			result.append(item)
	return result

func derived_stats(base_stats: Dictionary) -> Dictionary:
	var modifiers: Array[Dictionary] = []
	for item: Dictionary in equipped_items():
		var item_base_stats := item.get("base_stats", {}) as Dictionary
		for stat_id: String in item_base_stats:
			modifiers.append({"stat": stat_id, "operation": "add", "value": float(item_base_stats[stat_id])})
		modifiers.append_array(_item_modifiers(item))
	return StatBlock.calculate(base_stats, modifiers)

func _item_modifiers(item: Dictionary) -> Array[Dictionary]:
	var modifiers: Array[Dictionary] = []
	for affix_value: Variant in item.get("affixes", []):
		if affix_value is Dictionary:
			var affix := affix_value as Dictionary
			modifiers.append({"stat": String(affix.get("stat", "")), "operation": String(affix.get("operation", "add")), "value": float(affix.get("value", 0.0))})
	return modifiers

func _equipped_power() -> int:
	return int(equipped_item("weapon").get("power", 0))

func _item_slot(item: Dictionary) -> String:
	return String(item.get("slot", "weapon"))

func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < items.size()

static func salvage_value(item: Dictionary) -> int:
	var base := salvage_value_for_rarity(String(item.get("rarity", "common")))
	return base + maxi(0, int(item.get("item_level", 1)) - 1) / 10

static func salvage_value_for_rarity(rarity: String) -> int:
	match rarity:
		"magic", "uncommon":
			return 2
		"rare":
			return 4
		"epic":
			return 7
		"legendary":
			return 10
		_:
			return 1
