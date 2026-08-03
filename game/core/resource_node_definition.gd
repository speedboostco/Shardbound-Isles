class_name ResourceNodeDefinition
extends Resource

@export var resource_id: String
@export var display_name: String
@export var maximum_health: int = 1
@export var drop_amount: int = 1
@export_enum("tree", "stone") var visual_kind: String = "tree"
