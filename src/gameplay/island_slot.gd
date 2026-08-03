class_name IslandSlot
extends Node2D

var installed: bool = false
var shard_name: String = ""
var shard_biome: String = ""

func set_installed(value: bool, display_name: String = "", biome: String = "") -> void:
	installed = value
	shard_name = display_name
	shard_biome = biome
	queue_redraw()

func _draw() -> void:
	if not installed:
		draw_circle(Vector2.ZERO, 67.0, Color(0.2, 0.45, 0.5, 0.16))
		draw_arc(Vector2.ZERO, 69.0, 0.0, TAU, 40, Color("5d999c"), 4.0)
		draw_line(Vector2(-24, 0), Vector2(24, 0), Color("70aeb0"), 3.0)
		draw_line(Vector2(0, -24), Vector2(0, 24), Color("70aeb0"), 3.0)
		return
	match shard_biome:
		"ember":
			draw_circle(Vector2.ZERO, 67.0, Color("743532"))
			draw_arc(Vector2.ZERO, 69.0, 0.0, TAU, 40, Color("ff9b54"), 4.0)
			for offset: Vector2 in [Vector2(-26, 12), Vector2(0, -20), Vector2(27, 15)]:
				draw_colored_polygon(PackedVector2Array([offset + Vector2(0, -18), offset + Vector2(13, 14), offset + Vector2(-13, 14)]), Color("ff6b45"))
		"tempest":
			draw_circle(Vector2.ZERO, 67.0, Color("28587d"))
			draw_arc(Vector2.ZERO, 69.0, 0.0, TAU, 40, Color("83e5ff"), 4.0)
			for radius: float in [22.0, 39.0, 54.0]:
				draw_arc(Vector2.ZERO, radius, -PI * 0.85, PI * 0.35, 24, Color("78d9ff"), 5.0)
		_:
			draw_circle(Vector2.ZERO, 67.0, Color("3d8c68"))
			draw_arc(Vector2.ZERO, 69.0, 0.0, TAU, 40, Color("82e0a7"), 4.0)
			for offset: Vector2 in [Vector2(-24, -10), Vector2(5, -24), Vector2(27, 9), Vector2(-9, 25)]:
				draw_circle(offset, 11.0, Color("6ecb73"))
