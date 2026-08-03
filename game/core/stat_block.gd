class_name StatBlock
extends RefCounted

const STATS: Array[String] = ["max_health", "damage_multiplier", "attack_speed", "critical_chance", "critical_damage", "movement_speed", "pickup_radius", "gathering_power", "production_speed"]

static func default_base_stats() -> Dictionary:
	return {
		"max_health": 10.0,
		"damage_multiplier": 1.0,
		"attack_speed": 1.0,
		"critical_chance": 0.05,
		"critical_damage": 1.5,
		"movement_speed": 240.0,
		"pickup_radius": 135.0,
		"gathering_power": 1.0,
		"production_speed": 1.0,
	}

static func calculate(base_values: Dictionary, modifiers: Array) -> Dictionary:
	var result := default_base_stats()
	for stat_id: String in base_values:
		result[stat_id] = float(base_values[stat_id])
	var additive: Dictionary = {}
	var multiplicative: Dictionary = {}
	for modifier_value: Variant in modifiers:
		if not modifier_value is Dictionary:
			continue
		var modifier := modifier_value as Dictionary
		var stat_id := String(modifier.get("stat", ""))
		if stat_id not in STATS:
			continue
		var value := float(modifier.get("value", 0.0))
		if String(modifier.get("operation", "add")) == "multiply":
			multiplicative[stat_id] = float(multiplicative.get(stat_id, 1.0)) * (1.0 + value)
		else:
			additive[stat_id] = float(additive.get(stat_id, 0.0)) + value
	for stat_id: String in STATS:
		result[stat_id] = (float(result.get(stat_id, 0.0)) + float(additive.get(stat_id, 0.0))) * float(multiplicative.get(stat_id, 1.0))
	result.max_health = maxf(1.0, float(result.max_health))
	result.attack_speed = maxf(0.1, float(result.attack_speed))
	result.movement_speed = maxf(1.0, float(result.movement_speed))
	result.pickup_radius = maxf(0.0, float(result.pickup_radius))
	result.critical_chance = clampf(float(result.critical_chance), 0.0, 1.0)
	return result

