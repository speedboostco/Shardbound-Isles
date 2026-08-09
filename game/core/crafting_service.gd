class_name CraftingService
extends RefCounted

const RecipeRegistryScript := preload("res://game/core/recipe_registry.gd")

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

func evaluate(recipe_id: String, resources: Dictionary, unlocks: Dictionary = {}, crafted: Dictionary = {}, output_capacity: int = 1) -> Dictionary:
	var recipe: Dictionary = RecipeRegistryScript.get_definition(recipe_id)
	if recipe.is_empty():
		return {"success": false, "reason": "unknown_recipe", "missing": {}}
	if bool(recipe.get("unique", false)) and bool(crafted.get(recipe_id, false)):
		return {"success": false, "reason": "already_crafted", "missing": {}}
	for requirement_value: Variant in recipe.get("unlock_requirements", []):
		var requirement := String(requirement_value)
		if requirement != "always" and not bool(unlocks.get(requirement, false)):
			return {"success": false, "reason": "locked", "missing": {}, "requirement": requirement}
	if output_capacity < int((recipe.output as Dictionary).get("amount", 1)):
		return {"success": false, "reason": "output_blocked", "missing": {}}
	var missing: Dictionary = {}
	for resource_value: Variant in recipe.inputs:
		var resource_id := String(resource_value)
		var needed := int(recipe.inputs[resource_value])
		var available := int(resources.get(resource_id, 0))
		if available < needed:
			missing[resource_id] = needed - available
	if not missing.is_empty():
		return {"success": false, "reason": "insufficient_resources", "missing": missing}
	var after := resources.duplicate(true)
	for resource_value: Variant in recipe.inputs:
		var resource_id := String(resource_value)
		after[resource_id] = int(after.get(resource_id, 0)) - int(recipe.inputs[resource_value])
	return {"success": true, "recipe": recipe, "resources_after": after, "output": (recipe.output as Dictionary).duplicate(true), "missing": {}}

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
