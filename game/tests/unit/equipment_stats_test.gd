extends RefCounted

func run(support: TestSupport) -> void:
	var inventory := EquipmentInventory.new()
	var slot_bases := ["sword", "iron_helmet", "tide_body", "swift_boots", "coral_ring", "storm_amulet"]
	for index: int in slot_bases.size():
		inventory.collect(LootGenerator.generate(60000 + index, "slots", 20, slot_bases[index], "rare"))
	support.expect(EquipmentInventory.SLOTS == ["weapon", "helmet", "body", "boots", "ring", "amulet"], "equipment must expose six typed slots")
	var all_equipped := true
	for index: int in slot_bases.size():
		all_equipped = inventory.equip(index) and all_equipped
	support.expect(all_equipped and inventory.equipped_slots.size() == 6, "one item must equip into every typed slot")
	support.expect(EquipmentInventory.SLOTS.all(func(slot: String) -> bool: return not inventory.equipped_item(slot).is_empty()), "all equipped slot references must resolve to owned items")
	var old_weapon_id := String(inventory.equipped_item("weapon").get("id", ""))
	inventory.collect(LootGenerator.generate(60010, "slots", 25, "bow", "epic"))
	support.expect(inventory.equip(6) and String(inventory.equipped_item("weapon").get("base_type", "")) == "bow", "equipping a weapon must replace only the weapon slot")
	support.expect(inventory.items.any(func(item: Dictionary) -> bool: return String(item.get("id", "")) == old_weapon_id), "replaced equipment must remain in inventory")
	support.expect(not inventory.equip_item_in_slot(1, "weapon"), "typed slots must reject incompatible items")
	var base_stats := StatBlock.default_base_stats()
	var first_stats := inventory.derived_stats(base_stats)
	var repeated_stats := inventory.derived_stats(base_stats)
	support.expect(first_stats == repeated_stats, "stat recalculation must not accumulate bonuses across repeated reads")
	support.expect(StatBlock.STATS.all(func(stat_id: String) -> bool: return first_stats.has(stat_id)), "derived block must contain every required M2 stat")
	var formula := StatBlock.calculate({"damage_multiplier": 1.0}, [{"stat": "damage_multiplier", "operation": "add", "value": 0.2}, {"stat": "damage_multiplier", "operation": "multiply", "value": 0.5}])
	support.expect(is_equal_approx(float(formula.damage_multiplier), 1.8), "stats must apply additive modifiers before multiplicative modifiers")
	var before_unequip_health := float(first_stats.max_health)
	support.expect(inventory.unequip("helmet"), "an occupied typed slot must unequip")
	var after_unequip := inventory.derived_stats(base_stats)
	support.expect(float(after_unequip.max_health) <= before_unequip_health and inventory.equipped_item("helmet").is_empty(), "unequipping must remove that item's effects")
	var equipped_weapon_index := inventory.items.find(inventory.equipped_item("weapon"))
	support.expect(inventory.salvage(equipped_weapon_index) == 0, "equipped items must be protected from salvage")
	var favorite_index := 0
	support.expect(inventory.set_favorite(favorite_index, true), "owned item must be markable as favorite")
	support.expect(inventory.salvage(favorite_index) == 0 and inventory.items[favorite_index].get("favorite") == true, "favorite items must be protected from salvage")
	var salvage_index := 1
	if String(inventory.items[salvage_index].get("id", "")) in inventory.equipped_slots.values():
		inventory.unequip(String(inventory.items[salvage_index].get("slot", "")))
	var expected_reward := EquipmentInventory.salvage_value(inventory.items[salvage_index])
	var size_before := inventory.items.size()
	support.expect(inventory.salvage(salvage_index) == expected_reward and expected_reward > 0, "successful salvage reward must depend on rarity and level")
	support.expect(inventory.items.size() == size_before - 1 and inventory.scrap >= expected_reward, "item must be destroyed only after successful salvage")
	support.expect(EquipmentInventory.salvage_value({"rarity": "rare", "item_level": 40}) > EquipmentInventory.salvage_value({"rarity": "rare", "item_level": 1}), "salvage reward must increase with item level")
	var restored := EquipmentInventory.new()
	for item: Dictionary in inventory.items:
		restored.collect(item)
	support.expect(restored.restore_slots(inventory.equipped_slots) and restored.equipped_slots == inventory.equipped_slots, "serialized slot IDs must restore all valid equipment slots")
	support.expect(inventory.comparison(6).has("stat_deltas") and inventory.comparison(6).has("behavior_changes"), "comparison must separate numeric differences from behavior changes")

