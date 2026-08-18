class_name ExpeditionCycle
extends RefCounted

const DAY_LENGTH_SECONDS: float = 240.0
const SHELTER_DURATION_SECONDS: float = 90.0
const PHASES: Array[String] = ["dawn", "day", "dusk", "night"]
const WEATHER_TYPES: Array[String] = ["clear", "rain", "fog", "gale"]

var world_seed: int = 73000
var elapsed_seconds: float = 0.0
var shelter_remaining: float = 0.0

func _init(seed_value: int = 73000) -> void:
	world_seed = seed_value

func advance(delta: float) -> Dictionary:
	if delta <= 0.0:
		return {"advanced": false, "phase_changed": false, "day_changed": false, "shelter_expired": false}
	var prior_phase := phase()
	var prior_day := day_index()
	var had_shelter := shelter_remaining > 0.0
	elapsed_seconds += delta
	shelter_remaining = maxf(0.0, shelter_remaining - delta)
	return {
		"advanced": true,
		"phase_changed": prior_phase != phase(),
		"day_changed": prior_day != day_index(),
		"shelter_expired": had_shelter and shelter_remaining <= 0.0,
	}

func rest_at_shelter() -> void:
	shelter_remaining = SHELTER_DURATION_SECONDS

func day_index() -> int:
	return floori(maxf(0.0, elapsed_seconds) / DAY_LENGTH_SECONDS)

func phase() -> String:
	var within_day := fposmod(maxf(0.0, elapsed_seconds), DAY_LENGTH_SECONDS)
	if within_day < 30.0:
		return "dawn"
	if within_day < 150.0:
		return "day"
	if within_day < 180.0:
		return "dusk"
	return "night"

func clock_text() -> String:
	var ratio := fposmod(maxf(0.0, elapsed_seconds), DAY_LENGTH_SECONDS) / DAY_LENGTH_SECONDS
	var total_minutes := posmod(360 + floori(ratio * 1440.0), 1440)
	return "%02d:%02d" % [floori(total_minutes / 60.0), total_minutes % 60]

func weather(biome: String = "Forest") -> String:
	var pool: Array[String]
	match biome.to_lower():
		"frozen": pool = ["clear", "fog", "gale", "fog"]
		"volcano": pool = ["clear", "gale", "clear", "fog"]
		"swamp": pool = ["rain", "fog", "rain", "clear"]
		_: pool = ["clear", "rain", "fog", "gale"]
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed + day_index() * 104729 + _stable_biome_offset(biome)
	return pool[rng.randi_range(0, pool.size() - 1)]

func effects(biome: String = "Forest") -> Dictionary:
	var weather_id := weather(biome)
	var result := {
		"enemy_speed_multiplier": 1.12 if phase() == "night" else 1.0,
		"manual_yield_bonus": 1 if phase() == "night" else 0,
		"forage_yield_bonus": 0,
		"wood_yield_bonus": 0,
		"mana_regeneration_bonus": 2.0 if shelter_remaining > 0.0 else 0.0,
		"damage_reduction": 1 if shelter_remaining > 0.0 else 0,
	}
	match weather_id:
		"rain": result.forage_yield_bonus = 1
		"fog": result.forage_yield_bonus = 1
		"gale": result.wood_yield_bonus = 1
	return result

func status_text(biome: String = "Forest") -> String:
	var shelter := "  •  SHELTER %ds" % ceili(shelter_remaining) if shelter_remaining > 0.0 else ""
	return "DAY %d  •  %s  •  %s  •  %s%s" % [day_index() + 1, clock_text(), phase().to_upper(), weather(biome).to_upper(), shelter]

func to_dictionary() -> Dictionary:
	return {"world_seed": world_seed, "elapsed_seconds": elapsed_seconds, "shelter_remaining": shelter_remaining}

func restore(data: Dictionary) -> bool:
	for key: String in ["world_seed", "elapsed_seconds", "shelter_remaining"]:
		if not data.has(key) or not (data[key] is int or data[key] is float):
			return false
	var saved_elapsed := float(data.elapsed_seconds)
	var saved_shelter := float(data.shelter_remaining)
	if saved_elapsed < 0.0 or saved_shelter < 0.0 or saved_shelter > SHELTER_DURATION_SECONDS:
		return false
	world_seed = int(data.world_seed)
	elapsed_seconds = saved_elapsed
	shelter_remaining = saved_shelter
	return true

static func default_state(seed_value: int = 73000) -> Dictionary:
	return {"world_seed": seed_value, "elapsed_seconds": 0.0, "shelter_remaining": 0.0}

static func _stable_biome_offset(biome: String) -> int:
	var value := 0
	for index: int in biome.length():
		value = (value * 31 + biome.unicode_at(index)) % 1000003
	return value
