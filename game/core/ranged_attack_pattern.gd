class_name RangedAttackPattern
extends RefCounted

const TELEGRAPH_SECONDS: float = 0.55
const COOLDOWN_SECONDS: float = 1.65
const ELITE_SPREAD_RADIANS: float = 0.22

static func angles(elite: bool) -> Array[float]:
	var result: Array[float] = []
	if elite:
		result.assign([-ELITE_SPREAD_RADIANS, 0.0, ELITE_SPREAD_RADIANS])
	else:
		result.assign([0.0])
	return result
