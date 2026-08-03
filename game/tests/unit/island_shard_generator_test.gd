extends RefCounted

func run(support: TestSupport) -> void:
	var first := IslandShardGenerator.generate(9001)
	var repeated := IslandShardGenerator.generate(9001)
	var ember := IslandShardGenerator.generate(9002)
	var tempest := IslandShardGenerator.generate(9003)
	support.expect(first == repeated, "same island seed must generate the same shard")
	support.expect(first.get("id") == "verdant_crucible_9001", "shard must have a stable seed-based ID")
	support.expect(first.get("biome") == "forest", "first shard must expose its biome identity")
	support.expect(first.get("tree_yield_bonus") == 1, "positive shard modifier must add one tree yield")
	support.expect(is_equal_approx(float(first.get("enemy_speed_multiplier")), 1.25), "negative shard modifier must increase enemy speed by 25 percent")
	support.expect(ember.get("id") == "emberglass_reach_9002" and ember.get("biome") == "volcano", "second seed must select stable Emberglass identity")
	support.expect(ember.get("player_attack_bonus") == 2 and ember.get("tree_yield_bonus") == -1, "Emberglass must trade gathering yield for attack power")
	support.expect(tempest.get("id") == "tempest_loom_9003" and tempest.get("biome") == "frozen", "third seed must select stable Tempest identity")
	support.expect(is_equal_approx(float(tempest.get("production_interval_multiplier")), 0.5) and tempest.get("enemy_projectile_damage_bonus") == 1, "Tempest must trade faster automation for projectile danger")
	support.expect(IslandShardGenerator.generate(9007).get("id") == "verdant_crucible_9007", "biome selection must cycle deterministically")
