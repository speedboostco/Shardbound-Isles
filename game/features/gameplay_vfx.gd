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
	var vfx_id := {
		"normal_hit": "hit", "critical_hit": "critical", "projectile_impact": "hit",
		"gather_hit": "gather", "resource_break": "gather", "death": "death",
		"pickup": "pickup", "reward": "legendary",
	}.get(effect_kind, "hit") as String
	var frame_count := 4 if settings.reduced_effects else VisualAssetLibrary.vfx_frame_count()
	var frame := clampi(floori(reveal * float(frame_count)), 0, frame_count - 1)
	if settings.reduced_effects:
		frame = mini(frame * 2, VisualAssetLibrary.vfx_frame_count() - 1)
	var scale_value := 0.72
	if effect_kind in ["critical_hit", "death", "reward"]:
		scale_value = 1.12
	elif effect_kind == "projectile_impact":
		scale_value = 0.58
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * scale_value)
	draw_texture(VisualAssetLibrary.vfx_texture(vfx_id, frame), Vector2(-32, -32), Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
