class_name AffixRegistry
extends RefCounted

const CATEGORIES: Array[String] = ["offensive", "defensive", "utility", "gathering", "production", "hybrid"]
const DEFINITIONS: Array[Dictionary] = [
	{"id": "keen_edge", "name": "Keen", "category": "offensive", "allowed_slots": ["weapon"], "allowed_base_types": [], "minimum": 0.05, "maximum": 0.16, "weight": 12.0, "tags": ["damage"], "stat": "damage_multiplier", "operation": "add", "conflict_group": ""},
	{"id": "rapid_strikes", "name": "Rapid", "category": "offensive", "allowed_slots": ["weapon"], "allowed_base_types": [], "minimum": 0.05, "maximum": 0.2, "weight": 10.0, "tags": ["speed"], "stat": "attack_speed", "operation": "add", "conflict_group": ""},
	{"id": "critical_focus", "name": "Focused", "category": "offensive", "allowed_slots": ["weapon", "ring", "amulet"], "allowed_base_types": [], "minimum": 0.02, "maximum": 0.09, "weight": 8.0, "tags": ["critical"], "stat": "critical_chance", "operation": "add", "conflict_group": ""},
	{"id": "brutal_impact", "name": "Brutal", "category": "offensive", "allowed_slots": ["weapon", "ring"], "allowed_base_types": [], "minimum": 0.1, "maximum": 0.45, "weight": 7.0, "tags": ["critical"], "stat": "critical_damage", "operation": "add", "conflict_group": ""},
	{"id": "vital_shell", "name": "Vital", "category": "defensive", "allowed_slots": ["helmet", "body", "ring", "amulet"], "allowed_base_types": [], "minimum": 1.0, "maximum": 5.0, "weight": 11.0, "tags": ["health"], "stat": "max_health", "operation": "add", "conflict_group": ""},
	{"id": "deep_ward", "name": "Deep-Warded", "category": "defensive", "allowed_slots": ["helmet", "body"], "allowed_base_types": [], "minimum": 0.04, "maximum": 0.14, "weight": 6.0, "tags": ["health"], "stat": "max_health", "operation": "multiply", "conflict_group": ""},
	{"id": "fleet_current", "name": "Fleet", "category": "utility", "allowed_slots": ["boots", "ring", "amulet"], "allowed_base_types": [], "minimum": 8.0, "maximum": 32.0, "weight": 10.0, "tags": ["movement"], "stat": "movement_speed", "operation": "add", "conflict_group": ""},
	{"id": "magnetic_tide", "name": "Magnetic", "category": "utility", "allowed_slots": ["boots", "ring", "amulet"], "allowed_base_types": [], "minimum": 12.0, "maximum": 55.0, "weight": 9.0, "tags": ["pickup"], "stat": "pickup_radius", "operation": "add", "conflict_group": ""},
	{"id": "prospectors_touch", "name": "Prospector's", "category": "gathering", "allowed_slots": ["weapon", "helmet", "boots", "amulet"], "allowed_base_types": [], "minimum": 0.08, "maximum": 0.3, "weight": 9.0, "tags": ["gathering"], "stat": "gathering_power", "operation": "add", "conflict_group": ""},
	{"id": "harvesters_reach", "name": "Harvester's", "category": "gathering", "allowed_slots": ["weapon", "boots"], "allowed_base_types": [], "minimum": 8.0, "maximum": 35.0, "weight": 6.0, "tags": ["gathering", "pickup"], "stat": "pickup_radius", "operation": "add", "conflict_group": ""},
	{"id": "efficient_forge", "name": "Efficient", "category": "production", "allowed_slots": ["body", "ring", "amulet"], "allowed_base_types": [], "minimum": 0.05, "maximum": 0.22, "weight": 7.0, "tags": ["production"], "stat": "production_speed", "operation": "add", "conflict_group": ""},
	{"id": "refiners_luck", "name": "Refiner's", "category": "production", "allowed_slots": ["helmet", "ring", "amulet"], "allowed_base_types": [], "minimum": 0.04, "maximum": 0.18, "weight": 6.0, "tags": ["production", "gathering"], "stat": "gathering_power", "operation": "add", "conflict_group": ""},
	{"id": "battle_harvester", "name": "Battle-Harvester's", "category": "hybrid", "allowed_slots": ["weapon", "body", "amulet"], "allowed_base_types": [], "minimum": 0.04, "maximum": 0.12, "weight": 5.0, "tags": ["damage", "gathering"], "stat": "damage_multiplier", "operation": "add", "conflict_group": ""},
	{"id": "living_quiver", "name": "Living", "category": "hybrid", "allowed_slots": ["weapon"], "allowed_base_types": ["bow"], "minimum": 0.05, "maximum": 0.15, "weight": 5.0, "tags": ["arrow", "projectile", "gathering"], "stat": "attack_speed", "operation": "add", "conflict_group": ""},
	{"id": "ember_conversion", "name": "Ember-Touched", "category": "hybrid", "allowed_slots": ["weapon"], "allowed_base_types": [], "minimum": 0.08, "maximum": 0.18, "weight": 4.0, "tags": ["elemental", "fire"], "stat": "damage_multiplier", "operation": "add", "conflict_group": "elemental_conversion"},
	{"id": "frost_conversion", "name": "Frost-Touched", "category": "hybrid", "allowed_slots": ["weapon"], "allowed_base_types": [], "minimum": 0.08, "maximum": 0.18, "weight": 4.0, "tags": ["elemental", "frost"], "stat": "damage_multiplier", "operation": "add", "conflict_group": "elemental_conversion"},
]

