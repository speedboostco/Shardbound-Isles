class_name SaveService
extends RefCounted

const TechnologyTreeScript := preload("res://game/core/technology_tree.gd")

const SCHEMA_VERSION: int = 7
const DEFAULT_WORLD_SEED: int = 73000

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
	if version not in [1, 2, 3, 4, 5, 6, SCHEMA_VERSION]:
		return {"ok": false, "error": "unsupported_schema"}
	if not document.get("state") is Dictionary:
		return {"ok": false, "error": "missing_state"}
	var state := (document.get("state") as Dictionary).duplicate(true)
	if version == 1:
		state["islands"] = {"inventory": [], "installed": {}}
	if version <= 2:
		state["stone"] = 0
		state["runed_whetstone_crafted"] = false
	if version <= 3:
		var legacy_equipment := state.get("equipment", {}) as Dictionary
		var legacy_equipped_id := String(legacy_equipment.get("equipped_id", ""))
		legacy_equipment["equipped_slots"] = {} if legacy_equipped_id.is_empty() else {"weapon": legacy_equipped_id}
	if version <= 4:
		state["moonleaf"] = int(state.get("moonleaf", 0))
		state["herbal_compass_crafted"] = bool(state.get("herbal_compass_crafted", false))
		var legacy_islands := state.get("islands", {"inventory": [], "installed": {}}) as Dictionary
		var upgraded_inventory: Array[Dictionary] = []
		for shard_value: Variant in legacy_islands.get("inventory", []):
			if shard_value is Dictionary:
				upgraded_inventory.append(_upgrade_legacy_shard(shard_value as Dictionary))
		var archipelago := ArchipelagoModel.new(DEFAULT_WORLD_SEED)
		archipelago.initialize_default_slots()
		var legacy_installed := legacy_islands.get("installed", {}) as Dictionary
		if not legacy_installed.is_empty():
			var upgraded := _upgrade_legacy_shard(legacy_installed)
			archipelago.install("east", upgraded, IslandRuntimeState.create(upgraded))
		state["islands"] = {"inventory": upgraded_inventory, "installed": {} if legacy_installed.is_empty() else _upgrade_legacy_shard(legacy_installed), "archipelago": archipelago.to_dictionary()}
	if version <= 5:
		state["plank"] = 0
		state["base"] = _default_base_state()
	if version <= 6:
		state["technologies"] = {"learned": ["fieldcraft", "combat_training"]}
		var legacy_player := state.get("player", {}) as Dictionary
		legacy_player["mana"] = 60.0
		legacy_player["maximum_mana"] = 60.0
		legacy_player["mana_regeneration"] = 6.0
	if not _is_valid_state(state):
		return {"ok": false, "error": "invalid_state"}
	var result := {"ok": true, "schema_version": SCHEMA_VERSION, "state": _normalize_state(state)}
	if version < SCHEMA_VERSION:
		result["migrated_from"] = version
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
	if not state.get("player") is Dictionary or not state.get("equipment") is Dictionary or not state.get("tidecatcher") is Dictionary or not state.get("islands") is Dictionary or not state.get("base") is Dictionary or not state.get("technologies") is Dictionary:
		return false
	var player := state.player as Dictionary
	var equipment := state.equipment as Dictionary
	var tidecatcher := state.tidecatcher as Dictionary
	var islands := state.islands as Dictionary
	var base := state.base as Dictionary
	var technologies := state.technologies as Dictionary
	if not player.get("position") is Dictionary or not equipment.get("items") is Array:
		return false
	if not islands.get("inventory") is Array or not islands.get("installed") is Dictionary or not islands.get("archipelago") is Dictionary:
		return false
	var position := player.position as Dictionary
	var required_values: Array[Variant] = [player.get("health"), player.get("maximum_health"), player.get("mana"), player.get("maximum_mana"), player.get("mana_regeneration"), position.get("x"), position.get("y"), state.get("wood"), state.get("stone"), state.get("moonleaf"), state.get("plank"), equipment.get("scrap"), tidecatcher.get("stored_wood"), base.get("saved_unix")]
	for value: Variant in required_values:
		if not (value is int or value is float):
			return false
	if not equipment.get("equipped_id") is String or not equipment.get("equipped_slots") is Dictionary or not state.get("reinforced_heart_crafted") is bool or not state.get("runed_whetstone_crafted") is bool or not state.get("herbal_compass_crafted") is bool or not tidecatcher.get("built") is bool:
		return false
	if not technologies.get("learned") is Array or not TechnologyTreeScript.new().restore(technologies.learned as Array):
		return false
	if float(player.get("maximum_mana", 0.0)) <= 0.0 or float(player.get("mana", -1.0)) < 0.0 or float(player.get("mana", 0.0)) > float(player.get("maximum_mana", 0.0)) or float(player.get("mana_regeneration", -1.0)) < 0.0:
		return false
	for slot_value: Variant in (equipment.get("equipped_slots") as Dictionary):
		if String(slot_value) not in EquipmentInventory.SLOTS or not (equipment.get("equipped_slots") as Dictionary).get(slot_value) is String:
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
	if ArchipelagoModel.from_dictionary(islands.archipelago as Dictionary) == null:
		return false
	if BasePlacementModel.from_dictionary(base.get("placement", {}) as Dictionary) == null or SharedStorage.from_dictionary(base.get("storage", {}) as Dictionary) == null:
		return false
	var mill := LumberMillSimulation.new()
	var collector := CollectorSimulation.new()
	if not mill.restore(base.get("lumber_mill", {}) as Dictionary) or not collector.restore(base.get("collector", {}) as Dictionary) or not base.get("crafted_kits", {}) is Dictionary:
		return false
	return true

