class_name RiftRules
extends RefCounted

const TOTAL_WAVES: int = 3

static func wave(index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	match index:
		1:
			result.assign([
				{"kind": "chaser", "position": Vector2(-220, -120)},
				{"kind": "chaser", "position": Vector2(220, 120)},
			])
		2:
			result.assign([
				{"kind": "chaser", "position": Vector2(-250, 135)},
				{"kind": "ranged", "position": Vector2(240, -145)},
			])
		3:
			result.assign([
				{"kind": "ranged", "position": Vector2(-250, -150)},
				{"kind": "elite", "position": Vector2(250, 150)},
			])
	return result

static func reward(run_index: int) -> Dictionary:
	var safe_index := maxi(1, run_index)
	return {
		"item_id": "rift_cache_%d" % (8800 + safe_index),
		"id": "rift_cache_%d" % (8800 + safe_index),
		"definition_id": "rift_cache",
		"name": "Rift Cache %d" % safe_index,
		"base_type": "magic",
		"archetype": "magic",
		"rarity": "rare",
		"damage": 6 + mini(safe_index, 3),
		"power": 6 + mini(safe_index, 3),
		"attack_speed": 1.0,
		"seed": 8800 + safe_index,
	}
