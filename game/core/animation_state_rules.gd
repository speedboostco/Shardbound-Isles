class_name AnimationStateRules
extends RefCounted

const IDLE: String = "idle"
const MOVE: String = "move"
const ATTACK: String = "attack"
const HIT: String = "hit"
const DEATH: String = "death"
const STATES: Array[String] = [IDLE, MOVE, ATTACK, HIT, DEATH]

static func resolve(dead: bool, hit_active: bool, attack_active: bool, moving: bool) -> String:
	if dead:
		return DEATH
	if hit_active:
		return HIT
	if attack_active:
		return ATTACK
	return MOVE if moving else IDLE

static func frame_index(elapsed: float, frames_per_second: float, frame_count: int, loop: bool = true) -> int:
	if frame_count <= 1 or elapsed <= 0.0 or frames_per_second <= 0.0:
		return 0
	var index := floori(elapsed * frames_per_second)
	return posmod(index, frame_count) if loop else mini(index, frame_count - 1)

static func is_valid(state_name: String) -> bool:
	return state_name in STATES

static func loops(state_name: String) -> bool:
	return state_name in [IDLE, MOVE]
