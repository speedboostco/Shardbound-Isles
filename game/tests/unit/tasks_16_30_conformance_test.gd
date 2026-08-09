extends RefCounted

func run(support: TestSupport) -> void:
	var definition := WeaponDefinition.new()
	definition.item_id = "test_bow"
	definition.display_name = "Test Bow"
	definition.base_type = "ranged"
	definition.damage = 5
	definition.attack_speed = 1.2
	definition.rarity = "magic"
	support.expect(definition.validation_errors().is_empty(), "a complete weapon definition must validate")
	var broken_definition := WeaponDefinition.new()
	broken_definition.damage = 0
	broken_definition.attack_speed = 0.0
	var definition_errors: Array[String] = broken_definition.validation_errors()
	support.expect(definition_errors.any(func(message: String) -> bool: return message.contains("item_id")), "weapon validation must identify a missing stable ID")
	support.expect(definition_errors.any(func(message: String) -> bool: return message.contains("damage")) and definition_errors.any(func(message: String) -> bool: return message.contains("attack_speed")), "weapon validation must diagnose impossible numeric values")
	var first: WeaponInstance = WeaponInstance.from_definition(definition, 16001, "drop_a")
	var repeated: WeaponInstance = WeaponInstance.from_definition(definition, 16001, "drop_a")
	var other: WeaponInstance = WeaponInstance.from_definition(definition, 16001, "drop_b")
	support.expect(first.instance_id == repeated.instance_id, "fixed weapon inputs must reconstruct the same stable identity")
	support.expect(first.instance_id != other.instance_id, "distinct drop contexts must produce distinct stable identities")
	var payload := first.to_dictionary()
	support.expect(payload.get("instance_id") == first.instance_id and payload.get("item_id") == first.instance_id, "serialized weapons must expose canonical and compatibility identity keys")
	support.expect(WeaponInstance.from_dictionary(payload).to_dictionary() == payload, "canonical weapon payload must round trip exactly")
	var first_drop := LootDropDecision.decide(424242, "arena_first_slime", 0.99)
	var second_drop := LootDropDecision.decide(424242, "arena_second_slime", 0.01)
	support.expect(first_drop == LootDropDecision.decide(424242, "arena_first_slime", 0.99), "fixed loot seed and context must repeat the same drop decision")
	support.expect(not LootDropDecision.decide(1, "boundary", 0.0) and LootDropDecision.decide(1, "boundary", 1.0), "loot decision must handle guaranteed drop and no-drop boundaries")
	support.expect(first_drop and not second_drop, "documented M1 contexts must produce one known drop and one known no-drop")

	support.expect(RarityRules.validate().is_empty(), "authored rarity configuration must validate")
	support.expect(not RarityRules.validate([{"id": "bad", "weight": -1.0, "minimum_affixes": 2, "maximum_affixes": 1, "color": "nope"}]).is_empty(), "malformed rarity configuration must fail validation")
	var one_tier := [{"id": "rare", "weight": 1.0, "minimum_affixes": 2, "maximum_affixes": 2, "color": "ffffff"}]
	support.expect(RarityRules.roll_from_definitions(SeededRngStreams.from_seed(22), one_tier) == "rare", "one eligible rarity tier must be selected deterministically")

	var bow := ItemBaseRegistry.get_definition("bow")
	var required := AffixRegistry.prototype({"id": "requires_arrow", "required_tags": ["arrow"]})
	var excluded := AffixRegistry.prototype({"id": "excludes_arrow", "excluded_tags": ["arrow"]})
	var leveled := AffixRegistry.prototype({"id": "leveled", "minimum_level": 10, "maximum_level": 20})
	support.expect(AffixRegistry.is_eligible(required, bow, [], 10), "required item tags must permit a matching item")
	support.expect(not AffixRegistry.is_eligible(required, ItemBaseRegistry.get_definition("sword"), [], 10), "required item tags must reject a nonmatching item")
	support.expect(not AffixRegistry.is_eligible(excluded, bow, [], 10), "excluded item tags must reject a matching item")
	support.expect(not AffixRegistry.is_eligible(leveled, bow, [], 9) and AffixRegistry.is_eligible(leveled, bow, [], 10), "affix item-level boundaries must be enforced")
	var diagnostic := AffixRegistry.eligibility(required, ItemBaseRegistry.get_definition("sword"), [], 10)
	support.expect(not bool(diagnostic.eligible) and (diagnostic.reasons as Array).has("missing_required_tag:arrow"), "eligibility diagnostics must explain a stable rejection reason")
	var selected_a: Array = [{"id": "frost_conversion"}, {"id": "keen_edge"}]
	var selected_b: Array = selected_a.duplicate(true)
	selected_b.reverse()
	support.expect(AffixRegistry.eligibility(AffixRegistry.get_definition("ember_conversion"), bow, selected_a, 20) == AffixRegistry.eligibility(AffixRegistry.get_definition("ember_conversion"), bow, selected_b, 20), "eligibility result must not depend on selected collection order")
	var unknown_tag_definition := AffixRegistry.prototype({"id": "unknown_tag", "required_tags": ["not_a_real_item_tag"]})
	support.expect(AffixRegistry.validate([unknown_tag_definition]).any(func(message: String) -> bool: return message.contains("unknown required tag")), "controlled item-tag vocabulary must reject unknown tags")

	var generated := LootGenerator.generate(25001, "conformance", 25, "bow", "epic")
	support.expect(generated == LootGenerator.generate(25001, "conformance", 25, "bow", "epic") and LootGenerator.validate_item(generated), "complete generated item pipeline must repeat and validate")
	var rolled_ranges_valid := true
	for affix_value: Variant in generated.affixes:
		var affix := affix_value as Dictionary
		var affix_definition := AffixRegistry.get_definition(String(affix.id))
		rolled_ranges_valid = rolled_ranges_valid and float(affix.value) >= float(affix_definition.minimum) and float(affix.value) <= float(affix_definition.maximum)
	support.expect(rolled_ranges_valid, "all generated affix values must stay inside their authored ranges")
	support.expect((generated.affixes as Array).size() >= RarityRules.affix_range("epic").x, "generated affix count must satisfy the rarity minimum")

	var inventory := EquipmentInventory.new()
	support.expect(inventory.collect(generated) and not inventory.collect(generated), "ownership must reject duplicate stable item IDs")
	var equipment_events: Array[Dictionary] = []
	inventory.equipment_changed.connect(func(slot: String, previous_id: String, current_id: String) -> void: equipment_events.append({"slot": slot, "previous": previous_id, "current": current_id}))
	support.expect(inventory.equip(0) and inventory.equip(0) and equipment_events.size() == 1, "repeated equip must be idempotent and emit one mutation event")
	var slots_before := inventory.equipped_slots.duplicate(true)
	support.expect(not inventory.equip_item_in_slot(0, "helmet") and inventory.equipped_slots == slots_before, "invalid item-slot equip must not mutate authoritative state")
	var clamped := StatBlock.calculate({}, [{"stat": "critical_chance", "operation": "add", "value": 5.0}, {"stat": "attack_speed", "operation": "add", "value": -10.0}])
	support.expect(float(clamped.critical_chance) == 1.0 and float(clamped.attack_speed) == 0.1, "dangerous derived statistics must respect configured clamps")

	inventory.unequip("weapon")
	var plan := inventory.plan_salvage(0)
	support.expect(bool(plan.ok) and int(plan.reward) == EquipmentInventory.salvage_value(generated), "salvage must expose a deterministic validation plan before mutation")
	var committed := inventory.commit_salvage(plan)
	var duplicate_commit := inventory.commit_salvage(plan)
	support.expect(bool(committed.ok) and not bool(duplicate_commit.ok) and inventory.items.is_empty(), "salvage commit must remove exactly once and reject duplicate invocation")
	support.expect(inventory.scrap == int(plan.reward), "atomic salvage must grant its material exactly once")

	var tooltip := ItemTooltipPresenter.present(generated)
	support.expect(String(tooltip.rarity_text) == "EPIC" and not (tooltip.affix_lines as Array).is_empty(), "tooltip presenter must expose textual rarity and rolled affixes without UI state")
	var empty_comparison := ItemTooltipPresenter.compare(generated, {})
	support.expect(bool(empty_comparison.empty_slot) and String(empty_comparison.equipped_name) == "EMPTY SLOT", "same-slot comparison must degrade safely when no item is equipped")
	var current := LootGenerator.generate(25002, "conformance", 12, "bow", "rare")
	var comparison := ItemTooltipPresenter.compare(generated, current)
	support.expect(not bool(comparison.empty_slot) and comparison.has("candidate_affixes") and comparison.has("equipped_affixes") and not JSON.stringify(comparison).contains("item_score"), "comparison presenter must expose both item sides without synthetic scoring")
