extends RefCounted

const SCRIPT_PATH: String = "res://game/core/seeded_rng_streams.gd"

func run(support: TestSupport) -> void:
	var rng_script: Variant = load(SCRIPT_PATH)
	support.expect(rng_script != null, "seeded RNG stream implementation must load")
	if rng_script == null:
		return

	var direct_a: RandomNumberGenerator = rng_script.from_seed(12345)
	var direct_b: RandomNumberGenerator = rng_script.from_seed(12345)
	var direct_other: RandomNumberGenerator = rng_script.from_seed(12346)
	var repeated_sequence := _take(direct_a, 4)
	support.expect(repeated_sequence == _take(direct_b, 4), "equal direct seeds must repeat the same sequence")
	support.expect(repeated_sequence != _take(direct_other, 4), "different direct seeds should produce different sequences")

	var first: Variant = rng_script.new(777)
	var repeated: Variant = rng_script.new(777)
	support.expect(_take(first.stream("loot"), 4) == _take(repeated.stream("loot"), 4), "equal root seeds and stream IDs must repeat")
	var cached_stream: RandomNumberGenerator = first.stream("loot")
	support.expect(is_same(cached_stream, first.stream("loot")), "a named stream must preserve its own state")

	var control: Variant = rng_script.new(777)
	var influenced: Variant = rng_script.new(777)
	var expected_world := _take(control.stream("world"), 4)
	_take(influenced.stream("loot"), 12)
	support.expect(expected_world == _take(influenced.stream("world"), 4), "advancing loot must not influence the world stream")
	var separated: Variant = rng_script.new(777)
	support.expect(_take(separated.stream("loot"), 4) != _take(separated.stream("world"), 4), "different stream IDs should derive different sequences")
	support.expect(rng_script.derive_seed(777, "loot") == rng_script.derive_seed(777, "loot"), "stream seed derivation must be stable")
	support.expect(rng_script.derive_seed(777, "loot") != rng_script.derive_seed(778, "loot"), "root seed must participate in stream derivation")

func _take(rng: RandomNumberGenerator, count: int) -> Array[int]:
	var values: Array[int] = []
	for index: int in count:
		values.append(rng.randi())
	return values
