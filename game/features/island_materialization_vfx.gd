class_name IslandMaterializationVfx
extends Node2D

const DURATION: float = 1.05
var lifetime: float = DURATION

func _ready() -> void:
	add_to_group("island_materialization_vfx")
	z_index = 79
	queue_redraw()

func _process(delta: float) -> void:
	lifetime = maxf(0.0, lifetime - delta)
	queue_redraw()
	if lifetime <= 0.0:
		queue_free()

func _draw() -> void:
	var progress := clampf(lifetime / DURATION, 0.0, 1.0)
	var reveal := 1.0 - progress
	var intensity := VfxSettings.from_project_settings().intensity
	var alpha := progress * intensity
	var reduced := VfxSettings.from_project_settings().reduced_effects
	var spread := 54.0 if reduced else 88.0
	var shard_count := 5 if reduced else 9
	for index: int in shard_count:
		var normalized := float(index) / float(maxi(1, shard_count - 1))
		var x := lerpf(-spread, spread, normalized)
		var height := 18.0 + float(posmod(index * 17, 31)) + reveal * 36.0
		var rise := reveal * (22.0 + float(posmod(index * 11, 19)))
		var center := Vector2(x, 16.0 - rise)
		var half_width := 3.0 + float(index % 2)
		var diamond := PackedVector2Array([
			center + Vector2(0, -height * 0.5), center + Vector2(half_width, 0),
			center + Vector2(0, height * 0.5), center + Vector2(-half_width, 0),
		])
		draw_colored_polygon(diamond, Color(0.35, 0.95, 0.75, alpha * (0.45 + normalized * 0.25)))
	if not reduced:
		var beam_width := lerpf(15.0, 3.0, reveal)
		draw_rect(Rect2(-beam_width * 0.5, -72.0, beam_width, 86.0), Color(0.56, 1.0, 0.84, alpha * 0.18))

func uses_circular_overlay() -> bool:
	return false
