class_name LegendaryEffectVisual
extends Node2D

var effect_id: String = ""
var lifetime: float = 0.65
var settings := VfxSettings.from_project_settings()
var target_offsets: Array[Vector2] = []

func _ready() -> void:
	add_to_group("gameplay_vfx")
	z_index = 90

func _process(delta: float) -> void:
	lifetime -= delta
	queue_redraw()
	if lifetime <= 0.0:
		queue_free()

func _draw() -> void:
	var progress := clampf(lifetime / 0.65, 0.0, 1.0)
	var alpha := progress * settings.intensity * (0.7 if settings.reduced_effects else 1.0)
	var radius := 28.0 + (1.0 - progress) * 55.0
	if effect_id == "chain_mining":
		if target_offsets.is_empty():
			var points := PackedVector2Array([Vector2(-radius, 0), Vector2(-radius * 0.45, -18), Vector2(0, 12), Vector2(radius * 0.45, -18), Vector2(radius, 0)])
			draw_polyline(points, Color(0.66, 0.53, 1.0, alpha), 6.0)
		else:
			for target_offset: Vector2 in target_offsets:
				var midpoint := target_offset * 0.5 + target_offset.orthogonal().normalized() * 12.0
				draw_polyline(PackedVector2Array([Vector2.ZERO, midpoint, target_offset]), Color(0.66, 0.53, 1.0, alpha), 6.0)
				draw_circle(target_offset, 7.0, Color(0.91, 0.85, 1.0, alpha))
	elif effect_id == "burning_smelter":
		draw_colored_polygon(PackedVector2Array([Vector2(0, -radius), Vector2(radius * 0.5, 0), Vector2(0, radius), Vector2(-radius * 0.5, 0)]), Color(0.91, 0.40, 0.30, alpha * 0.55))
		draw_arc(Vector2.ZERO, radius, -PI * 0.9, -PI * 0.1, 18, Color(1.0, 0.72, 0.30, alpha), 6.0)
	elif effect_id == "living_arrows":
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * (0.9 + (1.0 - progress) * 0.45))
		draw_texture(VisualAssetLibrary.texture("legendary_plant"), Vector2(-32, -32), Color(1, 1, 1, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(0.66, 0.53, 1.0, alpha), 5.0)
	if settings.secondary_details_enabled():
		draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 24, Color(0.91, 0.85, 0.66, alpha * 0.7), 2.0)
