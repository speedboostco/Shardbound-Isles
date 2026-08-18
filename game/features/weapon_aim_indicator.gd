class_name WeaponAimIndicator
extends Node2D

var weapon_type: String = "unarmed"
var aim_direction: Vector2 = Vector2.RIGHT
var attack_range: float = 78.0
var enabled: bool = true

func configure(type_value: String, direction_value: Vector2, range_value: float, enabled_value: bool = true) -> void:
	weapon_type = type_value
	aim_direction = direction_value.normalized() if not direction_value.is_zero_approx() else Vector2.RIGHT
	attack_range = maxf(24.0, range_value)
	enabled = enabled_value
	visible = enabled and weapon_type in ["bow", "ranged", "wand", "magic"]
	rotation = aim_direction.angle()
	queue_redraw()

func _draw() -> void:
	if not visible:
		return
	var is_magic := weapon_type in ["wand", "magic"]
	var color := Color("b88cff") if is_magic else Color("9eeeff")
	var length := minf(attack_range, 310.0)
	for offset: float in range(24, int(length), 28):
		draw_line(Vector2(offset, 0), Vector2(minf(offset + 13.0, length - 8.0), 0), Color(color, 0.48), 2.0)
	var end := Vector2(length, 0)
	var size := 13.0 if is_magic else 10.0
	draw_polyline(PackedVector2Array([end + Vector2(-size, -size), end + Vector2(0, -size * 0.45), end + Vector2(size, -size), end + Vector2(size * 0.45, 0), end + Vector2(size, size), end + Vector2(0, size * 0.45), end + Vector2(-size, size), end + Vector2(-size * 0.45, 0), end + Vector2(-size, -size)]), Color(color, 0.88), 2.5)
	if is_magic:
		draw_line(end + Vector2(-4, -17), end + Vector2(4, 17), Color(color, 0.55), 2.0)
		draw_line(end + Vector2(-17, 4), end + Vector2(17, -4), Color(color, 0.55), 2.0)
