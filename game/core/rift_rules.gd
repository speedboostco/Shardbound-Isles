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
		"id": "rift_cache_%d" % (8800 + safe_index),
		"name": "Rift Cache %d" % safe_index,
		"archetype": "magic",
		"rarity": "rare",
		"power": 6 + mini(safe_index, 3),
		"seed": 8800 + safe_index,
	}
