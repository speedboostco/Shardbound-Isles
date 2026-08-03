class_name WeaponDefinition
extends Resource

@export var item_id: String
@export var display_name: String
@export_enum("melee", "ranged", "magic") var base_type: String = "melee"
@export var damage: int = 1
@export var attack_speed: float = 1.0
@export var rarity: String = "common"
