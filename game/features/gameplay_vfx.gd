class_name GameplayVfx
extends Node2D

const DURATIONS: Dictionary = {
	"normal_hit": 0.24,
	"critical_hit": 0.38,
	"death": 0.44,
	"projectile_impact": 0.24,
	"gather_hit": 0.28,
	"resource_break": 0.42,
	"pickup": 0.32,
	"reward": 0.68,
}

var effect_kind: String = "normal_hit"
var lifetime: float = 0.24
var duration: float = 0.24
var settings := VfxSettings.new()

func configure(kind_value: String, settings_value: VfxSettings = null) -> void:
	effect_kind = kind_value if DURATIONS.has(kind_value) else "normal_hit"
	duration = float(DURATIONS[effect_kind])
	lifetime = duration
	if settings_value != null:
		settings = settings_value
	queue_redraw()

func _ready() -> void:
	add_to_group("gameplay_vfx")
	z_index = 80
	queue_redraw()

func _process(delta: float) -> void:
	lifetime = maxf(0.0, lifetime - delta)
	queue_redraw()
	if lifetime <= 0.0:
		queue_free()

func _draw() -> void:
	var progress := clampf(lifetime / maxf(duration, 0.001), 0.0, 1.0)
	var reveal := 1.0 - progress
	var alpha := progress * settings.intensity * (0.7 if settings.reduced_effects else 1.0)
	if effect_kind in ["normal_hit", "critical_hit", "projectile_impact"]:
		var scale_value := 0.65 if effect_kind == "normal_hit" else (0.9 if effect_kind == "critical_hit" else 0.5)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * scale_value)
		draw_texture(VisualAssetLibrary.texture("hit_burst"), Vector2(-32, -32), Color(1, 1, 1, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if effect_kind == "critical_hit" and settings.secondary_details_enabled():
			draw_arc(Vector2.ZERO, 22.0 + reveal * 18.0, 0.0, TAU, 24, Color(1.0, 0.78, 0.25, alpha), 4.0)
	elif effect_kind in ["gather_hit", "resource_break"]:
		var color := Color(0.55, 0.88, 0.48, alpha)
		var ray_count := 3 if settings.reduced_effects else 7
		for index: int in ray_count:
			var direction := Vector2.RIGHT.rotated(float(index) * TAU / float(ray_count))
			draw_line(direction * (8.0 + reveal * 7.0), direction * (18.0 + reveal * 24.0), color, 3.0)
		if effect_kind == "resource_break" and settings.secondary_details_enabled():
			draw_arc(Vector2.ZERO, 24.0 + reveal * 26.0, 0.0, TAU, 24, Color(0.91, 0.76, 0.39, alpha), 3.0)
	elif effect_kind in ["pickup", "reward"]:
		var radius := (14.0 if effect_kind == "pickup" else 30.0) + reveal * 18.0
		var color := Color(0.31, 0.86, 0.72, alpha) if effect_kind == "pickup" else Color(1.0, 0.71, 0.25, alpha)
		draw_arc(Vector2(0, -reveal * 18.0), radius, 0.0, TAU, 28, color, 4.0)
		draw_line(Vector2(0, 8), Vector2(0, -18 - reveal * 16.0), color, 4.0)
	elif effect_kind == "death":
		var fragments := 4 if settings.reduced_effects else 8
		for index: int in fragments:
			var direction := Vector2.RIGHT.rotated(float(index) * TAU / float(fragments) + 0.2)
			draw_line(direction * 14.0, direction * (30.0 + reveal * 28.0), Color(0.91, 0.40, 0.30, alpha), 4.0)
