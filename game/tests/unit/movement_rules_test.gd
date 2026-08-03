extends RefCounted

const SCRIPT_PATH: String = "res://game/core/movement_rules.gd"

func run(support: TestSupport) -> void:
	var rules: Variant = load(SCRIPT_PATH)
	support.expect(rules != null, "movement rules must load")
	if rules == null:
		return
	var analog: Vector2 = rules.velocity(Vector2(0.5, 0.0), 240.0)
	support.expect(is_equal_approx(analog.length(), 120.0), "half-stick input must preserve half movement speed")
	var diagonal: Vector2 = rules.velocity(Vector2.ONE, 240.0)
	support.expect(is_equal_approx(diagonal.length(), 240.0), "diagonal movement must not exceed straight speed")
	support.expect(diagonal.normalized().is_equal_approx(Vector2.ONE.normalized()), "diagonal movement must preserve direction")
	var one_step: Vector2 = rules.displacement(Vector2(0.8, 0.0), 240.0, 1.0)
	var four_steps := Vector2.ZERO
	for index: int in 4:
		four_steps += rules.displacement(Vector2(0.8, 0.0), 240.0, 0.25)
	support.expect(one_step.is_equal_approx(four_steps), "movement distance must be independent of timestep partitioning")
	support.expect(rules.velocity(Vector2.ZERO, 240.0) == Vector2.ZERO, "zero input must not move")
	support.expect(is_equal_approx(rules.velocity(Vector2(4.0, 0.0), 240.0).length(), 240.0), "invalid over-range input must be clamped")
