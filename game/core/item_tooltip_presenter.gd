class_name ItemTooltipPresenter
extends RefCounted

static func present(item: Dictionary) -> Dictionary:
	var rarity := String(item.get("rarity", "common"))
	var canonical_rarity := "magic" if rarity == "uncommon" else rarity
	var slot := String(item.get("slot", "weapon"))
	var base_lines: Array[String] = []
	if slot == "weapon":
		base_lines.append("BASE  %d damage  •  %.2fx attacks" % [item.get("damage", item.get("power", 0)), item.get("attack_speed", 1.0)])
	var base_stats := item.get("base_stats", {}) as Dictionary
	var stat_ids: Array = base_stats.keys()
	stat_ids.sort()
	for stat_value: Variant in stat_ids:
		var stat_id := String(stat_value)
		base_lines.append("BASE  %s" % format_modifier(stat_id, "add", float(base_stats[stat_id])))
	var affix_lines: Array[String] = []
	for affix_value: Variant in item.get("affixes", []):
		if not affix_value is Dictionary:
			continue
		var affix := affix_value as Dictionary
		affix_lines.append("%s  [%s]  %s" % [String(affix.get("name", affix.get("id", "AFFIX"))).to_upper(), String(affix.get("category", "")).to_upper(), format_modifier(String(affix.get("stat", "")), String(affix.get("operation", "add")), float(affix.get("value", 0.0)))])
	var legendary_lines: Array[String] = []
	var effect_ids: Array = item.get("legendary_effects", []) as Array
	if effect_ids.is_empty() and not String(item.get("legendary_affix_id", "")).is_empty():
		effect_ids = [String(item.legendary_affix_id)]
	for effect_value: Variant in effect_ids:
		var effect := LegendaryBehaviorRegistry.definition(String(effect_value))
		var effect_name := String(effect.get("name", item.get("legendary_affix_name", effect_value)))
		var description := String(effect.get("description", item.get("legendary_affix_description", "Behavior-changing effect.")))
		legendary_lines.append("LEGENDARY — %s: %s" % [effect_name.to_upper(), description])
	return {
		"name": String(item.get("name", "Unknown Item")),
		"level": maxi(1, int(item.get("item_level", 1))),
		"slot": slot,
		"rarity_text": rarity.to_upper(),
		"rarity_color": String(item.get("rarity_color", RarityRules.color(canonical_rarity))),
		"favorite": bool(item.get("favorite", false)),
		"base_lines": base_lines,
		"affix_lines": affix_lines,
		"legendary_lines": legendary_lines,
	}

static func compare(candidate: Dictionary, equipped: Dictionary) -> Dictionary:
	var candidate_stats := _item_stats(candidate)
	var equipped_stats := _item_stats(equipped)
	var deltas: Array[String] = []
	var damage_delta := int(candidate.get("damage", candidate.get("power", 0))) - int(equipped.get("damage", equipped.get("power", 0)))
	var speed_delta := float(candidate.get("attack_speed", 1.0)) - float(equipped.get("attack_speed", 1.0))
	if String(candidate.get("slot", "weapon")) == "weapon":
		deltas.append("DMG %+d" % damage_delta)
		deltas.append("SPEED %+.2fx" % speed_delta)
	for stat_id: String in StatBlock.STATS:
		var delta := float(candidate_stats.get(stat_id, 0.0)) - float(equipped_stats.get(stat_id, 0.0))
		if not is_zero_approx(delta) and stat_id not in ["attack_speed"]:
			deltas.append("%s %+.2f" % [stat_id.replace("_", " ").to_upper(), delta])
	var candidate_tooltip := present(candidate)
	var equipped_tooltip := present(equipped) if not equipped.is_empty() else {"affix_lines": [], "legendary_lines": []}
	return {
		"empty_slot": equipped.is_empty(),
		"candidate_name": String(candidate.get("name", "Unknown Item")),
		"equipped_name": String(equipped.get("name", "EMPTY SLOT")),
		"deltas": deltas,
		"candidate_affixes": (candidate_tooltip.affix_lines as Array).duplicate(),
		"equipped_affixes": (equipped_tooltip.affix_lines as Array).duplicate(),
		"candidate_behaviors": (candidate_tooltip.legendary_lines as Array).duplicate(),
		"equipped_behaviors": (equipped_tooltip.legendary_lines as Array).duplicate(),
	}

static func format_modifier(stat_id: String, operation: String, value: float) -> String:
	var label := stat_id.replace("_", " ").capitalize()
	if stat_id in ["damage_multiplier", "attack_speed", "critical_chance", "critical_damage", "gathering_power", "production_speed"]:
		return "%+.1f%% %s%s" % [value * 100.0, label, " (multiplicative)" if operation == "multiply" else ""]
	return "%+.1f %s%s" % [value, label, " (multiplicative)" if operation == "multiply" else ""]

static func _item_stats(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return StatBlock.calculate({}, [])
	var modifiers: Array[Dictionary] = []
	for stat_id: String in item.get("base_stats", {}):
		modifiers.append({"stat": stat_id, "operation": "add", "value": float((item.base_stats as Dictionary)[stat_id])})
	for affix_value: Variant in item.get("affixes", []):
		if affix_value is Dictionary:
			var affix := affix_value as Dictionary
			modifiers.append({"stat": String(affix.get("stat", "")), "operation": String(affix.get("operation", "add")), "value": float(affix.get("value", 0.0))})
	return StatBlock.calculate({}, modifiers)
