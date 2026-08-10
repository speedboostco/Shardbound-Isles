class_name VfxSettings
extends RefCounted

var reduced_effects: bool = false
var intensity: float = 1.0

func _init(reduced_value: bool = false, intensity_value: float = 1.0) -> void:
	reduced_effects = reduced_value
	intensity = clampf(intensity_value, 0.0, 1.0)

static func from_project_settings() -> VfxSettings:
	return VfxSettings.new(
		bool(ProjectSettings.get_setting("shardbound/visual/reduced_effects", false)),
		float(ProjectSettings.get_setting("shardbound/visual/effect_intensity", 1.0))
	)

func shake_scale() -> float:
	return intensity * (0.5 if reduced_effects else 1.0)

func secondary_details_enabled() -> bool:
	return not reduced_effects and intensity > 0.25

