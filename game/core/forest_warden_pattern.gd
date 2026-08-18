class_name ForestWardenPattern
extends RefCounted

const THORN_VOLLEY := "thorn_volley"
const ROOT_ERUPTION := "root_eruption"
const ROOT_RANGE := 250.0
const ROOT_HALF_WIDTH := 34.0
const ROOT_START_OFFSET := 24.0

static func phase_for_health(current_health: int, maximum_health: int) -> int:
	if maximum_health <= 0:
		return 2
	return 2 if current_health * 2 <= maximum_health else 1

static func attack_kind(encounter_seed: int, attack_index: int, phase: int) -> String:
	var phase_one: Array[String] = [THORN_VOLLEY, ROOT_ERUPTION, THORN_VOLLEY, THORN_VOLLEY]
	var phase_two: Array[String] = [ROOT_ERUPTION, THORN_VOLLEY, ROOT_ERUPTION, THORN_VOLLEY]
	var pattern := phase_two if phase >= 2 else phase_one
	var offset := posmod(encounter_seed, pattern.size())
	return pattern[posmod(maxi(attack_index, 0) + offset, pattern.size())]

static func telegraph_seconds(attack_id: String, phase: int) -> float:
	if attack_id == ROOT_ERUPTION:
		return 0.78 if phase >= 2 else 0.92
	return 0.48 if phase >= 2 else 0.58

static func cooldown_seconds(phase: int) -> float:
	return 0.78 if phase >= 2 else 1.22

static func thorn_angles(phase: int) -> Array[float]:
	var result: Array[float] = []
	var authored: Array = [-0.32, -0.16, 0.0, 0.16, 0.32] if phase >= 2 else [-0.18, 0.0, 0.18]
	for angle: Variant in authored:
		result.append(float(angle))
	return result

static func root_lane_contains(origin: Vector2, direction: Vector2, point: Vector2) -> bool:
	var forward := direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	var offset := point - origin
	var along := offset.dot(forward)
	var lateral := absf(offset.dot(forward.orthogonal()))
	return along >= ROOT_START_OFFSET and along <= ROOT_RANGE and lateral <= ROOT_HALF_WIDTH

static func root_lane_polygon(origin: Vector2, direction: Vector2) -> PackedVector2Array:
	var forward := direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	var side := forward.orthogonal() * ROOT_HALF_WIDTH
	var start := origin + forward * ROOT_START_OFFSET
	var finish := origin + forward * ROOT_RANGE
	return PackedVector2Array([start - side, finish - side, finish + side, start + side])
