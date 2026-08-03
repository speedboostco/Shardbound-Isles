extends RefCounted

func run(support: TestSupport) -> void:
	var first := IslandShardGenerator.generate(9001)
	var repeated := IslandShardGenerator.generate(9001)
	support.expect(first == repeated, "same island seed must generate the same shard")
	support.expect(first.get("id") == "verdant_crucible_9001", "shard must have a stable seed-based ID")
	support.expect(first.get("biome") == "verdant", "first shard must expose its biome identity")
	support.expect(first.get("tree_yield_bonus") == 1, "positive shard modifier must add one tree yield")
	support.expect(is_equal_approx(float(first.get("enemy_speed_multiplier")), 1.25), "negative shard modifier must increase enemy speed by 25 percent")
