extends RefCounted

const EXPEDITION_PATH := "res://game/core/expedition_cycle.gd"
const FORAGE_PATH := "res://game/core/renewable_forage_state.gd"

func run(support: TestSupport) -> void:
	var Expedition: Variant = load(EXPEDITION_PATH)
	var Forage: Variant = load(FORAGE_PATH)
	support.expect(Expedition != null, "expedition cycle rules must load")
	support.expect(Forage != null, "renewable forage rules must load")
	if Expedition == null or Forage == null:
		return
	var cycle: Variant = Expedition.new(314159)
	support.expect(cycle.day_index() == 0 and cycle.phase() == "dawn" and cycle.clock_text() == "06:00", "an expedition begins at first dawn with a readable clock")
	cycle.elapsed_seconds = 29.99
	support.expect(cycle.phase() == "dawn", "dawn remains active through its final instant")
	cycle.elapsed_seconds = 30.0
	support.expect(cycle.phase() == "day", "day begins at the authored phase boundary")
	cycle.elapsed_seconds = 150.0
	support.expect(cycle.phase() == "dusk", "dusk begins at the authored phase boundary")
	cycle.elapsed_seconds = 180.0
	support.expect(cycle.phase() == "night", "night begins at the authored phase boundary")
	cycle.elapsed_seconds = 240.0
	support.expect(cycle.day_index() == 1 and cycle.phase() == "dawn" and cycle.clock_text() == "06:00", "the four-minute day wraps deterministically")

	var first_weather: Array[String] = []
	var repeated_weather: Array[String] = []
	var changed_weather: Array[String] = []
	for day: int in 12:
		cycle.elapsed_seconds = day * Expedition.DAY_LENGTH_SECONDS
		first_weather.append(cycle.weather("Forest"))
		var repeat: Variant = Expedition.new(314159)
		repeat.elapsed_seconds = cycle.elapsed_seconds
		repeated_weather.append(repeat.weather("Forest"))
		var changed: Variant = Expedition.new(271828)
		changed.elapsed_seconds = cycle.elapsed_seconds
		changed_weather.append(changed.weather("Forest"))
	support.expect(first_weather == repeated_weather, "the same seed, biome, and day produce the same weather sequence")
	support.expect(first_weather != changed_weather, "a different world seed produces a distinct weather sequence")
	var supported := true
	for weather_id: String in first_weather:
		supported = supported and weather_id in Expedition.WEATHER_TYPES
	support.expect(supported, "weather generation only emits supported states")
	var weather_effects: Dictionary = {}
	for day: int in 256:
		cycle.elapsed_seconds = day * Expedition.DAY_LENGTH_SECONDS
		var weather_id: String = cycle.weather("Forest")
		weather_effects[weather_id] = cycle.effects("Forest")
		if weather_effects.size() == Expedition.WEATHER_TYPES.size():
			break
	support.expect(weather_effects.size() == 4, "a bounded deterministic search reaches every Forest weather state")
	support.expect(int(weather_effects.rain.forage_yield_bonus) == 1 and int(weather_effects.fog.forage_yield_bonus) == 1 and int(weather_effects.gale.wood_yield_bonus) == 1 and int(weather_effects.clear.forage_yield_bonus) == 0, "rain, fog, gale, and clear expose distinct bounded opportunity effects")

	cycle.elapsed_seconds = 190.0
	var night_effects: Dictionary = cycle.effects("Forest")
	support.expect(is_equal_approx(float(night_effects.enemy_speed_multiplier), 1.12) and int(night_effects.manual_yield_bonus) == 1, "night combines bounded danger with a gathering opportunity")
	cycle.rest_at_shelter()
	var shelter_effects: Dictionary = cycle.effects("Forest")
	support.expect(cycle.shelter_remaining == 90.0 and is_equal_approx(float(shelter_effects.mana_regeneration_bonus), 2.0) and int(shelter_effects.damage_reduction) == 1, "rest creates a ninety-second shelter benefit")
	var almost_expired: Dictionary = cycle.advance(89.0)
	support.expect(bool(almost_expired.advanced) and not bool(almost_expired.shelter_expired) and is_equal_approx(cycle.shelter_remaining, 1.0), "shelter counts down without expiring early")
	var expired: Dictionary = cycle.advance(1.0)
	support.expect(bool(expired.shelter_expired) and cycle.shelter_remaining == 0.0, "shelter expiry is emitted exactly at zero")
	var saved_cycle: Dictionary = cycle.to_dictionary()
	var restored_cycle: Variant = Expedition.new()
	support.expect(restored_cycle.restore(saved_cycle) and restored_cycle.to_dictionary() == saved_cycle, "expedition time and shelter state round-trip through primitives")
	support.expect(not restored_cycle.restore({"world_seed": 1, "elapsed_seconds": -1.0, "shelter_remaining": 0.0}), "negative expedition time is rejected")
	support.expect(not restored_cycle.restore({"world_seed": 1, "elapsed_seconds": 0.0, "shelter_remaining": 91.0}), "out-of-range shelter duration is rejected")

	var forage: Variant = Forage.new()
	support.expect(forage.available and is_equal_approx(forage.regrow_remaining, 0.0), "renewable forage begins available")
	support.expect(forage.deplete(45.0) and not forage.available and is_equal_approx(forage.regrow_remaining, 45.0), "forage depletion starts a bounded regrowth timer")
	support.expect(not forage.deplete(45.0), "depleted forage cannot be harvested twice")
	support.expect(not forage.advance(44.0) and is_equal_approx(forage.regrow_remaining, 1.0), "forage remains unavailable before regrowth completes")
	support.expect(forage.advance(1.0) and forage.available and is_equal_approx(forage.regrow_remaining, 0.0), "forage becomes available at the deterministic boundary")
	forage.deplete(60.0)
	var saved_forage: Dictionary = forage.to_dictionary()
	var restored_forage: Variant = Forage.new()
	support.expect(restored_forage.restore(saved_forage, 60.0) and restored_forage.to_dictionary() == saved_forage, "forage regrowth progress round-trips")
	support.expect(not restored_forage.restore({"available": false, "regrow_remaining": 0.0}, 60.0), "an unavailable forage node requires positive remaining time")
	support.expect(not restored_forage.restore({"available": true, "regrow_remaining": 1.0}, 60.0), "an available forage node cannot retain a regrowth timer")
