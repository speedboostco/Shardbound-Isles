class_name LootFilter
extends RefCounted

var minimum_visible_rarity: String = "common"
var auto_salvage_enabled: bool = false
var auto_salvage_below: String = "common"

func should_show(item: Dictionary) -> bool:
	var rarity := _normalize_rarity(String(item.get("rarity", "common")))
	return rarity == "legendary" or RarityRules.rank(rarity) >= RarityRules.rank(_normalize_rarity(minimum_visible_rarity))

func should_auto_salvage(item: Dictionary) -> bool:
	if not auto_salvage_enabled or bool(item.get("favorite", false)):
		return false
	var rarity := _normalize_rarity(String(item.get("rarity", "common")))
	return rarity != "legendary" and RarityRules.rank(rarity) < RarityRules.rank(_normalize_rarity(auto_salvage_below))

static func _normalize_rarity(rarity: String) -> String:
	return "magic" if rarity == "uncommon" else (rarity if rarity in RarityRules.ORDER else "common")

