class_name ContactShadow
extends RefCounted

const COLOR_RGB := Color(0.025, 0.055, 0.06, 1.0)
const PROFILES: Dictionary = {
	"player": {"foot_y": 23.0, "radius": 15.0, "scale_y": 0.18, "opacity": 0.22},
	"enemy": {"foot_y": 19.0, "radius": 15.0, "scale_y": 0.19, "opacity": 0.21},
	"ranged_enemy": {"foot_y": 20.0, "radius": 15.0, "scale_y": 0.19, "opacity": 0.21},
	"resident": {"foot_y": 17.0, "radius": 12.0, "scale_y": 0.18, "opacity": 0.19},
	"resource": {"foot_y": 25.0, "radius": 22.0, "scale_y": 0.17, "opacity": 0.2},
	"obstacle": {"foot_y": 15.0, "radius": 16.0, "scale_y": 0.17, "opacity": 0.18},
	"living_prop": {"foot_y": 23.0, "radius": 20.0, "scale_y": 0.17, "opacity": 0.18},
	"summon": {"foot_y": 19.0, "radius": 14.0, "scale_y": 0.18, "opacity": 0.2},
}

static func profile(profile_id: String) -> Dictionary:
	return (PROFILES.get(profile_id, PROFILES.player) as Dictionary).duplicate(true)

static func paint(canvas: CanvasItem, profile_id: String, radius_override: float = 0.0, foot_y_override: float = -1.0) -> void:
	var value := profile(profile_id)
	var foot_y := foot_y_override if foot_y_override >= 0.0 else float(value.foot_y)
	var radius := radius_override if radius_override > 0.0 else float(value.radius)
	canvas.draw_set_transform(Vector2(0.0, foot_y), 0.0, Vector2(1.0, float(value.scale_y)))
	canvas.draw_circle(Vector2.ZERO, radius, Color(COLOR_RGB, float(value.opacity)))
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func validate_profiles() -> Array[String]:
	var errors: Array[String] = []
	for profile_id: String in PROFILES:
		var value := PROFILES[profile_id] as Dictionary
		if float(value.get("foot_y", 0.0)) <= 0.0:
			errors.append("contact shadow must sit below the actor origin: %s" % profile_id)
		if float(value.get("radius", 0.0)) < 8.0 or float(value.get("radius", 0.0)) > 28.0:
			errors.append("contact shadow radius is outside presentation bounds: %s" % profile_id)
		if float(value.get("scale_y", 0.0)) < 0.12 or float(value.get("scale_y", 0.0)) > 0.22:
			errors.append("contact shadow must remain a narrow ellipse: %s" % profile_id)
		if float(value.get("opacity", 0.0)) < 0.12 or float(value.get("opacity", 0.0)) > 0.24:
			errors.append("contact shadow opacity is outside presentation bounds: %s" % profile_id)
	return errors