static func all() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for definition: Dictionary in DEFINITIONS:
		result.append(prototype(definition))
	return result

static func ordinary_definitions() -> Array[Dictionary]:
	return all()

static func get_definition(affix_id: String) -> Dictionary:
	for definition: Dictionary in DEFINITIONS:
		if String(definition.get("id", "")) == affix_id:
			return prototype(definition)
	return {}

static func prototype(overrides: Dictionary = {}) -> Dictionary:
	var result := {
		"id": "prototype",
		"display_key": "affix.prototype",
		"name": "Prototype",
		"category": "utility",
		"allowed_slots": [],
		"allowed_base_types": [],
		"allowed_item_tags": [],
		"required_tags": [],
		"excluded_tags": [],
		"minimum_level": 1,
		"maximum_level": 0,
		"minimum_tier": 0,
		"maximum_tier": 0,
		"minimum": 0.0,
		"maximum": 1.0,
		"weight": 1.0,
		"tags": ["utility"],
		"stat": "pickup_radius",
		"operation": "add",
		"conflict_group": "",
	}
	for key: Variant in overrides:
		result[key] = overrides[key]
	if not overrides.has("display_key"):
		result.display_key = "affix.%s" % String(result.id)
	return result

static func eligibility(definition: Dictionary, item_base: Dictionary, selected: Array, item_level: int = 1, item_tier: int = 0) -> Dictionary:
	var reasons: Array[String] = []
	if definition.is_empty():
		reasons.append("missing_definition")
	if item_base.is_empty():
		reasons.append("missing_item_base")
	if not reasons.is_empty():
		return {"eligible": false, "reasons": reasons}
	var normalized := prototype(definition)
	var allowed_slots := definition.get("allowed_slots", []) as Array
	if not allowed_slots.is_empty() and String(item_base.get("slot", "")) not in allowed_slots:
		reasons.append("slot_not_allowed:%s" % String(item_base.get("slot", "")))
	var allowed_types := definition.get("allowed_base_types", []) as Array
	if not allowed_types.is_empty() and String(item_base.get("base_type", "")) not in allowed_types:
		reasons.append("base_type_not_allowed:%s" % String(item_base.get("base_type", "")))
	var item_tags: Array = item_base.get("tags", []) as Array
	var allowed_tags: Array = normalized.allowed_item_tags as Array
	if not allowed_tags.is_empty() and not allowed_tags.any(func(tag: Variant) -> bool: return tag in item_tags):
		reasons.append("no_allowed_item_tag")
	for tag_value: Variant in normalized.required_tags:
		if tag_value not in item_tags:
			reasons.append("missing_required_tag:%s" % String(tag_value))
	for tag_value: Variant in normalized.excluded_tags:
		if tag_value in item_tags:
			reasons.append("excluded_tag:%s" % String(tag_value))
	if item_level < int(normalized.minimum_level):
		reasons.append("below_minimum_level:%d" % int(normalized.minimum_level))
	if int(normalized.maximum_level) > 0 and item_level > int(normalized.maximum_level):
		reasons.append("above_maximum_level:%d" % int(normalized.maximum_level))
	if item_tier < int(normalized.minimum_tier):
		reasons.append("below_minimum_tier:%d" % int(normalized.minimum_tier))
	if int(normalized.maximum_tier) > 0 and item_tier > int(normalized.maximum_tier):
		reasons.append("above_maximum_tier:%d" % int(normalized.maximum_tier))
	var affix_id := String(normalized.get("id", ""))
	for selected_value: Variant in selected:
		var selected_id := String((selected_value as Dictionary).get("id", "")) if selected_value is Dictionary else String(selected_value)
		if selected_id == affix_id:
			reasons.append("duplicate_affix:%s" % affix_id)
		elif are_conflicting(affix_id, selected_id):
			reasons.append("conflict:%s" % selected_id)
	reasons.sort()
	return {"eligible": reasons.is_empty(), "reasons": reasons}

