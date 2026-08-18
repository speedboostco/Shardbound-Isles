class_name PresentationMotion
extends RefCounted

static func wave(elapsed: float, cycles_per_second: float, phase: float = 0.0) -> float:
	if cycles_per_second <= 0.0:
		return 0.0
	return sin((elapsed * cycles_per_second + phase) * TAU)

static func response_alpha(delta: float, responsiveness: float) -> float:
	if delta <= 0.0:
		return 1.0
	if responsiveness <= 0.0:
		return 0.0
	return clampf(1.0 - exp(-delta * responsiveness), 0.0, 1.0)
