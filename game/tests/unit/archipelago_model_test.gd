extends RefCounted

func run(support: TestSupport) -> void:
	var model := ArchipelagoModel.new(73001)
	model.initialize_default_slots()
	var repeated := ArchipelagoModel.new(73001)
	repeated.initialize_default_slots()
	support.expect(model.world_seed == 73001, "archipelago must retain its explicit world seed")
	support.expect(model.slot_ids() == ["east", "north_east", "south_east"], "M3 slots must have stable authored IDs")
	support.expect(model.slot("east").coordinate == {"q": 1, "r": 0}, "east slot must expose a stable axial coordinate")
	support.expect(model.to_dictionary() == repeated.to_dictionary(), "same world seed and authored slots must produce identical data")
	support.expect(model.neighbor_ids("east") == ["north_east", "south_east"], "hex neighbors must be deterministic and sorted")
	support.expect(model.neighbor_ids("north_east") == ["east", "south_east"], "neighbor relationship must be symmetric")
	support.expect(not _contains_node(model.to_dictionary()), "archipelago data must not serialize Node references")
	var forest := IslandShardGenerator.generate_for_biome(9101, "forest", 8)
	var swamp := IslandShardGenerator.generate_for_biome(9102, "swamp", 8)
	var forest_runtime := IslandRuntimeState.create(forest)
	support.expect(model.install("east", forest, forest_runtime), "valid shard must install into a free slot")
	support.expect(not model.slot("east").installed_island.is_empty(), "installed island must be authoritative model data")
	support.expect(model.install("north_east", swamp, IslandRuntimeState.create(swamp)), "second neighboring island must install")
	support.expect(model.revision == 2, "install mutations must increment revision once each")
	var encoded := JSON.stringify(model.to_dictionary())
	var restored := ArchipelagoModel.from_dictionary(JSON.parse_string(encoded) as Dictionary)
	support.expect(restored != null, "serialized archipelago must restore")
	support.expect(restored.world_seed == model.world_seed and restored.slot("east").installed_island.definition.shard_id == forest.shard_id, "archipelago JSON round trip must preserve authoritative identity")
	support.expect(restored.active_synergies().size() == 1, "neighbor pair must create one bounded synergy")
	var removed := model.remove("north_east")
	support.expect(not removed.is_empty() and model.slot("north_east").installed_island.is_empty(), "remove must return and clear installed data")
	support.expect(model.active_synergies().is_empty(), "removing neighbor must refresh affected synergies")
	var volcano := IslandShardGenerator.generate_for_biome(9103, "volcano", 9)
	support.expect(model.install("east", volcano, IslandRuntimeState.create(volcano)), "occupied slot must support atomic replacement")
	support.expect(model.slot("east").installed_island.definition.biome == "volcano", "replacement must update installed definition")
	support.expect(model.revision == 4, "remove and replacement must each trigger one revision")
	support.expect(model.install("missing", forest, forest_runtime) == false, "unknown slot must reject installation")

func _contains_node(value: Variant) -> bool:
	if value is Node:
		return true
	if value is Dictionary:
		for child: Variant in (value as Dictionary).values():
			if _contains_node(child):
				return true
	if value is Array:
		for child: Variant in value:
			if _contains_node(child):
				return true
	return false
