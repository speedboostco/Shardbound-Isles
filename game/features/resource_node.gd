class_name ResourceNode
extends StaticBody2D

signal depleted(position_value: Vector2, resource_id: String, amount: int)

const DefinitionScript := preload("res://game/core/resource_node_definition.gd")

@export var definition: Resource
var remaining_hits: int
var yield_bonus: int = 0
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
	add_to_group("attackable")
	queue_redraw()

func receive_attack(_damage: int) -> void:
	if remaining_hits <= 0:
		return
	remaining_hits -= 1
	queue_redraw()
	if remaining_hits <= 0:
		depleted.emit(global_position, resource_id, _drop_amount())
		queue_free()

func damage_stage() -> int:
	return clampi(hit_points - remaining_hits, 0, hit_points)

func display_name() -> String:
	return String(definition.get("display_name"))

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

func _draw() -> void:
	if String(definition.get("visual_kind")) == "stone":
		_draw_stone()
	else:
		_draw_tree()

func _draw_tree() -> void:
	var shake := 3.0 if damage_stage() > 0 else 0.0
	draw_rect(Rect2(-8.0 + shake, -5.0, 16.0, 34.0), Color("845b3a"))
	draw_circle(Vector2(shake, -20.0), 29.0, Color("58b66f") if damage_stage() == 0 else Color("8fd277"))
	draw_arc(Vector2(shake, -20.0), 30.0, 0.0, TAU, 24, Color("173d25"), 3.0)

func _draw_stone() -> void:
	var body := PackedVector2Array([
		Vector2(-34, 20), Vector2(-27, -17), Vector2(-5, -34),
		Vector2(27, -25), Vector2(38, 5), Vector2(22, 30), Vector2(-12, 35),
	])
	var fill := Color("8294a6") if damage_stage() > 0 else Color("65798a")
	draw_colored_polygon(body, fill)
	draw_polyline(PackedVector2Array([body[0], body[1], body[2], body[3], body[4], body[5], body[6], body[0]]), Color("263846"), 4.0)
	if damage_stage() >= 1:
		draw_polyline(PackedVector2Array([Vector2(-3, -31), Vector2(-8, -8), Vector2(4, 2), Vector2(-2, 20)]), Color("d5e5ef"), 3.0)
	if damage_stage() >= 2:
		draw_polyline(PackedVector2Array([Vector2(4, 2), Vector2(22, -9), Vector2(34, -1)]), Color("d5e5ef"), 3.0)
		draw_polyline(PackedVector2Array([Vector2(-8, -8), Vector2(-25, 1), Vector2(-31, 16)]), Color("d5e5ef"), 3.0)
