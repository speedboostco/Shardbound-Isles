class_name RiftPortal
extends Node2D

signal interacted
signal availability_changed

@export var interaction_radius: float = 95.0
var unlocked: bool = false
var _visual_sprite: Sprite2D

func _ready() -> void:
	add_to_group("interactable")
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * 1.55
	_visual_sprite.position = Vector2(0, -10)
	_visual_sprite.z_index = 1
	add_child(_visual_sprite)
	_refresh_visual()

func unlock() -> bool:
	if unlocked:
		return false
	unlocked = true
	_refresh_visual()
	queue_redraw()
	availability_changed.emit()
	return true

func is_player_in_range(player_position: Vector2) -> bool:
	return unlocked and global_position.distance_to(player_position) <= interaction_radius

func interaction_id() -> String:
	return "rift_portal"

func interaction_label() -> String:
	return "ENTER RIFT"

func can_interact(player_position: Vector2) -> bool:
	return is_player_in_range(player_position)

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position):
		return false
	interacted.emit()
	return true

func _draw() -> void:
	if unlocked:
		draw_arc(Vector2.ZERO, interaction_radius, 0.0, TAU, 40, Color(0.7, 0.48, 1.0, 0.2), 2.0)

func _refresh_visual() -> void:
	if is_instance_valid(_visual_sprite):
		_visual_sprite.texture = VisualAssetLibrary.structure_texture("rift_portal", unlocked)
		_visual_sprite.modulate = Color.WHITE if unlocked else Color(0.62, 0.68, 0.72, 0.8)
