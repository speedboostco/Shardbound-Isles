class_name LegendaryPulseVisual
extends Node2D

const MAXIMUM_RADIUS: float = 115.0
const DURATION: float = 0.28

var remaining: float = DURATION

func _process(delta: float) -> void:
	remaining = maxf(0.0, remaining - delta)
	queue_redraw()
	if remaining <= 0.0:
		queue_free()

func _draw() -> void:
	var progress := 1.0 - remaining / DURATION
	var radius := lerpf(24.0, MAXIMUM_RADIUS, progress)
	var alpha := 1.0 - progress
	draw_circle(Vector2.ZERO, radius, Color(0.55, 0.32, 0.95, 0.08 * alpha))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(0.78, 0.58, 1.0, alpha), 6.0)
	draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 40, Color(0.45, 0.9, 1.0, alpha * 0.8), 3.0)

