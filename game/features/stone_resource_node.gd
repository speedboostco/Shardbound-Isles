class_name StoneResourceNode
extends StaticBody2D

signal depleted(position_value: Vector2, amount: int)

@export var hit_points: int = 3
@export var stone_yield: int = 2
var remaining_hits: int

func _ready() -> void:
	remaining_hits = hit_points
	add_to_group("attackable")
	queue_redraw()

func receive_attack(_damage: int) -> void:
	remaining_hits -= 1
	queue_redraw()
	if remaining_hits <= 0:
		depleted.emit(global_position, stone_yield)
		queue_free()

func damage_stage() -> int:
	return clampi(hit_points - remaining_hits, 0, hit_points)

func _draw() -> void:
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
