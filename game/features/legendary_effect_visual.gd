class_name LegendaryEffectVisual
extends Node2D

var effect_id: String = ""
var lifetime: float = 0.65

func _process(delta: float) -> void:
	lifetime -= delta
	queue_redraw()
	if lifetime <= 0.0:
		queue_free()

func _draw() -> void:
	var progress := clampf(lifetime / 0.65, 0.0, 1.0)
	var color := Color("ffc45c") if effect_id == "burning_smelter" else (Color("75e58d") if effect_id == "living_arrows" else Color("a888ff"))
	draw_arc(Vector2.ZERO, 28.0 + (1.0 - progress) * 55.0, 0.0, TAU, 32, Color(color, progress), 5.0)

