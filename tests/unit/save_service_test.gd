extends RefCounted

const SaveScript := preload("res://src/domain/save_service.gd")

func run(support: TestSupport) -> void:
	var service: Variant = SaveScript.new()
	var state := _sample_state()
	var encoded: String = service.encode(state)
	var decoded: Dictionary = service.decode(encoded)
	support.expect(decoded.get("ok") == true, "valid save payload must decode")
	support.expect(decoded.get("schema_version") == 2, "save payload must declare schema version two")
	support.expect(decoded.get("state") == state, "save encode/decode must round trip scoped state")
	support.expect(service.decode("{broken").get("error") == "malformed_json", "malformed JSON must be rejected")
	support.expect(service.decode('{"schema_version":99,"state":{}}').get("error") == "unsupported_schema", "unsupported schema must be rejected")
	support.expect(service.decode('{"schema_version":1}').get("error") == "missing_state", "missing state must be rejected")
	var legacy_state := state.duplicate(true)
	legacy_state.erase("islands")
	var migrated: Dictionary = service.decode(JSON.stringify({"schema_version": 1, "state": legacy_state}))
	support.expect(migrated.get("ok") == true and migrated.get("migrated_from") == 1, "valid schema-one save must migrate explicitly")
	support.expect((migrated.get("state") as Dictionary).get("islands") == {"inventory": [], "installed": {}}, "schema-one migration must add empty island state")
	var invalid_modifier_state := state.duplicate(true)
	invalid_modifier_state["islands"] = {"inventory": [IslandShardGenerator.generate(9003)], "installed": IslandShardGenerator.generate(9003)}
	(invalid_modifier_state.islands.installed as Dictionary)["production_interval_multiplier"] = "fast"
	support.expect(service.decode(service.encode(invalid_modifier_state)).get("error") == "invalid_state", "schema-two shard extensions must reject malformed modifier types")
	var path := "user://save-service-unit.json"
	support.expect(service.save_to_path(path, state).get("ok") == true, "valid state must write to local save path")
	var disk_result: Dictionary = service.load_from_path(path)
	support.expect(disk_result.get("ok") == true and disk_result.get("state") == state, "disk save must round trip exactly")

func _sample_state() -> Dictionary:
	return {
		"player": {"health": 12, "maximum_health": 12, "position": {"x": 4.0, "y": -8.0}},
		"wood": 5,
		"equipment": {"scrap": 2, "equipped_id": "starter_ranged_424242", "items": [EquipmentGenerator.generate(424242)]},
		"reinforced_heart_crafted": true,
		"tidecatcher": {"built": true, "stored_wood": 4},
		"islands": {"inventory": [IslandShardGenerator.generate(9003)], "installed": IslandShardGenerator.generate(9003)},
	}
