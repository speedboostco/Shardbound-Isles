class_name SurvivalPreparation
extends RefCounted

const MAX_RATIONS: int = 3
const PREPARED_HARVESTS_PER_REST: int = 6
const REST_HEALTH: int = 4
const REST_MANA: float = 24.0

var rations: int = 0
var prepared_harvests: int = 0

func ration_capacity() -> int:
	return MAX_RATIONS - rations

func add_ration(amount: int = 1) -> bool:
	if amount <= 0 or rations + amount > MAX_RATIONS:
		return false
	rations += amount
	return true

func consume_for_rest() -> Dictionary:
	if rations <= 0:
		return {"success": false, "reason": "no_rations"}
	rations -= 1
	prepared_harvests = PREPARED_HARVESTS_PER_REST
	return {"success": true, "health": REST_HEALTH, "mana": REST_MANA, "prepared_harvests": prepared_harvests}

func resolve_gather_yield(base_amount: int) -> int:
	var safe_amount := maxi(0, base_amount)
	if safe_amount == 0 or prepared_harvests <= 0:
		return safe_amount
	prepared_harvests -= 1
	return safe_amount + 1

func to_dictionary() -> Dictionary:
	return {"rations": rations, "prepared_harvests": prepared_harvests}

func restore(data: Dictionary) -> bool:
	var ration_value: Variant = data.get("rations")
	var harvest_value: Variant = data.get("prepared_harvests")
	if not (ration_value is int or ration_value is float) or not (harvest_value is int or harvest_value is float):
		return false
	if not is_equal_approx(float(ration_value), float(int(ration_value))) or not is_equal_approx(float(harvest_value), float(int(harvest_value))):
		return false
	var saved_rations := int(ration_value)
	var saved_harvests := int(harvest_value)
	if saved_rations < 0 or saved_rations > MAX_RATIONS or saved_harvests < 0 or saved_harvests > PREPARED_HARVESTS_PER_REST:
		return false
	rations = saved_rations
	prepared_harvests = saved_harvests
	return true

static func default_state() -> Dictionary:
	return {"rations": 0, "prepared_harvests": 0}
