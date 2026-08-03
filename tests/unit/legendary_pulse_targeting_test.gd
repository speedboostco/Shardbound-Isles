extends RefCounted

func run(support: TestSupport) -> void:
	var candidates: Array[Dictionary] = [
		{"id": "far", "position": Vector2(116, 0)},
		{"id": "b", "position": Vector2(50, 0)},
		{"id": "a", "position": Vector2(0, 50)},
		{"id": "primary", "position": Vector2(20, 0)},
	]
	var selected := LegendaryPulseTargeting.select_ids(Vector2.ZERO, candidates, 115.0, "primary")
	support.expect(selected == ["a", "b"], "pulse must exclude primary/out-of-range targets and tie-break by stable ID")
	support.expect(LegendaryPulseTargeting.select_ids(Vector2.ZERO, candidates, 49.0, "primary").is_empty(), "pulse radius boundary must exclude farther candidates")
	var reward := BossReward.generate()
	support.expect(reward.get("legendary_affix_id") == "riftwake_pulse", "Riftwake Core must expose stable legendary affix ID")
	support.expect(String(reward.get("legendary_affix_description", "")).contains("pulse"), "legendary reward must describe its behavior")
