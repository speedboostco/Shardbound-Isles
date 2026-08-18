class_name ResourceNode
extends StaticBody2D

signal depleted(position_value: Vector2, resource_id: String, amount: int)

const DefinitionScript := preload("res://game/core/resource_node_definition.gd")
const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")
const RenewableForageStateScript := preload("res://game/core/renewable_forage_state.gd")

@export var definition: Resource
var remaining_hits: int
var yield_bonus: int = 0
var _hit_feedback_remaining: float = 0.0
var _visual_sprite: Sprite2D
var _visual_time: float = 0.0
var _visual_frame: int = -1
var renewal: Variant = RenewableForageStateScript.new()
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
	if is_renewable() and renewal.advance(delta):
		remaining_hits = hit_points
		add_to_group("attackable")
		_set_collision_enabled(true)
		_visual_frame = -1
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
		if is_renewable():
			renewal.deplete(_regrow_seconds())
			remove_from_group("attackable")
			_set_collision_enabled(false)
			_visual_frame = -1
			_update_visual()
		else:
			queue_free()

func is_renewable() -> bool:
	return _regrow_seconds() > 0.0

func is_available() -> bool:
	return not is_renewable() or bool(renewal.available)

func regrow_remaining() -> float:
	return float(renewal.regrow_remaining) if is_renewable() else 0.0

func runtime_state() -> Dictionary:
	return renewal.to_dictionary()

func restore_runtime_state(state: Dictionary) -> bool:
	if not is_renewable() or not renewal.restore(state, _regrow_seconds()):
		return false
	remaining_hits = hit_points if renewal.available else 0
	if renewal.available:
		add_to_group("attackable")
	else:
		remove_from_group("attackable")
	_set_collision_enabled(bool(renewal.available))
	_visual_frame = -1
	_update_visual()
	return true

func damage_stage() -> int:
	return clampi(hit_points - remaining_hits, 0, hit_points)

func display_name() -> String:
	return String(definition.get("display_name"))

func hit_feedback_active() -> bool:
	return _hit_feedback_remaining > 0.0

func _drop_amount() -> int:
	return maxi(0, int(definition.get("drop_amount")) + yield_bonus)

func _regrow_seconds() -> float:
	return maxf(0.0, float(definition.get("regrow_seconds"))) if definition != null else 0.0

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

func _set_collision_enabled(enabled: bool) -> void:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", not enabled)

func _update_visual() -> void:
	if not is_instance_valid(_visual_sprite):
		return
	var kind := String(definition.get("visual_kind"))
	if kind not in ["tree", "stone", "herb"]:
		kind = "tree"
	var frame := AnimationStateRules.frame_index(_visual_time, 1.6 if kind == "tree" else 0.8, 2)
	var authored_frame := 2 if damage_stage() > 0 else frame
	if authored_frame != _visual_frame:
		_visual_sprite.texture = VisualAssetLibrary.resource_texture(kind, authored_frame, is_renewable() and not renewal.available)
		_visual_frame = authored_frame
	var base_position := Vector2(0, -12 if kind == "herb" else -20)
	var base_scale := 3.0 if kind == "herb" else 4.0
	var ambient := PresentationMotion.wave(_visual_time, 0.42 if kind == "tree" else 0.72, 0.18)
	var hit_offset := 4.0 if _hit_feedback_remaining > 0.0 else 0.0
	_visual_sprite.position = base_position + Vector2(hit_offset, ambient * (1.0 if kind == "herb" else 0.35))
	_visual_sprite.scale = Vector2(base_scale * (1.0 + ambient * 0.012), base_scale * (1.0 - ambient * 0.008))
	_visual_sprite.rotation = ambient * 0.025 if kind == "tree" and _hit_feedback_remaining <= 0.0 else 0.0
	var authored_color := Color("9ad8a5") if resource_id == "fiber" else (Color("ff9a76") if resource_id == "emberberry" else Color.WHITE)
	_visual_sprite.modulate = Color("718178") if is_renewable() and not renewal.available else (Color("fff1b0") if _hit_feedback_remaining > 0.0 else (Color("d8e39a") if damage_stage() > 0 else authored_color))
	queue_redraw()

func _draw() -> void:
	if not is_renewable() or renewal.available:
		ContactShadowScript.paint(self, "resource", 15.0 if definition != null and String(definition.get("visual_kind")) == "herb" else 22.0)
