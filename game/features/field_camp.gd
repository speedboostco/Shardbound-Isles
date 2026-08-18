class_name FieldCamp
extends StaticBody2D

signal rest_requested

const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")

@export var interaction_radius: float = 115.0
var target_player: Node2D
var ration_count: Callable
var _visual_sprite: Sprite2D
var _visual_time: float = 0.0
var _interaction_targeted: bool = false

func _ready() -> void:
	add_to_group("interactable")
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 28.0
	collision.shape = shape
	add_child(collision)
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.texture = VisualAssetLibrary.living_world_texture("firefly_hollow", 0)
	_visual_sprite.scale = Vector2.ONE * 1.25
	_visual_sprite.position = Vector2(0, -12)
	_visual_sprite.z_index = 1
	add_child(_visual_sprite)
	queue_redraw()

func configure(player_value: Node2D, ration_count_value: Callable) -> void:
	target_player = player_value
	ration_count = ration_count_value

func _process(delta: float) -> void:
	_visual_time += maxf(0.0, delta)
	if is_instance_valid(_visual_sprite):
		var frame := AnimationStateRules.frame_index(_visual_time, 1.8, 2)
		_visual_sprite.texture = VisualAssetLibrary.living_world_texture("firefly_hollow", frame)
		_visual_sprite.position.y = -12.0 + PresentationMotion.wave(_visual_time, 0.7) * 0.6
	if _interaction_targeted:
		queue_redraw()

func interaction_id() -> String:
	return "field_camp"

func interaction_label() -> String:
	var count := int(ration_count.call()) if ration_count.is_valid() else 0
	return "REST AT CAMP — %d RATION%s" % [count, "" if count == 1 else "S"] if count > 0 else "FIELD CAMP — CRAFT A TRAIL RATION"

func can_interact(player_position: Vector2) -> bool:
	return global_position.distance_to(player_position) <= interaction_radius and ration_count.is_valid() and int(ration_count.call()) > 0

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position):
		return false
	rest_requested.emit()
	return true

func set_interaction_targeted(value: bool) -> void:
	if _interaction_targeted == value:
		return
	_interaction_targeted = value
	queue_redraw()

func _draw() -> void:
	ContactShadowScript.paint(self, "obstacle", 24.0)
	if _interaction_targeted:
		for corner: Vector2 in [Vector2(-38, -34), Vector2(38, -34), Vector2(38, 30), Vector2(-38, 30)]:
			var horizontal := 11.0 if corner.x < 0.0 else -11.0
			var vertical := 11.0 if corner.y < 0.0 else -11.0
			draw_line(corner, corner + Vector2(horizontal, 0), Color("ffd36e"), 3.0)
			draw_line(corner, corner + Vector2(0, vertical), Color("ffd36e"), 3.0)
