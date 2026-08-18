class_name ExpeditionContract
extends RefCounted

const STATUSES: Array[String] = ["none", "offered", "active", "completed", "claimed"]
const WEATHER_OBJECTIVES: Dictionary = {
	"clear": {"title": "Sunlit Survey", "objective_kind": "weather_event", "target": 2, "event_type": "sun_marker", "instruction": "Attune two sun markers while the sky is clear."},
	"rain": {"title": "Rainbloom Harvest", "objective_kind": "forage", "target": 3, "event_type": "rainbloom", "instruction": "Harvest three Fiber or Emberberry sources in the rain."},
	"fog": {"title": "Wisps in the Veil", "objective_kind": "weather_event", "target": 2, "event_type": "wisp_cache", "instruction": "Find two wisp caches hidden in the fog."},
	"gale": {"title": "Windfall Provision", "objective_kind": "gather_wood", "target": 4, "event_type": "windfall", "instruction": "Gather four Wood while the gale exposes fresh timber."},
}

var definition: Dictionary = {}
var status: String = "none"
var progress: int = 0
var claimed_event_ids: Array[String] = []

static func generate(world_seed: int, day_index: int, biome: String, weather: String) -> Dictionary:
	var weather_id := weather.to_lower()
	var objective := (WEATHER_OBJECTIVES.get(weather_id, WEATHER_OBJECTIVES.clear) as Dictionary).duplicate(true)
	var contract_seed := world_seed ^ ((day_index + 1) * 104729) ^ _stable_offset("%s:%s" % [biome.to_lower(), weather_id])
	var rng := RandomNumberGenerator.new()
	rng.seed = contract_seed
	var loot_seed := rng.randi_range(100000, 999999)
	var shard_seed := rng.randi_range(10000, 99999)
	return {
		"contract_id": "%s_%s_%d" % [biome.to_lower(), weather_id, day_index],
		"issuer_id": "mira",
		"issuer_name": "Mira",
		"title": String(objective.title),
		"instruction": String(objective.instruction),
		"objective_kind": String(objective.objective_kind),
		"event_type": String(objective.event_type),
		"target": int(objective.target),
		"day_index": day_index,
		"biome": biome,
		"weather": weather_id,
		"reward": {"expedition_marks": 1, "equipment_seed": loot_seed, "shard_seed": shard_seed, "shard_level": clampi(day_index + 1, 1, 30)},
	}

static func validate_definition(value: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for key: String in ["contract_id", "issuer_id", "issuer_name", "title", "instruction", "objective_kind", "event_type", "target", "day_index", "biome", "weather", "reward"]:
		if not value.has(key):
			errors.append("missing %s" % key)
	for key: String in ["contract_id", "issuer_id", "issuer_name", "title", "instruction", "objective_kind", "event_type", "biome", "weather"]:
		if not value.get(key) is String or String(value.get(key, "")).is_empty():
			errors.append("%s must be a non-empty string" % key)
	if String(value.get("weather", "")) not in WEATHER_OBJECTIVES:
		errors.append("unsupported weather")
	if String(value.get("objective_kind", "")) not in ["weather_event", "forage", "gather_wood"]:
		errors.append("unsupported objective kind")
	if not (value.get("target") is int or value.get("target") is float) or int(value.get("target", 0)) <= 0:
		errors.append("target must be positive")
	if not (value.get("day_index") is int or value.get("day_index") is float) or int(value.get("day_index", -1)) < 0:
		errors.append("day index must be non-negative")
	if not value.get("reward") is Dictionary:
		errors.append("reward must be a dictionary")
	else:
		var reward := value.reward as Dictionary
		for reward_key: String in ["expedition_marks", "equipment_seed", "shard_seed", "shard_level"]:
			if not (reward.get(reward_key) is int or reward.get(reward_key) is float) or int(reward.get(reward_key, 0)) <= 0:
				errors.append("reward %s must be positive" % reward_key)
	return errors

func ensure_offer(world_seed: int, day_index: int, biome: String, weather: String) -> Dictionary:
	if status in ["offered", "active", "completed"]:
		return definition.duplicate(true)
	definition = generate(world_seed, day_index, biome, weather)
	status = "offered"
	progress = 0
	claimed_event_ids.clear()
	return definition.duplicate(true)

func accept() -> bool:
	if status != "offered":
		return false
	status = "active"
	return true

func decline() -> bool:
	if status != "offered":
		return false
	definition.clear()
	status = "none"
	progress = 0
	claimed_event_ids.clear()
	return true

func record(objective_kind: String, amount: int = 1, event_id: String = "") -> Dictionary:
	if status != "active" or amount <= 0 or objective_kind != String(definition.get("objective_kind", "")):
		return {"accepted": false, "completed_now": false, "progress": progress}
	if not event_id.is_empty():
		if event_id in claimed_event_ids:
			return {"accepted": false, "completed_now": false, "progress": progress}
		claimed_event_ids.append(event_id)
	var target := int(definition.target)
	progress = mini(target, progress + amount)
	var completed_now := progress >= target
	if completed_now:
		status = "completed"
	return {"accepted": true, "completed_now": completed_now, "progress": progress}

func claim() -> Dictionary:
	if status != "completed":
		return {"success": false, "reward": {}}
	status = "claimed"
	return {"success": true, "reward": (definition.reward as Dictionary).duplicate(true)}

func objective_text() -> String:
	if definition.is_empty():
		return "NO ACTIVE CONTRACT"
	return "%s  %d/%d" % [String(definition.title).to_upper(), progress, int(definition.target)]

func to_dictionary() -> Dictionary:
	return {"definition": definition.duplicate(true), "status": status, "progress": progress, "claimed_event_ids": claimed_event_ids.duplicate()}

func restore(data: Dictionary) -> bool:
	if not data.get("definition") is Dictionary or not data.get("status") is String or not (data.get("progress") is int or data.get("progress") is float) or not data.get("claimed_event_ids") is Array:
		return false
	var saved_status := String(data.status)
	var saved_definition := data.definition as Dictionary
	var saved_progress := int(data.progress)
	if saved_status not in STATUSES:
		return false
	if saved_status == "none":
		if not saved_definition.is_empty() or saved_progress != 0 or not (data.claimed_event_ids as Array).is_empty():
			return false
	else:
		if not validate_definition(saved_definition).is_empty() or saved_progress < 0 or saved_progress > int(saved_definition.target):
			return false
		if saved_status in ["offered", "active"] and saved_progress >= int(saved_definition.target):
			return false
		if saved_status in ["completed", "claimed"] and saved_progress != int(saved_definition.target):
			return false
	var unique_events: Array[String] = []
	for event_value: Variant in data.claimed_event_ids:
		if not event_value is String or String(event_value).is_empty() or String(event_value) in unique_events:
			return false
		unique_events.append(String(event_value))
	definition = saved_definition.duplicate(true)
	if not definition.is_empty():
		definition["target"] = int(definition.target)
		definition["day_index"] = int(definition.day_index)
		var normalized_reward := (definition.reward as Dictionary).duplicate(true)
		for reward_key: String in ["expedition_marks", "equipment_seed", "shard_seed", "shard_level"]:
			normalized_reward[reward_key] = int(normalized_reward[reward_key])
		definition["reward"] = normalized_reward
	status = saved_status
	progress = saved_progress
	claimed_event_ids = unique_events
	return true

static func default_state() -> Dictionary:
	return {"definition": {}, "status": "none", "progress": 0, "claimed_event_ids": []}

static func _stable_offset(value: String) -> int:
	var result := 0
	for index: int in value.length():
		result = (result * 31 + value.unicode_at(index)) % 2147483629
	return result
