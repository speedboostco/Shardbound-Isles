class_name ItemBaseRegistry
extends RefCounted

const DEFINITIONS: Array[Dictionary] = [
	{"id": "sword", "name": "Isleforged Sword", "icon_id": "sword", "slot": "weapon", "base_type": "sword", "combat_family": "melee", "base_damage": 6, "attack_speed": 1.05, "base_stats": {}, "tags": ["weapon", "melee"], "attack_profile": {"style": "slash", "range": 82.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0}},
	{"id": "bow", "name": "Tideglass Bow", "icon_id": "bow", "slot": "weapon", "base_type": "bow", "combat_family": "ranged", "base_damage": 4, "attack_speed": 1.35, "base_stats": {}, "tags": ["weapon", "projectile", "arrow"], "attack_profile": {"style": "piercing_arrow", "range": 280.0, "minimum_dot": 0.9, "maximum_targets": 1, "splash_radius": 0.0}},
	{"id": "wand", "name": "Ember Wand", "icon_id": "wand", "slot": "weapon", "base_type": "wand", "combat_family": "magic", "base_damage": 5, "attack_speed": 0.9, "base_stats": {}, "tags": ["weapon", "spell", "fire"], "attack_profile": {"style": "arcane_burst", "range": 175.0, "minimum_dot": 0.35, "maximum_targets": 4, "splash_radius": 84.0}},
	{"id": "iron_helmet", "name": "Ironbark Helm", "icon_id": "helmet", "slot": "helmet", "base_type": "helmet", "combat_family": "armor", "base_damage": 0, "attack_speed": 1.0, "base_stats": {"max_health": 2.0}, "tags": ["armor", "helmet"]},
	{"id": "tide_body", "name": "Tidebound Carapace", "icon_id": "body", "slot": "body", "base_type": "body", "combat_family": "armor", "base_damage": 0, "attack_speed": 1.0, "base_stats": {"max_health": 3.0, "damage_multiplier": 0.03}, "tags": ["armor", "body"]},
	{"id": "swift_boots", "name": "Currentstep Boots", "icon_id": "boots", "slot": "boots", "base_type": "boots", "combat_family": "armor", "base_damage": 0, "attack_speed": 1.0, "base_stats": {"movement_speed": 18.0}, "tags": ["armor", "boots", "movement"]},
	{"id": "coral_ring", "name": "Coral Loop", "icon_id": "ring", "slot": "ring", "base_type": "ring", "combat_family": "jewelry", "base_damage": 0, "attack_speed": 1.0, "base_stats": {"critical_chance": 0.03, "critical_damage": 0.15}, "tags": ["jewelry", "ring"]},
	{"id": "storm_amulet", "name": "Stormglass Amulet", "icon_id": "amulet", "slot": "amulet", "base_type": "amulet", "combat_family": "jewelry", "base_damage": 0, "attack_speed": 1.0, "base_stats": {"pickup_radius": 24.0, "gathering_power": 0.1}, "tags": ["jewelry", "amulet"]},
]

static func all() -> Array[Dictionary]:
	return DEFINITIONS.duplicate(true)

static func get_definition(base_id: String) -> Dictionary:
	for definition: Dictionary in DEFINITIONS:
		if String(definition.get("id", "")) == base_id:
			return definition.duplicate(true)
	return {}

static func validate(definitions: Array[Dictionary] = DEFINITIONS) -> Array[String]:
	var errors: Array[String] = []
	var ids: Dictionary = {}
	var valid_slots := ["weapon", "helmet", "body", "boots", "ring", "amulet"]
	for definition: Dictionary in definitions:
		var base_id := String(definition.get("id", ""))
		if base_id.is_empty() or ids.has(base_id):
			errors.append("item base ID must be non-empty and unique: %s" % base_id)
		ids[base_id] = true
		if String(definition.get("slot", "")) not in valid_slots:
			errors.append("item base has invalid slot: %s" % base_id)
		if String(definition.get("icon_id", "")).is_empty():
			errors.append("item base must define icon_id: %s" % base_id)
		if not definition.get("tags") is Array or not definition.get("base_stats") is Dictionary:
			errors.append("item base must define tags and base_stats: %s" % base_id)
		if String(definition.get("slot", "")) == "weapon" and not definition.get("attack_profile") is Dictionary:
			errors.append("weapon base must define attack_profile: %s" % base_id)
	return errors
