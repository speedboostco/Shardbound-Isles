class_name ItemUpgradeService
extends RefCounted

const MAX_LEVEL: int = 10
const RARE_RESOURCE_START: int = 7

static func cost_for_next(current_level: int) -> Dictionary:
	if current_level < 0 or current_level >= MAX_LEVEL:
		return {}
	var target := current_level + 1
	return {"scrap": 2 + current_level * 2, "moonleaf": 1 if target >= RARE_RESOURCE_START else 0}

static func power_bonus(level: int) -> int:
	return clampi((maxi(0, level) + 1) / 2, 0, 5)

static func preview(item: Dictionary, resources: Dictionary) -> Dictionary:
	if item.is_empty():
		return {"ok": false, "reason": "missing_item"}
	var level := int(item.get("upgrade_level", 0))
	var cost := cost_for_next(level)
	if cost.is_empty():
		return {"ok": false, "reason": "maximum_level"}
	var missing: Dictionary = {}
	for resource_id: String in cost:
		var needed := int(cost[resource_id])
		var available := int(resources.get(resource_id, 0))
		if available < needed:
			missing[resource_id] = needed - available
	var base_power := int(item.get("unupgraded_power", item.get("power", 0) - power_bonus(level)))
	return {"ok": missing.is_empty(), "reason": "ready" if missing.is_empty() else "insufficient_resources", "from_level": level, "to_level": level + 1, "cost": cost, "missing": missing, "power_before": int(item.get("power", 0)), "power_after": base_power + power_bonus(level + 1)}

static func apply(item: Dictionary, resources: Dictionary, confirmed: bool) -> Dictionary:
	if not confirmed:
		return {"success": false, "reason": "confirmation_required", "item": item.duplicate(true), "resources": resources.duplicate(true)}
	var plan := preview(item, resources)
	if not bool(plan.get("ok", false)):
		return {"success": false, "reason": String(plan.get("reason", "invalid")), "item": item.duplicate(true), "resources": resources.duplicate(true)}
	var upgraded := item.duplicate(true)
	if not upgraded.has("unupgraded_power"):
		upgraded["unupgraded_power"] = int(item.get("power", 0)) - power_bonus(int(item.get("upgrade_level", 0)))
	upgraded["upgrade_level"] = int(plan.to_level)
	upgraded["power"] = int(plan.power_after)
	if upgraded.has("damage"):
		upgraded["damage"] = int(upgraded.unupgraded_power) + power_bonus(int(plan.to_level))
	var remaining := resources.duplicate(true)
	for resource_id: String in (plan.cost as Dictionary):
		remaining[resource_id] = int(remaining.get(resource_id, 0)) - int(plan.cost[resource_id])
	return {"success": true, "item": upgraded, "resources": remaining, "cost": (plan.cost as Dictionary).duplicate(true)}

