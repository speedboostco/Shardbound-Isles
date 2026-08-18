class_name FacingRules
extends RefCounted

const DIRECTIONS: Array[String] = ["south", "south_west", "west", "north_west", "north", "north_east", "east", "south_east"]

static func resolve(direction: Vector2, previous: String = "east") -> String:
	var fallback := previous if previous in DIRECTIONS else "east"
	if direction.is_zero_approx():
		return fallback
	var octant := posmod(roundi(direction.angle() / (PI / 4.0)), 8)
	return ["east", "south_east", "south", "south_west", "west", "north_west", "north", "north_east"][octant]
