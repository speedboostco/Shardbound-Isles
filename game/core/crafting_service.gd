class_name CraftingService
extends RefCounted

const RECIPE_ID: String = "reinforced_heart"
const WOOD_COST: int = 3
const SCRAP_COST: int = 2
const MAXIMUM_HEALTH_BONUS: int = 2
const WHETSTONE_RECIPE_ID: String = "runed_whetstone"
const WHETSTONE_STONE_COST: int = 2
const WHETSTONE_ATTACK_BONUS: int = 1
const HERBAL_COMPASS_RECIPE_ID: String = "herbal_compass"
const HERBAL_COMPASS_MOONLEAF_COST: int = 3
const HERBAL_COMPASS_PICKUP_RADIUS_BONUS: float = 40.0

func can_craft(wood: int, scrap: int, already_crafted: bool) -> bool:
	return not already_crafted and wood >= WOOD_COST and scrap >= SCRAP_COST

func craft(wood: int, scrap: int, already_crafted: bool) -> Dictionary:
	if already_crafted:
		return {"success": false, "reason": "already_crafted"}
	if not can_craft(wood, scrap, false):
		return {"success": false, "reason": "insufficient_resources"}
	return {
		"success": true,
		"recipe_id": RECIPE_ID,
		"wood_spent": WOOD_COST,
		"scrap_spent": SCRAP_COST,
		"maximum_health_bonus": MAXIMUM_HEALTH_BONUS,
	}

func can_craft_whetstone(stone: int, already_crafted: bool) -> bool:
	return not already_crafted and stone >= WHETSTONE_STONE_COST

func craft_whetstone(stone: int, already_crafted: bool) -> Dictionary:
	if already_crafted:
		return {"success": false, "reason": "already_crafted"}
	if not can_craft_whetstone(stone, false):
		return {"success": false, "reason": "insufficient_resources"}
	return {
		"success": true,
		"recipe_id": WHETSTONE_RECIPE_ID,
		"stone_spent": WHETSTONE_STONE_COST,
		"attack_damage_bonus": WHETSTONE_ATTACK_BONUS,
	}

func can_craft_herbal_compass(moonleaf: int, already_crafted: bool) -> bool:
	return not already_crafted and moonleaf >= HERBAL_COMPASS_MOONLEAF_COST

func craft_herbal_compass(moonleaf: int, already_crafted: bool) -> Dictionary:
	if already_crafted:
		return {"success": false, "reason": "already_crafted"}
	if not can_craft_herbal_compass(moonleaf, false):
		return {"success": false, "reason": "insufficient_resources"}
	return {"success": true, "recipe_id": HERBAL_COMPASS_RECIPE_ID, "moonleaf_spent": HERBAL_COMPASS_MOONLEAF_COST, "pickup_radius_bonus": HERBAL_COMPASS_PICKUP_RADIUS_BONUS}
