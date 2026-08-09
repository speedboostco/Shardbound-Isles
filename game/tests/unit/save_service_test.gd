extends RefCounted

const SaveScript := preload("res://game/core/save_service.gd")

func run(support: TestSupport) -> void:
	var service: Variant = SaveScript.new()
	var state := _sample_state()
	var encoded: String = service.encode(state)
	var decoded: Dictionary = service.decode(encoded)
	support.expect(decoded.get("ok") == true, "valid save payload must decode")
	support.expect(decoded.get("schema_version") == 6, "save payload must declare schema version six")
	support.expect(decoded.state.player == state.player and decoded.state.equipment == state.equipment and decoded.state.islands.archipelago.slots.east.installed_island.definition.shard_id == state.islands.archipelago.slots.east.installed_island.definition.shard_id, "save encode/decode must round trip authoritative scoped state")
	support.expect(service.decode("{broken").get("error") == "malformed_json", "malformed JSON must be rejected")
	support.expect(service.decode('{"schema_version":99,"state":{}}').get("error") == "unsupported_schema", "unsupported schema must be rejected")
	support.expect(service.decode('{"schema_version":1}').get("error") == "missing_state", "missing state must be rejected")
	var legacy_state := state.duplicate(true)
	legacy_state.erase("islands")
	legacy_state.erase("stone")
	legacy_state.erase("runed_whetstone_crafted")
	var migrated: Dictionary = service.decode(JSON.stringify({"schema_version": 1, "state": legacy_state}))
	support.expect(migrated.get("ok") == true and migrated.get("migrated_from") == 1, "valid schema-one save must migrate explicitly")
	support.expect((migrated.state.islands.inventory as Array).is_empty() and (migrated.state.islands.installed as Dictionary).is_empty() and migrated.state.islands.archipelago is Dictionary and (migrated.get("state") as Dictionary).get("stone") == 0 and not bool((migrated.get("state") as Dictionary).get("runed_whetstone_crafted")), "schema-one migration must add archipelago and resource defaults")
	var schema_two_state := state.duplicate(true)
	schema_two_state.erase("stone")
	schema_two_state.erase("runed_whetstone_crafted")
	var migrated_two: Dictionary = service.decode(JSON.stringify({"schema_version": 2, "state": schema_two_state}))
	support.expect(migrated_two.get("ok") == true and migrated_two.get("migrated_from") == 2 and (migrated_two.state as Dictionary).stone == 0 and not bool((migrated_two.state as Dictionary).runed_whetstone_crafted), "schema-two save must migrate explicit stone-era defaults")
	var schema_three_state := state.duplicate(true)
	(schema_three_state.equipment as Dictionary).erase("equipped_slots")
	var migrated_three: Dictionary = service.decode(JSON.stringify({"schema_version": 3, "state": schema_three_state}))
	support.expect(migrated_three.get("ok") == true and migrated_three.get("migrated_from") == 3 and (migrated_three.state.equipment.equipped_slots as Dictionary).get("weapon") == "starter_ranged_424242", "schema-three save must migrate the legacy weapon ID into typed slots")
	var invalid_resource_state := state.duplicate(true)
	invalid_resource_state["stone"] = "two"
	support.expect(service.decode(service.encode(invalid_resource_state)).get("error") == "invalid_state", "schema five must reject malformed stone state")
	var invalid_modifier_state := state.duplicate(true)
	invalid_modifier_state["islands"] = {"inventory": [IslandShardGenerator.generate(9003)], "installed": IslandShardGenerator.generate(9003)}
	(invalid_modifier_state.islands.installed as Dictionary)["production_interval_multiplier"] = "fast"
	support.expect(service.decode(service.encode(invalid_modifier_state)).get("error") == "invalid_state", "schema-two shard extensions must reject malformed modifier types")
	var invalid_slots := state.duplicate(true)
	(invalid_slots.equipment as Dictionary)["equipped_slots"] = {"cape": "starter_ranged_424242"}
	support.expect(service.decode(service.encode(invalid_slots)).get("error") == "invalid_state", "schema five must reject unknown equipment slots")
	var schema_five_state := state.duplicate(true)
	schema_five_state.erase("plank")
	schema_five_state.erase("base")
	var migrated_five: Dictionary = service.decode(JSON.stringify({"schema_version": 5, "state": schema_five_state}))
	support.expect(migrated_five.get("ok") == true and migrated_five.get("migrated_from") == 5 and int(migrated_five.state.plank) == 0 and (migrated_five.state.base.placement.buildings as Dictionary).is_empty(), "schema-five saves must migrate to an empty committed base")
	var path := "user://save-service-unit.json"
	support.expect(service.save_to_path(path, state).get("ok") == true, "valid state must write to local save path")
	var disk_result: Dictionary = service.load_from_path(path)
	support.expect(disk_result.get("ok") == true and int(disk_result.state.moonleaf) == 3 and disk_result.state.islands.archipelago.slots.east.installed_island.definition.shard_id == "tempest_loom_9003", "disk save must round trip authoritative state")

func _sample_state() -> Dictionary:
	var archipelago := ArchipelagoModel.new(73000)
	archipelago.initialize_default_slots()
	var installed := IslandShardGenerator.generate(9003)
	archipelago.install("east", installed, IslandRuntimeState.create(installed))
	return {
		"player": {"health": 12, "maximum_health": 12, "position": {"x": 4.0, "y": -8.0}},
		"wood": 5,
		"stone": 2,
		"moonleaf": 3,
		"plank": 2,
		"equipment": {"scrap": 2, "equipped_id": "starter_ranged_424242", "equipped_slots": {"weapon": "starter_ranged_424242"}, "items": [EquipmentGenerator.generate(424242)]},
		"reinforced_heart_crafted": true,
		"runed_whetstone_crafted": true,
		"herbal_compass_crafted": true,
		"tidecatcher": {"built": true, "stored_wood": 4},
		"islands": {"inventory": [IslandShardGenerator.generate(9002)], "installed": installed, "archipelago": archipelago.to_dictionary()},
		"base": {"placement": BasePlacementModel.new().to_dictionary(), "storage": SharedStorage.new().to_dictionary(), "lumber_mill": LumberMillSimulation.new().to_dictionary(), "collector": CollectorSimulation.new().to_dictionary(), "crafted_kits": {"lumber_mill_kit": false, "collector_kit": false}, "saved_unix": 1000},
	}
