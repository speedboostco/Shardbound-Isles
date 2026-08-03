class_name BossAttackPattern
extends RefCounted

const PHASE_ONE_TELEGRAPH: float = 0.7
const PHASE_TWO_TELEGRAPH: float = 0.4
const FOCUSED_SPREAD: float = 0.14

static func directions(phase: int, aim_direction: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []
	if phase <= 1:
		result.append(aim_direction.normalized().rotated(-FOCUSED_SPREAD))
		result.append(aim_direction.normalized().rotated(FOCUSED_SPREAD))
	else:
		for index: int in range(8):
			result.append(Vector2.RIGHT.rotated(TAU * float(index) / 8.0))
	return result

static func telegraph_seconds(phase: int) -> float:
	return PHASE_ONE_TELEGRAPH if phase <= 1 else PHASE_TWO_TELEGRAPH

