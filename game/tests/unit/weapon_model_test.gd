extends RefCounted

const DEFINITION_PATH: String = "res://game/core/weapon_definition.gd"
const INSTANCE_PATH: String = "res://game/core/weapon_instance.gd"

func run(support: TestSupport) -> void:
	var definition_script: Variant = load(DEFINITION_PATH)
	var instance_script: Variant = load(INSTANCE_PATH)
	support.expect(definition_script != null, "weapon definition must load")
	support.expect(instance_script != null, "weapon runtime instance must load")
	if definition_script == null or instance_script == null:
		return
	var definition: Variant = definition_script.new()
	definition.item_id = "tideglass_bow"
	definition.display_name = "Tideglass Bow"
	definition.base_type = "ranged"
	definition.damage = 5
	definition.attack_speed = 1.25
	definition.rarity = "uncommon"
	var first: Variant = instance_script.from_definition(definition, 424242, "arena_slime")
	var repeated: Variant = instance_script.from_definition(definition, 424242, "arena_slime")
	support.expect(first.definition_id == "tideglass_bow" and first.base_type == "ranged", "runtime instance must retain definition identity and type")
	support.expect(first.damage == 5 and is_equal_approx(first.attack_speed, 1.25), "runtime instance must contain damage and attack speed")
	support.expect(first.instance_id == repeated.instance_id, "equal seed and context must produce the same stable instance ID")
	var other: Variant = instance_script.from_definition(definition, 424242, "second_slime")
	support.expect(first.instance_id != other.instance_id, "different drop context must produce a distinct instance ID")
	var payload: Dictionary = first.to_dictionary()
	support.expect(["item_id", "base_type", "damage", "attack_speed", "rarity", "seed"].all(func(key: String) -> bool: return payload.has(key)), "serialized weapon must include every canonical M1 field")
	var restored: Variant = instance_script.from_dictionary(payload)
	support.expect(restored.to_dictionary() == payload, "serialized weapon must restore with identical parameters")
	support.expect(payload.get("id") == payload.get("item_id") and payload.get("power") == payload.get("damage"), "legacy equipment aliases must remain save-compatible")
	first.damage = 99
	support.expect(definition.damage == 5, "runtime mutation must not alter its definition")
