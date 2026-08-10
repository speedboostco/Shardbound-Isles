class_name FacingRules
extends RefCounted

const DIRECTIONS: Array[String] = ["south", "west", "east", "north"]

static func resolve(direction: Vector2, previous: String = "east") -> String:
	var fallback := previous if previous in DIRECTIONS else "east"
	if direction.is_zero_approx():
		return fallback
	var horizontal := absf(direction.x)
	var vertical := absf(direction.y)
	if is_equal_approx(horizontal, vertical):
		if fallback in ["west", "east"]:
			return "west" if direction.x < 0.0 else "east"
		return "north" if direction.y < 0.0 else "south"
	if horizontal > vertical:
		return "west" if direction.x < 0.0 else "east"
	return "north" if direction.y < 0.0 else "south"

