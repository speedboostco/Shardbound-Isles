class_name WeaponCastVisual
extends Node2D

var mode: String = "magic"
var direction: Vector2 = Vector2.RIGHT
var distance: float = 90.0
var lifetime: float = 0.34
var _elapsed: float = 0.0

func configure(mode_value: String, direction_value: Vector2, distance_value: float) -> void:
	mode = mode_value
	direction = direction_value.normalized() if not direction_value.is_zero_approx() else Vector2.RIGHT
	distance = maxf(30.0, minf(distance_value, 310.0))
	rotation = direction.angle()

func _ready() -> void:
	add_to_group("weapon_cast_visual")
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var progress := clampf(_elapsed / lifetime, 0.0, 1.0)
	var color := Color("bd8cff") if mode == "magic" else Color("9eeeff")
	var head := Vector2(distance * progress, 0)
	var trail := Vector2(maxf(0.0, distance * progress - 54.0), 0)
	draw_line(trail, head, Color(color, 1.0 - progress * 0.45), 4.0 if mode == "magic" else 2.0)
	for index: int in 3:
		var phase := fposmod(progress + float(index) * 0.22, 1.0)
		var point := Vector2(distance * phase, sin(phase * TAU + index) * 7.0)
		draw_colored_polygon(PackedVector2Array([point + Vector2(0, -4), point + Vector2(4, 0), point + Vector2(0, 4), point + Vector2(-4, 0)]), Color(color, 0.8 * (1.0 - progress)))
	if progress > 0.62:
		var end := Vector2(distance, 0)
		var pulse := 9.0 + 8.0 * (progress - 0.62) / 0.38
		draw_polyline(PackedVector2Array([end + Vector2(0, -pulse), end + Vector2(pulse, 0), end + Vector2(0, pulse), end + Vector2(-pulse, 0), end + Vector2(0, -pulse)]), Color(color, 1.0 - progress), 3.0)
