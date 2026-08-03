extends RefCounted

func run(support: TestSupport) -> void:
	var aim := Vector2.RIGHT
	var focused := BossAttackPattern.directions(1, aim)
	var maelstrom := BossAttackPattern.directions(2, aim)
	support.expect(focused.size() == 2, "phase one must fire two focused lances")
	support.expect(is_equal_approx(focused[0].angle(), -focused[1].angle()), "focused lances must be symmetric around aim")
	support.expect(maelstrom.size() == 8, "phase two must fire an eight-direction Maelstrom")
	var normalized := true
	for direction: Vector2 in maelstrom:
		normalized = normalized and is_equal_approx(direction.length(), 1.0)
	support.expect(normalized, "all Maelstrom directions must be normalized")
	support.expect(is_equal_approx(BossAttackPattern.telegraph_seconds(1), 0.7) and is_equal_approx(BossAttackPattern.telegraph_seconds(2), 0.4), "phase transition must shorten telegraph duration explicitly")
	var reward := BossReward.generate()
	support.expect(reward.get("id") == "riftwake_core_7777" and reward.get("rarity") == "legendary" and reward.get("power") == 9, "boss reward must be deterministic and legendary")
