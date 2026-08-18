class_name ResourceNode
extends StaticBody2D

signal depleted(position_value: Vector2, resource_id: String, amount: int)

const DefinitionScript := preload("res://game/core/resource_node_definition.gd")

@export var definition: Resource
var remaining_hits: int
var yield_bonus: int = 0
var _hit_feedback_remaining: float = 0.0
var _visual_sprite: Sprite2D
var _visual_time: float = 0.0
var _visual_frame: int = -1
var hit_points: int:
	get: return int(definition.get("maximum_health")) if definition != null else 1
var resource_id: String:
	get: return String(definition.get("resource_id")) if definition != null else "wood"
var wood_yield: int:
	get: return _drop_amount()
	set(value): yield_bonus = value - int(definition.get("drop_amount")) if definition != null else value - 1

func _ready() -> void:
	if definition == null:
		definition = _fallback_definition()
	remaining_hits = hit_points
	_ensure_collision_shape()
	_ensure_visual_sprite()
	add_to_group("attackable")
	queue_redraw()

func _process(delta: float) -> void:
	_visual_time += maxf(0.0, delta)
	_hit_feedback_remaining = maxf(0.0, _hit_feedback_remaining - delta)
	_update_visual()

func receive_attack(damage: int) -> void:
	if remaining_hits <= 0:
		return
	remaining_hits -= maxi(1, damage)
	_hit_feedback_remaining = 0.14
	_update_visual()
	queue_redraw()
	if remaining_hits <= 0:
		depleted.emit(global_position, resource_id, _drop_amount())
		queue_free()

func damage_stage() -> int:
	return clampi(hit_points - remaining_hits, 0, hit_points)

func display_name() -> String:
	return String(definition.get("display_name"))

func hit_feedback_active() -> bool:
	return _hit_feedback_remaining > 0.0

func _drop_amount() -> int:
	return maxi(0, int(definition.get("drop_amount")) + yield_bonus)

func _fallback_definition() -> Resource:
	var value: Resource = DefinitionScript.new()
	value.set("resource_id", "wood")
	value.set("display_name", "Tree")
	value.set("maximum_health", 2)
	value.set("drop_amount", 3)
	value.set("visual_kind", "tree")
	return value

func _ensure_collision_shape() -> void:
	if get_node_or_null("CollisionShape2D") != null:
		return
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 27.0 if String(definition.get("visual_kind")) == "tree" else 31.0
	collision.shape = shape
	collision.name = "CollisionShape2D"
	add_child(collision)

func _ensure_visual_sprite() -> void:
	var visual_kind := String(definition.get("visual_kind"))
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * (3.0 if visual_kind == "herb" else 4.0)
	_visual_sprite.position = Vector2(0, -12 if visual_kind == "herb" else -20)
	_visual_sprite.z_index = 1
	add_child(_visual_sprite)
	_update_visual()

func _update_visual() -> void:
	if not is_instance_valid(_visual_sprite):
		return
	var kind := String(definition.get("visual_kind"))
	if kind not in ["tree", "stone", "herb"]:
		kind = "tree"
	var frame := AnimationStateRules.frame_index(_visual_time, 1.6 if kind == "tree" else 0.8, 2)
	var authored_frame := 2 if damage_stage() > 0 else frame
	if authored_frame != _visual_frame:
		_visual_sprite.texture = VisualAssetLibrary.resource_texture(kind, authored_frame)
		_visual_frame = authored_frame
	var base_position := Vector2(0, -12 if kind == "herb" else -20)
	var base_scale := 3.0 if kind == "herb" else 4.0
	var ambient := PresentationMotion.wave(_visual_time, 0.42 if kind == "tree" else 0.72, 0.18)
	var hit_offset := 4.0 if _hit_feedback_remaining > 0.0 else 0.0
	_visual_sprite.position = base_position + Vector2(hit_offset, ambient * (1.0 if kind == "herb" else 0.35))
	_visual_sprite.scale = Vector2(base_scale * (1.0 + ambient * 0.012), base_scale * (1.0 - ambient * 0.008))
	_visual_sprite.rotation = ambient * 0.025 if kind == "tree" and _hit_feedback_remaining <= 0.0 else 0.0
	_visual_sprite.modulate = Color("fff1b0") if _hit_feedback_remaining > 0.0 else (Color("d8e39a") if damage_stage() > 0 else Color.WHITE)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(0, 22), 0.0, Vector2(1.0, 0.28))
	draw_circle(Vector2.ZERO, 31.0, Color(0.03, 0.08, 0.09, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
