extends RefCounted

func run(support: TestSupport) -> void:
	var first := IslandShardGenerator.generate(9001, 7)
	var repeated := IslandShardGenerator.generate(9001, 7)
	var required := ["shard_id", "seed", "biome", "level", "size", "positive_modifiers", "negative_modifiers", "encounter", "reward_tags", "rarity"]
	support.expect(first == repeated, "same seed and level must generate identical shard definition")
	support.expect(required.all(func(key: String) -> bool: return first.has(key)), "shard must expose every required definition field")
	support.expect(IslandShardDefinition.validate_dictionary(first).is_empty(), "generated definition must pass validation")
	support.expect(first.shard_id == first.id and first.seed == 9001, "shard identity must be stable and compatibility-safe")
	support.expect(first.biome == "forest" and first.level == 7, "seed 9001 must expose a leveled Forest island")
	support.expect(first.resources.has("moonleaf") and first.resources.has("wood") and first.resources.has("stone"), "Forest preview must list its valuable resources")
	support.expect(first.enemies.has("slime") and first.enemies.has("forest_ranger"), "Forest preview must list both enemy archetypes")
	support.expect(String(first.encounter).contains("Grove"), "Forest shard must preview its small encounter")
	support.expect(not first.positive_modifiers.is_empty() and not first.negative_modifiers.is_empty(), "every shard must pair reward with risk")
	support.expect(first.positive_modifiers.size() == first.negative_modifiers.size(), "generation must pair each positive modifier with a negative risk")
	var low_forest := IslandShardGenerator.generate_for_biome(9201, "forest", 2)
	var high_forest := IslandShardGenerator.generate_for_biome(9201, "forest", 20)
	support.expect(low_forest.positive_modifiers != high_forest.positive_modifiers or low_forest.negative_modifiers != high_forest.negative_modifiers, "modifier pool must change with level")
	var volcano := IslandShardGenerator.generate_for_biome(9202, "volcano", 12)
	support.expect(volcano.positive_modifiers.has("volatile_ore"), "Volcano pool must produce Volatile Ore")
	support.expect(not volcano.positive_modifiers.has("overgrown"), "biome-ineligible modifier must never generate")
	support.expect(IslandShardDefinition.validate_dictionary({}).size() >= required.size(), "missing required definition fields must be reported")
	var invalid := first.duplicate(true)
	invalid.positive_modifiers.append(invalid.negative_modifiers[0])
	support.expect(not IslandShardDefinition.validate_dictionary(invalid).is_empty(), "a modifier cannot be both positive and negative")
	var runtime := IslandRuntimeState.create(first)
	support.expect(runtime.definition == first and runtime.destroyed_resources.is_empty(), "runtime must contain copied definition and separate mutable progress")
	runtime.destroyed_resources.append("tree_0")
	support.expect(first.get("destroyed_resources", []).is_empty(), "runtime progress must never mutate shard definition")
	var preview_payload := JSON.stringify(first)
	support.expect(IslandShardDefinition.validate_dictionary(JSON.parse_string(preview_payload) as Dictionary).is_empty(), "uninstalled shard definition must serialize for inventory/UI")
	var started := Time.get_ticks_usec()
	var all_valid := true
	var paired := true
	var biome_counts: Dictionary = {}
	for seed_value: int in range(10000, 20000):
		var shard := IslandShardGenerator.generate(seed_value, 1 + seed_value % 30)
		all_valid = all_valid and IslandShardDefinition.validate_dictionary(shard).is_empty()
		paired = paired and not shard.positive_modifiers.is_empty() and shard.positive_modifiers.size() == shard.negative_modifiers.size()
		biome_counts[shard.biome] = int(biome_counts.get(shard.biome, 0)) + 1
	print("M3_SHARD_METRICS %s" % JSON.stringify({"items": 10000, "elapsed_usec": Time.get_ticks_usec() - started, "biomes": biome_counts.size()}))
	support.expect(all_valid, "10,000 shard generations must remain valid")
	support.expect(paired, "10,000 shard generations must keep risk/reward paired")
	support.expect(biome_counts.size() == IslandShardGenerator.BIOMES.size(), "stress sample must exercise every biome")
	support.expect(first.rarity in RarityRules.ORDER, "shard rarity must use the shared five-tier vocabulary")
	support.expect(first.expected_rewards is Array and not first.expected_rewards.is_empty(), "preview must expose expected rewards")
	support.expect(first.size in ["small", "medium", "large"], "generated island size must be supported")
