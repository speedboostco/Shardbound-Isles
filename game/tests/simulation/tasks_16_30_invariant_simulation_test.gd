extends RefCounted

func run(support: TestSupport, _scene_tree: SceneTree) -> Dictionary:
	var first := _scenario()
	var repeated := _scenario()
	support.expect(first == repeated, "fixed equipment mutation and salvage simulation must repeat exactly")
	support.expect(bool(first.unique_ownership), "random equipment operations must preserve unique ownership")
	support.expect(int(first.equipped_after_clear) == 0, "clearing every slot must restore an unequipped baseline")
	support.expect(bool(first.baseline_restored), "derived stats must return exactly to baseline after all equipment is removed")
	support.expect(int(first.salvaged_items) == int(first.initial_items), "batch salvage must consume every eligible owned item exactly once")
	support.expect(int(first.scrap) == int(first.expected_scrap), "batch salvage must conserve deterministic material value")
	return first

func _scenario() -> Dictionary:
	var inventory := EquipmentInventory.new()
	var bases := ["sword", "bow", "wand", "iron_helmet", "tide_body", "swift_boots", "coral_ring", "storm_amulet"]
	for index: int in 48:
		inventory.collect(LootGenerator.generate(30000 + index, "invariant", 1 + index, bases[index % bases.size()], RarityRules.ORDER[index % RarityRules.ORDER.size()]))
	var initial_items := inventory.items.size()
	var rng := SeededRngStreams.from_seed(30100)
	for _step: int in 500:
		var index := rng.randi_range(0, inventory.items.size() - 1)
		var slot := String(inventory.items[index].slot)
		if rng.randi_range(0, 3) == 0:
			inventory.unequip(slot)
		else:
			inventory.equip(index)
	for slot: String in EquipmentInventory.SLOTS:
		inventory.unequip(slot)
	var baseline := StatBlock.default_base_stats()
	var restored := inventory.derived_stats(baseline) == baseline
	var ids: Dictionary = {}
	for item: Dictionary in inventory.items:
		ids[String(item.id)] = true
	var expected_scrap := 0
	var salvaged := 0
	while not inventory.items.is_empty():
		var plan := inventory.plan_salvage(0)
		if not bool(plan.ok):
			break
		expected_scrap += int(plan.reward)
		if bool(inventory.commit_salvage(plan).ok):
			salvaged += 1
	return {
		"seed": 30100,
		"initial_items": initial_items,
		"unique_ownership": ids.size() == initial_items,
		"equipped_after_clear": inventory.equipped_slots.size(),
		"baseline_restored": restored,
		"salvaged_items": salvaged,
		"expected_scrap": expected_scrap,
		"scrap": inventory.scrap,
	}

