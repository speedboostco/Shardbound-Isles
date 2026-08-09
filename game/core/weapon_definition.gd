class_name WeaponDefinition
extends Resource

@export var item_id: String
@export var display_name: String
@export_enum("melee", "ranged", "magic") var base_type: String = "melee"
@export var damage: int = 1
@export var attack_speed: float = 1.0
@export var rarity: String = "common"

func validation_errors() -> Array[String]:
	var errors: Array[String] = []
	if item_id.strip_edges().is_empty():
		errors.append("weapon item_id must be a non-empty stable identifier")
	if display_name.strip_edges().is_empty():
		errors.append("weapon display_name must be non-empty")
	if base_type not in ["melee", "ranged", "magic", "sword", "bow", "wand"]:
		errors.append("weapon base_type is unsupported: %s" % base_type)
	if damage <= 0:
		errors.append("weapon damage must be greater than zero")
	if not is_finite(attack_speed) or attack_speed <= 0.0:
		errors.append("weapon attack_speed must be finite and greater than zero")
	if rarity not in ["common", "uncommon", "magic", "rare", "epic", "legendary"]:
		errors.append("weapon rarity is unsupported: %s" % rarity)
	return errors

func is_valid() -> bool:
	return validation_errors().is_empty()
