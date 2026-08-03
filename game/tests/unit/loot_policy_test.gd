extends RefCounted

func run(support: TestSupport) -> void:
	var drops: Array[Dictionary] = []
	for index: int in 50:
		drops.append({"rarity": "common" if index < 25 else "rare", "spawn_order": index})
	drops.append({"rarity": "legendary", "spawn_order": -1})
	support.expect(LootDropPolicy.MAX_WORLD_EQUIPMENT < 200, "world equipment policy must impose a finite drop cap")
	support.expect(LootDropPolicy.select_eviction(drops) == 0, "cleanup must choose the oldest lowest-rarity drop")
	drops.remove_at(0)
	support.expect(LootDropPolicy.select_eviction(drops) == 0, "cleanup ordering must remain deterministic after eviction")
	var legendary_only: Array[Dictionary] = [{"rarity": "legendary", "spawn_order": 0}]
	support.expect(LootDropPolicy.select_eviction(legendary_only) == -1, "automatic cleanup must never evict a legendary")
	support.expect(LootDropPolicy.is_important({"rarity": "epic"}) and LootDropPolicy.is_important({"rarity": "legendary"}), "epic and legendary drops must receive important presentation")
	var filter := LootFilter.new()
	filter.minimum_visible_rarity = "rare"
	support.expect(not filter.should_show({"rarity": "common"}) and filter.should_show({"rarity": "rare"}) and filter.should_show({"rarity": "legendary"}), "loot filter must preserve important drops above its threshold")
	filter.auto_salvage_enabled = true
	filter.auto_salvage_below = "rare"
	support.expect(filter.should_auto_salvage({"rarity": "magic"}) and not filter.should_auto_salvage({"rarity": "legendary"}), "optional auto-salvage architecture must always exclude legendary items")
	support.expect(not filter.should_auto_salvage({"rarity": "common", "favorite": true}), "optional auto-salvage must protect favorites")

