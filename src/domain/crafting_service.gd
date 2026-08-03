class_name CraftingService
extends RefCounted

const RECIPE_ID: String = "reinforced_heart"
const WOOD_COST: int = 3
const SCRAP_COST: int = 2
const MAXIMUM_HEALTH_BONUS: int = 2

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