static func is_eligible(definition: Dictionary, item_base: Dictionary, selected: Array, item_level: int = 1, item_tier: int = 0) -> bool:
	return bool(eligibility(definition, item_base, selected, item_level, item_tier).eligible)

static func are_conflicting(first_id: String, second_id: String) -> bool:
	if first_id == second_id:
		return true
	var first := get_definition(first_id)
	var second := get_definition(second_id)
	var first_group := String(first.get("conflict_group", ""))
	return not first_group.is_empty() and first_group == String(second.get("conflict_group", ""))

static func validate(definitions: Array[Dictionary] = []) -> Array[String]:
	var values: Array[Dictionary] = all() if definitions.is_empty() else definitions
	var errors: Array[String] = []
	var ids: Dictionary = {}
	var known_tags := _known_item_tags()
	var known_types: Array[String] = []
	for item_base: Dictionary in ItemBaseRegistry.all():
		var base_type := String(item_base.get("base_type", ""))
		if base_type not in known_types:
			known_types.append(base_type)
	for raw_definition: Dictionary in values:
		var definition := prototype(raw_definition)
		var affix_id := String(definition.get("id", ""))
		if affix_id.is_empty() or ids.has(affix_id):
			errors.append("affix ID must be non-empty and unique: %s" % affix_id)
		ids[affix_id] = true
		if String(definition.get("category", "")) not in CATEGORIES:
			errors.append("affix has invalid category: %s" % affix_id)
		if not (definition.get("minimum") is int or definition.get("minimum") is float) or not (definition.get("maximum") is int or definition.get("maximum") is float) or float(definition.get("minimum", 1.0)) > float(definition.get("maximum", 0.0)):
			errors.append("affix has invalid range: %s" % affix_id)
		if float(definition.get("weight", 0.0)) <= 0.0:
			errors.append("affix weight must be positive: %s" % affix_id)
		if not definition.get("tags") is Array or (definition.get("tags") as Array).is_empty():
			errors.append("affix tags must be non-empty: %s" % affix_id)
		if not definition.get("allowed_slots") is Array or not definition.get("allowed_base_types") is Array:
			errors.append("affix eligibility arrays missing: %s" % affix_id)
		for base_type_value: Variant in definition.allowed_base_types:
			if String(base_type_value) not in known_types:
				errors.append("affix has unknown allowed base type: %s:%s" % [affix_id, String(base_type_value)])
		for tag_value: Variant in definition.required_tags:
			if String(tag_value) not in known_tags:
				errors.append("affix has unknown required tag: %s:%s" % [affix_id, String(tag_value)])
		for tag_value: Variant in definition.excluded_tags:
			if String(tag_value) not in known_tags:
				errors.append("affix has unknown excluded tag: %s:%s" % [affix_id, String(tag_value)])
		if int(definition.minimum_level) < 1 or (int(definition.maximum_level) > 0 and int(definition.maximum_level) < int(definition.minimum_level)):
			errors.append("affix level range is invalid: %s" % affix_id)
		if int(definition.minimum_tier) < 0 or (int(definition.maximum_tier) > 0 and int(definition.maximum_tier) < int(definition.minimum_tier)):
			errors.append("affix tier range is invalid: %s" % affix_id)
		if String(definition.display_key).strip_edges().is_empty():
			errors.append("affix display key is missing: %s" % affix_id)
		if String(definition.get("stat", "")).is_empty() or String(definition.get("operation", "")) not in ["add", "multiply"]:
			errors.append("affix modifier is invalid: %s" % affix_id)
	return errors

static func _known_item_tags() -> Array[String]:
	var result: Array[String] = []
	for item_base: Dictionary in ItemBaseRegistry.all():
		for tag_value: Variant in item_base.get("tags", []):
			var tag := String(tag_value)
			if tag not in result:
				result.append(tag)
	result.sort()
	return result
