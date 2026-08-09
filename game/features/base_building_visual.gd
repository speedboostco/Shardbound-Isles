class_name BaseBuildingVisual
extends Node2D

var building_id: String = "shared_storage"
var preview: bool = false
var placement_valid: bool = true
var facing_degrees: int = 0

func configure(id_value: String, preview_value: bool = false, valid_value: bool = true, rotation_value: int = 0) -> void:
	building_id = id_value
	preview = preview_value
	placement_valid = valid_value
	facing_degrees = posmod(rotation_value, 360)
	rotation_degrees = float(facing_degrees)
	queue_redraw()

func _draw() -> void:
	var tint := Color("59d98e") if placement_valid else Color("ef5c68")
	var alpha := 0.52 if preview else 1.0
	if building_id == "lumber_mill":
		draw_rect(Rect2(-42, -28, 84, 56), Color(0.32, 0.20, 0.11, alpha))
		draw_circle(Vector2(18, 0), 22.0, Color(0.77, 0.48, 0.20, alpha))
		for spoke: int in range(6):
			var direction := Vector2.RIGHT.rotated(float(spoke) * TAU / 6.0)
			draw_line(Vector2(18, 0), Vector2(18, 0) + direction * 20.0, Color(0.18, 0.12, 0.08, alpha), 3.0)
		draw_rect(Rect2(-34, -39, 45, 13), Color(0.69, 0.42, 0.18, alpha))
	elif building_id == "collector":
		draw_circle(Vector2.ZERO, 33.0, Color(0.12, 0.34, 0.38, alpha))
		draw_arc(Vector2.ZERO, 44.0, 0.0, TAU, 28, Color(0.35, 0.94, 0.76, alpha), 4.0)
		for angle: float in [0.0, PI * 0.5, PI, PI * 1.5]:
			draw_line(Vector2.ZERO, Vector2.RIGHT.rotated(angle) * 38.0, Color(0.62, 1.0, 0.87, alpha), 5.0)
	else:
		draw_rect(Rect2(-38, -30, 76, 60), Color(0.19, 0.32, 0.37, alpha))
		draw_rect(Rect2(-29, -20, 58, 40), Color(0.33, 0.55, 0.57, alpha))
	var outline := Color(tint.r, tint.g, tint.b, 0.95 if preview else 0.55)
	draw_arc(Vector2.ZERO, 51.0, 0.0, TAU, 32, outline, 4.0 if preview else 2.0)
	draw_colored_polygon(PackedVector2Array([Vector2(50, 0), Vector2(35, -8), Vector2(35, 8)]), outline)

