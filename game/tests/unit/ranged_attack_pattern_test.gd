extends RefCounted

func run(support: TestSupport) -> void:
	var ordinary := RangedAttackPattern.angles(false)
	var elite := RangedAttackPattern.angles(true)
	support.expect(ordinary == [0.0], "ordinary ranged volley must contain one centered projectile")
	support.expect(elite.size() == 3, "elite volley must contain three projectiles")
	support.expect(is_equal_approx(float(elite[0]), -float(elite[2])) and is_zero_approx(float(elite[1])), "elite spread must be symmetric around aim direction")
	support.expect(is_equal_approx(RangedAttackPattern.TELEGRAPH_SECONDS, 0.55), "ranged telegraph duration must remain explicit")
	support.expect(is_equal_approx(RangedAttackPattern.COOLDOWN_SECONDS, 1.65), "ranged attack cooldown must remain deterministic")
