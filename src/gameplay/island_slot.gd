class_name IslandSlot
extends Node2D

var installed: bool = false
var shard_name: String = ""

func set_installed(value: bool, display_name: String = "") -> void:
	installed = value
	shard_name = display_name
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 67.0, Color("3d8c68") if installed else Color(0.2, 0.45, 0.5, 0.16))
	draw_arc(Vector2.ZERO, 69.0, 0.0, TAU, 40, Color("82e0a7") if installed else Color("5d999c"), 4.0)
	if installed:
		for offset: Vector2 in [Vector2(-24, -10), Vector2(5, -24), Vector2(27, 9), Vector2(-9, 25)]:
			draw_circle(offset, 11.0, Color("6ecb73"))
	else:
		draw_line(Vector2(-24, 0), Vector2(24, 0), Color("70aeb0"), 3.0)
		draw_line(Vector2(0, -24), Vector2(0, 24), Color("70aeb0"), 3.0)

