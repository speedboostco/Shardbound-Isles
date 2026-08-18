extends RefCounted

const PATTERN_PATH := "res://game/core/forest_warden_pattern.gd"

func run(support: TestSupport) -> void:
	var Pattern: Variant = load(PATTERN_PATH)
	support.expect(Pattern != null, "Forest Warden attack rules must load")
	if Pattern == null:
		return
	support.expect(Pattern.phase_for_health(12, 12) == 1, "full health starts in phase one")
	support.expect(Pattern.phase_for_health(7, 12) == 1, "health above half remains phase one")
	support.expect(Pattern.phase_for_health(6, 12) == 2, "half health enters phase two")
	support.expect(Pattern.phase_for_health(0, 12) == 2, "zero health never returns to phase one")
	support.expect(Pattern.telegraph_seconds(Pattern.ROOT_ERUPTION, 1) >= 0.75, "root eruption exposes a dodgeable minimum telegraph")
	support.expect(Pattern.telegraph_seconds(Pattern.THORN_VOLLEY, 1) < Pattern.telegraph_seconds(Pattern.ROOT_ERUPTION, 1), "root eruption is signaled longer than the aimed volley")
	support.expect(Pattern.cooldown_seconds(2) < Pattern.cooldown_seconds(1), "phase two increases cadence instead of only health")
	var first_sequence: Array[String] = []
	var repeated_sequence: Array[String] = []
	var other_seed_sequence: Array[String] = []
	for attack_index: int in 8:
		first_sequence.append(Pattern.attack_kind(314159, attack_index, 1))
		repeated_sequence.append(Pattern.attack_kind(314159, attack_index, 1))
		other_seed_sequence.append(Pattern.attack_kind(314160, attack_index, 1))
	support.expect(first_sequence == repeated_sequence, "same seed reproduces the full attack sequence")
	support.expect(first_sequence != other_seed_sequence, "different encounter seeds separate attack ordering")
	support.expect(Pattern.THORN_VOLLEY in first_sequence and Pattern.ROOT_ERUPTION in first_sequence, "phase one uses both authored attack families")
	var phase_two: Array[String] = []
	for attack_index: int in 8:
		phase_two.append(Pattern.attack_kind(314159, attack_index, 2))
	support.expect(phase_two.count(Pattern.ROOT_ERUPTION) >= first_sequence.count(Pattern.ROOT_ERUPTION), "phase two preserves or increases spatial root pressure")
	var phase_one_angles: Array[float] = Pattern.thorn_angles(1)
	var phase_two_angles: Array[float] = Pattern.thorn_angles(2)
	support.expect(phase_one_angles.size() == 3, "phase one fires a readable three-thorn fan")
	support.expect(phase_two_angles.size() == 5, "phase two expands the fan without unbounded projectiles")
	support.expect(is_equal_approx(phase_one_angles[0], -phase_one_angles[-1]), "phase-one fan is symmetric around its target")
	support.expect(is_equal_approx(phase_two_angles[0], -phase_two_angles[-1]), "phase-two fan is symmetric around its target")
	var origin := Vector2.ZERO
	var direction := Vector2.RIGHT
	support.expect(Pattern.root_lane_contains(origin, direction, Vector2(120, 0)), "root lane includes a player standing on its center line")
	support.expect(not Pattern.root_lane_contains(origin, direction, Vector2(120, 56)), "root lane leaves explicit safe side space")
	support.expect(not Pattern.root_lane_contains(origin, direction, Vector2(-10, 0)), "root lane excludes space behind the Warden")
	support.expect(not Pattern.root_lane_contains(origin, direction, Vector2(300, 0)), "root lane is range bounded")
	support.expect(Pattern.root_lane_contains(origin, Vector2.ZERO, Vector2(90, 0)), "zero aim direction falls back safely without invalid geometry")
	var polygon: PackedVector2Array = Pattern.root_lane_polygon(origin, direction)
	support.expect(polygon.size() == 4, "root telegraph is one simple danger lane rather than a full-screen circle")
	var polygon_is_finite := true
	for point: Vector2 in polygon:
		polygon_is_finite = polygon_is_finite and is_finite(point.x) and is_finite(point.y)
	support.expect(polygon_is_finite, "root telegraph geometry contains only finite points")
	support.expect([Pattern.THORN_VOLLEY, Pattern.ROOT_ERUPTION].all(func(kind: String) -> bool: return Pattern.telegraph_seconds(kind, 2) > 0.0), "every supported attack has a positive phase-two telegraph")
	support.expect(Pattern.attack_kind(314159, 100000, 2) in [Pattern.THORN_VOLLEY, Pattern.ROOT_ERUPTION], "large sequence indices remain bounded to valid attack IDs")
