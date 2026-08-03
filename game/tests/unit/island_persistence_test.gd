extends RefCounted

func run(support: TestSupport) -> void:
	var model := ArchipelagoModel.new(73003)
	model.initialize_default_slots()
	var forest := IslandShardGenerator.generate_for_biome(9401, "forest", 6)
	var runtime := IslandRuntimeState.create(forest)
	runtime.destroyed_resources.append("tree_0")
	runtime.collected_rewards.append("grove_shrine")
	runtime.encounter_completed = true
	model.install("east", forest, runtime)
	var state := _state(model.to_dictionary(), [IslandShardGenerator.generate(9402, 4)])
	var service := SaveService.new()
	var decoded := service.decode(service.encode(state))
	support.expect(SaveService.SCHEMA_VERSION == 5, "M3 saves must use schema version 5")
	support.expect(bool(decoded.ok), "schema-5 archipelago state must round trip")
	var restored_archipelago := decoded.state.islands.archipelago as Dictionary
	support.expect(int(restored_archipelago.world_seed) == 73003, "world seed must persist")
	var restored_island := (restored_archipelago.slots.east as Dictionary).installed_island as Dictionary
	support.expect(restored_island.runtime.destroyed_resources == ["tree_0"], "destroyed resources must persist")
	support.expect(restored_island.runtime.collected_rewards == ["grove_shrine"], "collected rewards must persist without duplication")
	support.expect(bool(restored_island.runtime.encounter_completed), "encounter completion must persist")
	support.expect(restored_island.definition.shard_id == forest.shard_id and int(restored_island.definition.seed) == int(forest.seed) and restored_island.definition.positive_modifiers == forest.positive_modifiers, "load must retain exact seed-generated definition identity and rolls")
	var regenerated := IslandShardGenerator.generate_for_biome(int(restored_island.definition.seed), String(restored_island.definition.biome), int(restored_island.definition.level))
	support.expect(regenerated.shard_id == forest.shard_id and regenerated.positive_modifiers == forest.positive_modifiers and regenerated.negative_modifiers == forest.negative_modifiers, "saved seed and level must regenerate identical island rolls")
	var unsupported := JSON.stringify({"schema_version": 999, "state": state})
	support.expect(service.decode(unsupported).error == "unsupported_schema", "unsupported save version must fail safely")
	var legacy := _state({}, [])
	legacy.islands = {"inventory": [forest], "installed": forest}
	var legacy_payload := JSON.stringify({"schema_version": 4, "state": legacy})
	var migrated := service.decode(legacy_payload)
	support.expect(bool(migrated.ok) and int(migrated.migrated_from) == 4, "schema-4 island save must migrate")
	support.expect(not (migrated.state.islands.archipelago.slots.east.installed_island as Dictionary).is_empty(), "legacy installed shard must migrate into east slot")
	support.expect(IslandRuntimeState.validate_dictionary(restored_island.runtime).is_empty(), "restored runtime island state must validate")

func _state(archipelago: Dictionary, inventory: Array[Dictionary]) -> Dictionary:
	return {
		"player": {"health": 10, "maximum_health": 10, "position": {"x": 0.0, "y": 0.0}},
		"wood": 0,
		"stone": 0,
		"moonleaf": 0,
		"equipment": {"scrap": 0, "equipped_id": "", "equipped_slots": {}, "items": []},
		"reinforced_heart_crafted": false,
		"runed_whetstone_crafted": false,
		"herbal_compass_crafted": false,
		"tidecatcher": {"built": false, "stored_wood": 0},
		"islands": {"inventory": inventory, "installed": {}, "archipelago": archipelago},
	}
