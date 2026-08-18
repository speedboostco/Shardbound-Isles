class_name Workbench
extends StaticBody2D

signal interacted

@export var interaction_radius: float = 105.0
var _visual_sprite: Sprite2D
var _visual_time: float = 0.0
var _visual_frame: int = -1
var _interaction_targeted: bool = false

func _ready() -> void:
	add_to_group("interactable")
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(62, 42)
	collision.shape = shape
	add_child(collision)
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * 1.25
	_visual_sprite.position = Vector2(0, -8)
	add_child(_visual_sprite)
	_process(0.0)
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	_visual_time += maxf(0.0, delta)
	var frame := AnimationStateRules.frame_index(_visual_time, 1.5, 2)
	if frame != _visual_frame:
		_visual_sprite.texture = VisualAssetLibrary.structure_texture("workbench", frame == 1)
		_visual_frame = frame
	var wave := PresentationMotion.wave(_visual_time, 0.55)
	_visual_sprite.position.y = -8.0 + wave * 0.45
	_visual_sprite.scale = Vector2(1.25 * (1.0 + wave * 0.008), 1.25 * (1.0 - wave * 0.008))

func is_player_in_range(player_position: Vector2) -> bool:
	return global_position.distance_to(player_position) <= interaction_radius

func interaction_id() -> String:
	return "workbench"

func interaction_label() -> String:
	return "USE WORKBENCH"

func can_interact(player_position: Vector2) -> bool:
	return is_player_in_range(player_position)

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position):
		return false
	interacted.emit()
	return true

func set_interaction_targeted(value: bool) -> void:
	if _interaction_targeted == value:
		return
	_interaction_targeted = value
	queue_redraw()

func _draw() -> void:
	if _interaction_targeted:
		var color := Color("8fe7ff")
		for corner: Vector2 in [Vector2(-45, -38), Vector2(45, -38), Vector2(45, 34), Vector2(-45, 34)]:
			var horizontal := 13.0 if corner.x < 0.0 else -13.0
			var vertical := 13.0 if corner.y < 0.0 else -13.0
			draw_line(corner, corner + Vector2(horizontal, 0), color, 3.0)
			draw_line(corner, corner + Vector2(0, vertical), color, 3.0)
