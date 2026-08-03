extends RefCounted

func run(support: TestSupport) -> void:
	var weapon_ids := ["sword", "bow", "wand"]
	var weapon_bases: Array[Dictionary] = []
	for base_id: String in weapon_ids:
		weapon_bases.append(ItemBaseRegistry.get_definition(base_id))
	support.expect(weapon_bases.all(func(value: Dictionary) -> bool: return not value.is_empty() and value.get("slot") == "weapon"), "sword, bow, and wand must share the item-base data contract")
	var profiles := weapon_bases.map(func(value: Dictionary) -> String: return JSON.stringify(value.get("attack_profile", {})))
	support.expect(profiles[0] != profiles[1] and profiles[1] != profiles[2] and profiles[0] != profiles[2], "three weapon archetypes must have distinct combat profiles")
	support.expect(ItemBaseRegistry.validate().is_empty(), "authored item-base definitions must validate")
	support.expect(RarityRules.affix_range("common") == Vector2i(0, 0) and RarityRules.affix_range("legendary").y >= 3, "rarity must control ordinary affix count")
	var rarity_counts: Dictionary = {}
	var rarity_rng := SeededRngStreams.from_seed(22001)
	for _index: int in 50000:
		var rarity: String = RarityRules.roll(rarity_rng)
		rarity_counts[rarity] = int(rarity_counts.get(rarity, 0)) + 1
	support.expect(RarityRules.ORDER.all(func(rarity: String) -> bool: return int(rarity_counts.get(rarity, 0)) > 0), "statistical rarity sample must contain every tier")
	support.expect(int(rarity_counts.common) > int(rarity_counts.magic) and int(rarity_counts.magic) > int(rarity_counts.rare) and int(rarity_counts.rare) > int(rarity_counts.epic) and int(rarity_counts.epic) > int(rarity_counts.legendary), "fixed-seed rarity distribution must follow authored weights")
	var ordinary := AffixRegistry.ordinary_definitions()
	support.expect(ordinary.size() >= 12, "M2 must author at least twelve ordinary affixes")
	var categories: Dictionary = {}
	for definition: Dictionary in ordinary:
		categories[String(definition.get("category", ""))] = true
	support.expect(["offensive", "defensive", "utility", "gathering", "production", "hybrid"].all(func(category: String) -> bool: return categories.has(category)), "ordinary registry must cover all six M2 categories")
	support.expect(ordinary.all(func(definition: Dictionary) -> bool: return not String(definition.get("id", "")).is_empty() and float(definition.get("minimum", 0.0)) <= float(definition.get("maximum", -1.0)) and float(definition.get("weight", 0.0)) > 0.0 and definition.get("tags") is Array), "every affix must expose stable ID, range, weight, and tags")
	support.expect(AffixRegistry.validate().is_empty(), "authored affix registry must pass definition validation")
	var broken := ordinary.duplicate(true)
	broken.append({"id": "broken", "minimum": 4.0, "maximum": 1.0, "weight": 0.0, "tags": []})
	support.expect(not AffixRegistry.validate(broken).is_empty(), "validation must reject malformed affix definitions")
	var arrow_affix := AffixRegistry.get_definition("living_quiver")
	support.expect(not AffixRegistry.is_eligible(arrow_affix, ItemBaseRegistry.get_definition("sword"), []), "arrow modifiers must be ineligible for swords")
	support.expect(AffixRegistry.are_conflicting("ember_conversion", "frost_conversion"), "mutually exclusive elemental conversions must conflict")
	var first := LootGenerator.generate(33001, "unit", 18, "bow", "legendary")
	var repeated := LootGenerator.generate(33001, "unit", 18, "bow", "legendary")
	support.expect(first == repeated, "full item pipeline must be deterministic for seed and context")
	support.expect(first.get("base_type") == "bow" and first.get("item_level") == 18 and first.get("rarity") == "legendary" and first.get("affixes") is Array and first.get("legendary_effects") is Array, "generated item must expose every pipeline stage")
	support.expect((first.affixes as Array).size() <= RarityRules.affix_range("legendary").y and not (first.legendary_effects as Array).is_empty(), "legendary behavior must not consume an ordinary affix slot")
	var generated_valid := true
	var generated_serializable := true
	var generated_rarities: Dictionary = {}
	var started_usec := Time.get_ticks_usec()
	for seed_value: int in 10000:
		var item := LootGenerator.generate(40000 + seed_value, "stress", 1 + seed_value % 60)
		generated_rarities[String(item.get("rarity", ""))] = true
		if not LootGenerator.validate_item(item):
			generated_valid = false
		var json := JSON.stringify(item)
		if not JSON.parse_string(json) is Dictionary:
			generated_serializable = false
	var elapsed_usec := Time.get_ticks_usec() - started_usec
	print("M2_LOOT_METRICS %s" % JSON.stringify({"items": 10000, "elapsed_usec": elapsed_usec}))
	support.expect(generated_valid, "ten thousand generated items must contain no duplicate, conflicting, or ineligible affixes")
	support.expect(generated_serializable, "every generated item must JSON round trip")
	support.expect(generated_rarities.size() == RarityRules.ORDER.size(), "ten-thousand-item deterministic sample must exercise every rarity")
	var high_common := LootGenerator.generate(51000, "overlap", 60, "sword", "common")
	var low_rare := LootGenerator.generate(51001, "overlap", 1, "sword", "rare")
	support.expect(int(high_common.get("damage", 0)) > int(low_rare.get("damage", 0)), "rarity must not guarantee superiority over every lower-rarity item")
	support.expect(String(first.get("item_id", "")) == String(first.get("id", "")) and int(first.get("seed", 0)) == 33001, "generated runtime identity must be stable and serializable")

