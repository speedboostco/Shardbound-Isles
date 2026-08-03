extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> Dictionary:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var forest := IslandShardGenerator.generate_for_biome(105001, "forest", 14)
	var swamp := IslandShardGenerator.generate_for_biome(105002, "swamp", 14)
	var volcano := IslandShardGenerator.generate_for_biome(105003, "volcano", 14)
	for shard: Dictionary in [forest, swamp, volcano]:
		world._on_pickup_collected("island_shard", shard)
	support.expect(world.island_shards.size() == 3, "M3 route must obtain three shard items")
	world.open_island_panel()
	var preview := world.hud.get_island_preview_text().to_upper()
	support.expect(preview.contains("FOREST") and preview.contains("MOONLEAF") and preview.contains("RISKS"), "M3 route must understand shard biome, value, and risk")
	support.expect(world.install_selected_shard(0, "east"), "M3 route must choose and install Forest")
	support.expect(world.island_slot.materialized.resource_ids().has("moonleaf") and world.island_slot.materialized.active_enemy_count() == 3, "Forest must physically expose unique resource and Predatory pressure")
	support.expect(world.install_selected_shard(0, "north_east"), "M3 route must place a neighboring Swamp")
	support.expect(world.archipelago.active_synergies()[0].id == "rare_spores", "Forest and Swamp must create meaningful Rare Spores adjacency")
	world.island_slot.materialized.resource_node("tree_0").receive_attack(99)
	await scene_tree.process_frame
	support.expect("tree_0" in (world.archipelago.slots.east.installed_island.runtime.destroyed_resources as Array), "M3 route must record destroyed island resource")
	var path := "user://m3-world-loot-simulation.json"
	var saved := world.save_game(path)
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	var loaded := restored.load_game(path)
	support.expect(saved and loaded and restored.island_slot.materialized.resource_node("tree_0") == null, "M3 save/load must preserve materialized runtime progress")
	support.expect(restored.install_selected_shard(0, "east"), "M3 route must replace Forest with Volcano")
	support.expect(restored.island_slot.materialized.resource_ids().count("wood") == 2, "neighboring Overgrown Swamp must spread resource growth to Volcano")
	var island := restored.island_slot.materialized
	var victim := island.get_node("ForestSlime") as ChaserEnemy
	victim.global_position = island.resource_node("stone_0").global_position + Vector2(8, 0)
	island.resource_node("stone_0").receive_attack(99)
	await scene_tree.process_frame
	support.expect(not is_instance_valid(victim) and restored.hud.get_encounter_feedback().contains("VOLATILE ORE"), "Volatile Ore must visibly explode and affect an enemy")
	restored.player.global_position = Vector2.ZERO
	support.expect(restored.remove_installed_shard("north_east") and restored.archipelago.active_synergies().is_empty(), "M3 route must remove an unoccupied neighbor and refresh adjacency")
	var metrics := {
		"world_seed": restored.archipelago.world_seed,
		"installed_slots": restored.archipelago.slot_ids().filter(func(slot_id: String) -> bool: return not restored.archipelago.slot(slot_id).installed_island.is_empty()).size(),
		"inventory_shards": restored.island_shards.size(),
		"destroyed_resources": 1,
		"synergies_created": 1,
		"volatile_triggered": true,
		"forest_unique_resource": "moonleaf",
	}
	world.queue_free()
	restored.queue_free()
	await scene_tree.process_frame
	return metrics
