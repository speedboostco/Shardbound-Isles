class_name SaveService
extends RefCounted

const SCHEMA_VERSION: int = 1

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
	if int(document.get("schema_version", -1)) != SCHEMA_VERSION:
		return {"ok": false, "error": "unsupported_schema"}
	if not document.get("state") is Dictionary:
		return {"ok": false, "error": "missing_state"}
	var state := document.get("state") as Dictionary
	if not _is_valid_state(state):
		return {"ok": false, "error": "invalid_state"}
	return {"ok": true, "schema_version": SCHEMA_VERSION, "state": _normalize_state(state)}

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
	if not state.get("player") is Dictionary or not state.get("equipment") is Dictionary or not state.get("tidecatcher") is Dictionary:
		return false
	var player := state.player as Dictionary
	var equipment := state.equipment as Dictionary
	var tidecatcher := state.tidecatcher as Dictionary
	if not player.get("position") is Dictionary or not equipment.get("items") is Array:
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
	return true

func _normalize_state(state: Dictionary) -> Dictionary:
	var player := state.player as Dictionary
	var position := player.position as Dictionary
	var equipment := state.equipment as Dictionary
	var tidecatcher := state.tidecatcher as Dictionary
	var normalized_items: Array[Dictionary] = []
	for item_value: Variant in equipment.items:
		var item := (item_value as Dictionary).duplicate(true)
		item["seed"] = int(item.get("seed", 0))
		item["power"] = int(item.get("power", 0))
		normalized_items.append(item)
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
	}
