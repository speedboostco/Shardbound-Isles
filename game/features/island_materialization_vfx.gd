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
	var frame_count := 4 if reduced else VisualAssetLibrary.vfx_frame_count()
	var frame := clampi(floori(reveal * float(frame_count)), 0, frame_count - 1)
	if reduced:
		frame = mini(frame * 2, VisualAssetLibrary.vfx_frame_count() - 1)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * 2.15)
	draw_texture(VisualAssetLibrary.vfx_texture("materialize", frame), Vector2(-32, -32), Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not reduced:
		draw_arc(Vector2.ZERO, 28.0 + reveal * 84.0, 0.0, TAU, 40, Color(0.35, 0.95, 0.75, alpha * 0.55), 4.0)
