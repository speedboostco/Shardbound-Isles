extends RefCounted

func run(support: TestSupport) -> void:
	var candidates: Array[Dictionary] = [
		{"id": "near", "position": Vector2(60, 0)},
		{"id": "far", "position": Vector2(220, 5)},
		{"id": "side", "position": Vector2(105, 70)},
		{"id": "splash", "position": Vector2(115, 22)},
	]
	var sword := ItemBaseRegistry.get_definition("sword").attack_profile as Dictionary
	var bow := ItemBaseRegistry.get_definition("bow").attack_profile as Dictionary
	var wand := ItemBaseRegistry.get_definition("wand").attack_profile as Dictionary
	support.expect(AttackProfileRules.select_targets(Vector2.ZERO, Vector2.RIGHT, candidates, sword) == ["near"], "sword must use a short directional slash")
	var bow_targets := AttackProfileRules.select_targets(Vector2.ZERO, Vector2.RIGHT, candidates, bow)
	support.expect(bow_targets == ["near"], "bow must use a narrow long single-target line")
	var far_only: Array[Dictionary] = [{"id": "far", "position": Vector2(220, 5)}]
	support.expect(AttackProfileRules.select_targets(Vector2.ZERO, Vector2.RIGHT, far_only, sword).is_empty() and AttackProfileRules.select_targets(Vector2.ZERO, Vector2.RIGHT, far_only, bow) == ["far"], "bow must reach targets outside sword range")
	var wand_targets := AttackProfileRules.select_targets(Vector2.ZERO, Vector2.RIGHT, candidates, wand)
	support.expect(wand_targets.size() > 1 and wand_targets[0] == "near", "wand must splash around its primary impact")
	support.expect(wand_targets.size() <= int(wand.maximum_targets), "wand splash must respect its target cap")
	var tied: Array[Dictionary] = [{"id": "b", "position": Vector2(40, 0)}, {"id": "a", "position": Vector2(40, 0)}]
	support.expect(AttackProfileRules.select_targets(Vector2.ZERO, Vector2.RIGHT, tied, sword)[0] == "a", "attack target ties must resolve by stable ID")
	support.expect(String(sword.style) != String(bow.style) and String(bow.style) != String(wand.style), "weapon feedback styles must be data-defined")
	support.expect([sword, bow, wand].all(func(profile: Dictionary) -> bool: return profile.has("range") and profile.has("minimum_dot") and profile.has("maximum_targets")), "all archetypes must use one attack-profile data shape")

