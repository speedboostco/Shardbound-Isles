class_name MovementRules
extends RefCounted

static func velocity(input_vector: Vector2, speed: float) -> Vector2:
	return input_vector.limit_length(1.0) * maxf(0.0, speed)

static func displacement(input_vector: Vector2, speed: float, delta: float) -> Vector2:
	return velocity(input_vector, speed) * maxf(0.0, delta)
