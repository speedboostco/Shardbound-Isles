class_name WorldPickup
extends Area2D

signal collected(kind: String, payload: Variant)

const MERGE_RADIUS: float = 48.0

var kind: String = "wood"
var payload: Variant = 1
var target: Node2D
var attraction_radius: float = 135.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	var distance := global_position.distance_to(target.global_position)
	if distance <= attraction_radius:
		global_position = global_position.move_toward(target.global_position, 420.0 * delta)
	if distance <= 24.0:
		collected.emit(kind, payload)
		queue_free()

func collect_immediately() -> void:
	collected.emit(kind, payload)
	queue_free()

func merge_amount(amount: int) -> bool:
	if kind not in ["wood", "stone"] or not payload is int or amount <= 0:
		return false
	payload = int(payload) + amount
	queue_redraw()
	return true

func _draw() -> void:
	if kind == "island_shard":
		draw_colored_polygon(PackedVector2Array([Vector2(0, -13), Vector2(11, 0), Vector2(0, 13), Vector2(-11, 0)]), Color("72e1a5"))
		draw_polyline(PackedVector2Array([Vector2(0, -13), Vector2(11, 0), Vector2(0, 13), Vector2(-11, 0), Vector2(0, -13)]), Color.WHITE, 2.0)
	elif kind == "stone":
		var shape := PackedVector2Array([Vector2(-10, 7), Vector2(-7, -7), Vector2(3, -11), Vector2(11, -2), Vector2(7, 10), Vector2(-10, 7)])
		draw_colored_polygon(shape, Color("91a7b5"))
		draw_polyline(shape, Color.WHITE, 2.0)
	else:
		var color := Color("f0c55b") if kind == "wood" else Color("b779ff")
		draw_circle(Vector2.ZERO, 9.0, color)
		draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 16, Color.WHITE, 2.0)
