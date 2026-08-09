class_name LootGenerator
extends RefCounted

static func generate(seed_value: int, context: String, item_level: int, forced_base_id: String = "", forced_rarity: String = "") -> Dictionary:
	var rng := SeededRngStreams.from_seed(seed_value)
	var bases := ItemBaseRegistry.all()
	var item_base := ItemBaseRegistry.get_definition(forced_base_id)
	if item_base.is_empty():
		item_base = bases[rng.randi_range(0, bases.size() - 1)]
	var rarity := forced_rarity if forced_rarity in RarityRules.ORDER else RarityRules.roll(rng)
	var selected: Array[Dictionary] = []
	var requested_count := RarityRules.affix_count(rarity, rng)
	for _slot: int in requested_count:
		var pool: Array[Dictionary] = []
		var total_weight := 0.0
		for definition: Dictionary in AffixRegistry.ordinary_definitions():
			if AffixRegistry.is_eligible(definition, item_base, selected, maxi(1, item_level), RarityRules.rank(rarity)):
				pool.append(definition)
				total_weight += float(definition.weight)
		if pool.is_empty():
			break
		var cursor := rng.randf_range(0.0, total_weight)
		var chosen: Dictionary = pool.back()
		for candidate: Dictionary in pool:
			cursor -= float(candidate.weight)
			if cursor <= 0.0:
				chosen = candidate
				break
		var rolled_value := snappedf(rng.randf_range(float(chosen.minimum), float(chosen.maximum)), 0.001)
		selected.append({"id": String(chosen.id), "name": String(chosen.name), "category": String(chosen.category), "stat": String(chosen.stat), "operation": String(chosen.operation), "value": rolled_value, "tags": (chosen.tags as Array).duplicate()})
	var legendary_effects: Array[String] = []
	if rarity == "legendary":
		var eligible_effects := LegendaryBehaviorRegistry.eligible_ids(item_base)
		if not eligible_effects.is_empty():
			legendary_effects.append(eligible_effects[rng.randi_range(0, eligible_effects.size() - 1)])
	var level := maxi(1, item_level)
	var base_damage := int(item_base.get("base_damage", 0))
	var damage := base_damage + (level - 1) / 5 if String(item_base.slot) == "weapon" else 0
	var instance_id := "%s_%s_%d_%d" % [context, String(item_base.id), level, seed_value]
	var prefix := rarity.capitalize() + " " if rarity != "common" else ""
	var item := {
		"instance_id": instance_id,
		"item_id": instance_id,
		"id": instance_id,
		"definition_id": String(item_base.id),
		"name": prefix + String(item_base.name),
		"base_type": String(item_base.base_type),
		"archetype": String(item_base.combat_family),
		"slot": String(item_base.slot),
		"item_level": level,
		"rarity": rarity,
		"rarity_color": RarityRules.color(rarity),
		"seed": seed_value,
		"damage": damage,
		"power": damage,
		"attack_speed": float(item_base.attack_speed),
		"base_stats": (item_base.base_stats as Dictionary).duplicate(true),
		"attack_profile": (item_base.get("attack_profile", {}) as Dictionary).duplicate(true),
		"affixes": selected,
		"legendary_effects": legendary_effects,
		"favorite": false,
	}
	if not legendary_effects.is_empty():
		var effect_definition := LegendaryBehaviorRegistry.definition(legendary_effects[0])
		item["legendary_affix_id"] = legendary_effects[0]
		item["legendary_affix_name"] = String(effect_definition.get("name", ""))
		item["legendary_affix_description"] = String(effect_definition.get("description", ""))
	return item

static func validate_item(item: Dictionary) -> bool:
	var item_base := ItemBaseRegistry.get_definition(String(item.get("definition_id", "")))
	if item_base.is_empty() or String(item.get("rarity", "")) not in RarityRules.ORDER or not item.get("affixes") is Array or not item.get("legendary_effects") is Array:
		return false
	var selected: Array = []
	for affix_value: Variant in item.affixes:
		if not affix_value is Dictionary:
			return false
		var affix := affix_value as Dictionary
		var definition := AffixRegistry.get_definition(String(affix.get("id", "")))
		if not AffixRegistry.is_eligible(definition, item_base, selected, int(item.get("item_level", 1)), RarityRules.rank(String(item.get("rarity", "common")))):
			return false
		var rolled_value := float(affix.get("value", NAN))
		if not is_finite(rolled_value) or rolled_value < float(definition.get("minimum", 0.0)) or rolled_value > float(definition.get("maximum", 0.0)):
			return false
		selected.append(affix)
	var limits := RarityRules.affix_range(String(item.rarity))
	if selected.size() < limits.x or selected.size() > limits.y:
		return false
	for effect_value: Variant in item.legendary_effects:
		if String(effect_value) not in LegendaryBehaviorRegistry.eligible_ids(item_base):
			return false
	return true
