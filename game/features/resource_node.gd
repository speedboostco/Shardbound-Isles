class_name ResourceNode
extends StaticBody2D

signal depleted(position_value: Vector2, amount: int)

@export var hit_points: int = 2
@export var wood_yield: int = 3
var remaining_hits: int

func _ready() -> void:
	remaining_hits = hit_points
	add_to_group("attackable")
	queue_redraw()

func receive_attack(_damage: int) -> void:
	remaining_hits -= 1
	queue_redraw()
	if remaining_hits <= 0:
		depleted.emit(global_position, wood_yield)
		queue_free()

func _draw() -> void:
	var shake := 3.0 if remaining_hits < hit_points else 0.0
	draw_rect(Rect2(-8.0 + shake, -5.0, 16.0, 34.0), Color("845b3a"))
	draw_circle(Vector2(shake, -20.0), 29.0, Color("3a9d5d"))
	draw_arc(Vector2(shake, -20.0), 30.0, 0.0, TAU, 24, Color("173d25"), 3.0)

