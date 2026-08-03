class_name SaveService
extends RefCounted

const SCHEMA_VERSION: int = 2

func encode(state: Dictionary) -> String:
	return JSON.stringify({"schema_version": SCHEMA_VERSION, "state": state})

func decode(payload: String) -> Dictionary:
	var json := JSON.new()
	if json.parse(payload) != OK:
		return {"ok": false, "error": "malformed_json"}
	var root: Variant = json.data
	if not root is Dictionary:
		return {"ok": false, "error": "invalid_root"}
	var document := root as Dictionary
	if not document.has("schema_version"):
		return {"ok": false, "error": "missing_schema"}
	var version := int(document.get("schema_version", -1))
	if version not in [1, SCHEMA_VERSION]:
		return {"ok": false, "error": "unsupported_schema"}
	if not document.get("state") is Dictionary:
		return {"ok": false, "error": "missing_state"}
	var state := (document.get("state") as Dictionary).duplicate(true)
	if version == 1:
		state["islands"] = {"inventory": [], "installed": {}}
	if not _is_valid_state(state):
		return {"ok": false, "error": "invalid_state"}
	var result := {"ok": true, "schema_version": SCHEMA_VERSION, "state": _normalize_state(state)}
	if version == 1:
		result["migrated_from"] = 1
	return result

func save_to_path(path: String, state: Dictionary) -> Dictionary:
	if not _is_valid_state(state):
		return {"ok": false, "error": "invalid_state"}
	var absolute_path := ProjectSettings.globalize_path(path)
	var temporary_path := absolute_path + ".tmp"
	var backup_path := absolute_path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": "write_failed"}
	file.store_string(encode(state))
	file.flush()
	file.close()
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	if FileAccess.file_exists(absolute_path):
		var backup_error := DirAccess.rename_absolute(absolute_path, backup_path)
		if backup_error != OK:
			DirAccess.remove_absolute(temporary_path)
			return {"ok": false, "error": "backup_failed"}
	var replace_error := DirAccess.rename_absolute(temporary_path, absolute_path)
	if replace_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_path, absolute_path)
		return {"ok": false, "error": "replace_failed"}
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	return {"ok": true}

func load_from_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "error": "missing_file"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "read_failed"}
	return decode(file.get_as_text())

func _is_valid_state(state: Dictionary) -> bool:
	if not state.get("player") is Dictionary or not state.get("equipment") is Dictionary or not state.get("tidecatcher") is Dictionary or not state.get("islands") is Dictionary:
		return false
	var player := state.player as Dictionary
	var equipment := state.equipment as Dictionary
	var tidecatcher := state.tidecatcher as Dictionary
	var islands := state.islands as Dictionary
	if not player.get("position") is Dictionary or not equipment.get("items") is Array:
		return false
	if not islands.get("inventory") is Array or not islands.get("installed") is Dictionary:
		return false
	var position := player.position as Dictionary
	var required_values: Array[Variant] = [player.get("health"), player.get("maximum_health"), position.get("x"), position.get("y"), state.get("wood"), equipment.get("scrap"), tidecatcher.get("stored_wood")]
	for value: Variant in required_values:
		if not (value is int or value is float):
			return false
	if not equipment.get("equipped_id") is String or not state.get("reinforced_heart_crafted") is bool or not tidecatcher.get("built") is bool:
		return false
	for item_value: Variant in equipment.items:
		if not item_value is Dictionary:
			return false
		var item := item_value as Dictionary
		if not item.get("id") is String or not (item.get("seed") is int or item.get("seed") is float):
			return false
	for shard_value: Variant in islands.inventory:
		if not _is_valid_shard(shard_value):
			return false
	if not (islands.installed as Dictionary).is_empty() and not _is_valid_shard(islands.installed):
		return false
	return true

func _is_valid_shard(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var shard := value as Dictionary
	if not (shard.get("id") is String and shard.get("name") is String and shard.get("biome") is String and (shard.get("seed") is int or shard.get("seed") is float) and (shard.get("tree_yield_bonus") is int or shard.get("tree_yield_bonus") is float) and (shard.get("enemy_speed_multiplier") is int or shard.get("enemy_speed_multiplier") is float)):
		return false
	for key: String in ["player_attack_bonus", "production_interval_multiplier", "enemy_projectile_damage_bonus"]:
		if shard.has(key) and not (shard.get(key) is int or shard.get(key) is float):
			return false
	for key: String in ["reward_description", "risk_description"]:
		if shard.has(key) and not shard.get(key) is String:
			return false
	return true

func _normalize_state(state: Dictionary) -> Dictionary:
	var player := state.player as Dictionary
	var position := player.position as Dictionary
	var equipment := state.equipment as Dictionary
	var tidecatcher := state.tidecatcher as Dictionary
	var islands := state.islands as Dictionary
	var normalized_items: Array[Dictionary] = []
	for item_value: Variant in equipment.items:
		var item := (item_value as Dictionary).duplicate(true)
		item["seed"] = int(item.get("seed", 0))
		item["power"] = int(item.get("power", 0))
		normalized_items.append(item)
	var normalized_shards: Array[Dictionary] = []
	for shard_value: Variant in islands.inventory:
		normalized_shards.append(_normalize_shard(shard_value as Dictionary))
	var installed := islands.installed as Dictionary
	return {
		"player": {
			"health": int(player.health),
			"maximum_health": int(player.maximum_health),
			"position": {"x": float(position.x), "y": float(position.y)},
		},
		"wood": int(state.wood),
		"equipment": {
			"scrap": int(equipment.scrap),
			"equipped_id": String(equipment.equipped_id),
			"items": normalized_items,
		},
		"reinforced_heart_crafted": bool(state.reinforced_heart_crafted),
		"tidecatcher": {"built": bool(tidecatcher.built), "stored_wood": int(tidecatcher.stored_wood)},
		"islands": {"inventory": normalized_shards, "installed": {} if installed.is_empty() else _normalize_shard(installed)},
	}

func _normalize_shard(shard: Dictionary) -> Dictionary:
	var normalized := shard.duplicate(true)
	normalized["seed"] = int(shard.seed)
	normalized["tree_yield_bonus"] = int(shard.tree_yield_bonus)
	normalized["enemy_speed_multiplier"] = float(shard.enemy_speed_multiplier)
	if shard.has("player_attack_bonus"):
		normalized["player_attack_bonus"] = int(shard.player_attack_bonus)
	if shard.has("production_interval_multiplier"):
		normalized["production_interval_multiplier"] = float(shard.production_interval_multiplier)
	if shard.has("enemy_projectile_damage_bonus"):
		normalized["enemy_projectile_damage_bonus"] = int(shard.enemy_projectile_damage_bonus)
	return normalized
