class_name LootDropPolicy
extends RefCounted

const MAX_WORLD_EQUIPMENT: int = 40

static func select_eviction(drops: Array[Dictionary]) -> int:
	var selected_index := -1
	var selected_rank := 100
	var selected_order := 9223372036854775807
	for index: int in drops.size():
		var drop := drops[index]
		var rarity := LootFilter._normalize_rarity(String(drop.get("rarity", "common")))
		if rarity == "legendary":
			continue
		var rank := RarityRules.rank(rarity)
		var order := int(drop.get("spawn_order", index))
		if rank < selected_rank or (rank == selected_rank and order < selected_order):
			selected_index = index
			selected_rank = rank
			selected_order = order
	return selected_index

static func is_important(item: Dictionary) -> bool:
	return LootFilter._normalize_rarity(String(item.get("rarity", "common"))) in ["epic", "legendary"]

