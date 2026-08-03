class_name WorldPickup
extends Area2D

signal collected(kind: String, payload: Variant)

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

func _draw() -> void:
	var color := Color("f0c55b") if kind == "wood" else Color("b779ff")
	draw_circle(Vector2.ZERO, 9.0, color)
	draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 16, Color.WHITE, 2.0)