func _is_valid_shard(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	return IslandShardDefinition.validate_dictionary(value as Dictionary).is_empty()

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
		if item.has("damage"):
			item["damage"] = int(item.get("damage", item.get("power", 0)))
		if item.has("attack_speed"):
			item["attack_speed"] = float(item.get("attack_speed", 1.0))
		if item.has("item_level"):
			item["item_level"] = int(item.get("item_level", 1))
		if item.has("favorite"):
			item["favorite"] = bool(item.get("favorite", false))
		if item.has("upgrade_level"):
			item["upgrade_level"] = clampi(int(item.upgrade_level), 0, ItemUpgradeService.MAX_LEVEL)
		if item.has("unupgraded_power"):
			item["unupgraded_power"] = int(item.unupgraded_power)
		if item.get("base_stats") is Dictionary:
			var normalized_base_stats: Dictionary = {}
			for stat_id: String in (item.base_stats as Dictionary):
				normalized_base_stats[stat_id] = float((item.base_stats as Dictionary)[stat_id])
			item["base_stats"] = normalized_base_stats
		if item.get("affixes") is Array:
			var normalized_affixes: Array[Dictionary] = []
			for affix_value: Variant in item.affixes:
				if affix_value is Dictionary:
					var affix := (affix_value as Dictionary).duplicate(true)
					affix["value"] = float(affix.get("value", 0.0))
					normalized_affixes.append(affix)
			item["affixes"] = normalized_affixes
		normalized_items.append(item)
	var normalized_shards: Array[Dictionary] = []
	for shard_value: Variant in islands.inventory:
		normalized_shards.append(_normalize_shard(shard_value as Dictionary))
	var installed := islands.installed as Dictionary
	var base := state.base as Dictionary
	return {
		"player": {
			"health": int(player.health),
			"maximum_health": int(player.maximum_health),
			"mana": float(player.mana),
			"maximum_mana": float(player.maximum_mana),
			"mana_regeneration": float(player.mana_regeneration),
			"position": {"x": float(position.x), "y": float(position.y)},
		},
		"wood": int(state.wood),
		"stone": int(state.stone),
		"moonleaf": int(state.moonleaf),
		"plank": int(state.plank),
		"equipment": {
			"scrap": int(equipment.scrap),
			"equipped_id": String(equipment.equipped_id),
			"equipped_slots": (equipment.equipped_slots as Dictionary).duplicate(true),
			"items": normalized_items,
		},
		"reinforced_heart_crafted": bool(state.reinforced_heart_crafted),
		"runed_whetstone_crafted": bool(state.runed_whetstone_crafted),
		"herbal_compass_crafted": bool(state.herbal_compass_crafted),
		"tidecatcher": {"built": bool(tidecatcher.built), "stored_wood": int(tidecatcher.stored_wood)},
		"islands": {"inventory": normalized_shards, "installed": {} if installed.is_empty() else _normalize_shard(installed), "archipelago": (ArchipelagoModel.from_dictionary(islands.archipelago as Dictionary) as ArchipelagoModel).to_dictionary()},
		"base": {
			"placement": (BasePlacementModel.from_dictionary(base.placement as Dictionary) as BasePlacementModel).to_dictionary(),
			"storage": (SharedStorage.from_dictionary(base.storage as Dictionary) as SharedStorage).to_dictionary(),
			"lumber_mill": (base.lumber_mill as Dictionary).duplicate(true),
			"collector": (base.collector as Dictionary).duplicate(true),
			"crafted_kits": (base.crafted_kits as Dictionary).duplicate(true),
			"saved_unix": int(base.saved_unix),
		},
		"technologies": {"learned": (state.technologies.learned as Array).duplicate()},
	}

func _default_base_state() -> Dictionary:
	return {"placement": BasePlacementModel.new().to_dictionary(), "storage": SharedStorage.new().to_dictionary(), "lumber_mill": LumberMillSimulation.new().to_dictionary(), "collector": CollectorSimulation.new().to_dictionary(), "crafted_kits": {"lumber_mill_kit": false, "collector_kit": false}, "saved_unix": 0}

func _normalize_shard(shard: Dictionary) -> Dictionary:
	var normalized := shard.duplicate(true)
	normalized["seed"] = int(shard.seed)
	normalized["level"] = int(shard.level)
	if shard.has("tree_yield_bonus"):
		normalized["tree_yield_bonus"] = int(shard.tree_yield_bonus)
	if shard.has("enemy_speed_multiplier"):
		normalized["enemy_speed_multiplier"] = float(shard.enemy_speed_multiplier)
	if shard.has("player_attack_bonus"):
		normalized["player_attack_bonus"] = int(shard.player_attack_bonus)
	if shard.has("production_interval_multiplier"):
		normalized["production_interval_multiplier"] = float(shard.production_interval_multiplier)
	if shard.has("enemy_projectile_damage_bonus"):
		normalized["enemy_projectile_damage_bonus"] = int(shard.enemy_projectile_damage_bonus)
	return normalized

func _upgrade_legacy_shard(shard: Dictionary) -> Dictionary:
	if IslandShardDefinition.validate_dictionary(shard).is_empty():
		return shard.duplicate(true)
	return IslandShardGenerator.generate(int(shard.get("seed", FIRST_LEGACY_SEED())), int(shard.get("level", 1)))

func FIRST_LEGACY_SEED() -> int:
	return IslandShardGenerator.FIRST_DEFINITION_SEED
