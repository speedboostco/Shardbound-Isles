extends RefCounted

func run(support: TestSupport) -> void:
	var wave_one := RiftRules.wave(1)
	var wave_two := RiftRules.wave(2)
	var wave_three := RiftRules.wave(3)
	support.expect(wave_one.map(func(entry: Dictionary) -> String: return String(entry.kind)) == ["chaser", "chaser"], "rift wave one must contain two chasers")
	support.expect(wave_two.map(func(entry: Dictionary) -> String: return String(entry.kind)) == ["chaser", "ranged"], "rift wave two must add ranged pressure")
	support.expect(wave_three.map(func(entry: Dictionary) -> String: return String(entry.kind)) == ["ranged", "elite"], "rift wave three must culminate in elite pressure")
	support.expect((wave_one[0].position as Vector2) == Vector2(-220, -120) and (wave_three[1].position as Vector2) == Vector2(250, 150), "rift spawn coordinates must remain explicit")
	var first_reward := RiftRules.reward(1)
	var second_reward := RiftRules.reward(2)
	support.expect(first_reward.get("id") != second_reward.get("id") and first_reward.get("power") < second_reward.get("power"), "successive runs must grant distinct improving rewards")
