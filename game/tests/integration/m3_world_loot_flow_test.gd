extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(world.archipelago.slot_ids() == ["east", "north_east", "south_east"], "world must expose three stable model slots")
	support.expect(world.island_slots.size() == 3 and world.north_east_island_slot.position == Vector2(390, -250), "three physical slots must map to stable scene coordinates")
	var forest := IslandShardGenerator.generate_for_biome(9001, "forest", 12)
	var swamp := IslandShardGenerator.generate_for_biome(9004, "swamp", 12)
	var volcano := IslandShardGenerator.generate_for_biome(9002, "volcano", 12)
	world._on_pickup_collected("island_shard", forest)
	world._on_pickup_collected("island_shard", swamp)
	world._on_pickup_collected("island_shard", volcano)
	support.expect(world.island_shards.size() == 3, "collected shards must remain inventory items before installation")
	world.open_island_panel()
	await scene_tree.process_frame
	support.expect(world.hud.is_island_panel_open() and world.hud.has_valid_action_focus(), "controller preview must open with valid focus")
	var preview := world.hud.get_island_preview_text()
	support.expect(["BIOME", "LEVEL", "RESOURCES", "MOONLEAF", "ENEMIES", "POSITIVE", "RISKS", "ENCOUNTER", "EXPECTED REWARDS"].all(func(token: String) -> bool: return preview.to_upper().contains(token)), "preview must explain island content and risk before installation")
	support.expect((_node(world.hud, "IslandPanel/Margin/VBox/Close") as Button).text.contains("CANCEL"), "preview must expose a clear controller cancel action")
	support.expect(world.hud.select_island_slot("east") and world.hud.get_selected_island_slot_id() == "east", "controller UI must select a stable free world slot")
	support.expect(world.install_selected_shard(0, "east"), "valid Forest shard must install atomically")
	support.expect(world.island_shards.size() == 2, "successful install must consume exactly one shard")
	var forest_island := world.island_slot.materialized
	support.expect(is_instance_valid(forest_island) and world.island_slot.installed, "successful installation must physically materialize the island")
	var resource_ids := forest_island.resource_ids()
	support.expect(resource_ids.has("wood") and resource_ids.has("stone") and resource_ids.has("moonleaf"), "Forest island must contain tree, stone, and herbal resource")
	support.expect(forest_island.get_node_or_null("ForestSlime") != null and forest_island.get_node_or_null("ForestRanger") != null and not (forest_island.get_node("ForestSlime") as ChaserEnemy).is_physics_processing(), "Forest island must contain both enemies and pause them under controller preview")
	support.expect(is_instance_valid(forest_island.event_marker) and forest_island.event_marker.display_name.contains("Grove"), "Forest island must contain its small Grove event")
	support.expect(resource_ids.count("wood") == 2, "Dense Growth must physically add a resource node")
	support.expect(forest_island.active_enemy_count() == 3, "Predatory must physically add an elite enemy")
	var island_smelter := LootGenerator.generate(9050, "island_smelter", 20, "wand", "legendary")
	island_smelter.legendary_effects = ["burning_smelter"]
	island_smelter.legendary_affix_id = "burning_smelter"
	world._on_pickup_collected("equipment", island_smelter)
	world.equip_selected_item(0)
	var island_slime := forest_island.get_node("ForestSlime") as ChaserEnemy
	world._burning_targets[str(island_slime.get_instance_id())] = true
	island_slime.receive_attack(99)
	await scene_tree.process_frame
	support.expect(_has_pickup(world, "stone"), "a burning installed-island enemy death must reach the shared Smelter path and produce exactly one visible ore reward")
	world.island_shards.append({"id": "invalid"})
	var inventory_before_invalid := world.island_shards.size()
	support.expect(not world.install_selected_shard(inventory_before_invalid - 1, "north_east") and world.island_shards.size() == inventory_before_invalid, "invalid generation must preserve the shard inventory transaction")
	world.island_shards.remove_at(inventory_before_invalid - 1)
	world.north_east_island_slot.reject_next_materialization = true
	var inventory_before_failure := world.island_shards.size()
	support.expect(not world.install_selected_shard(0, "north_east") and world.island_shards.size() == inventory_before_failure, "materialization failure must not destroy a valid shard")
	support.expect(world.hud.select_island(0) and world.hud.select_island_slot("north_east"), "controller UI must select neighboring slot and Swamp shard")
	preview = world.hud.get_island_preview_text()
	support.expect(preview.contains("RARE SPORES") and preview.contains("PRICE"), "Forest + Swamp synergy must be visible with benefit and price before confirmation")
	support.expect(world.install_selected_shard(0, "north_east"), "Swamp shard must install next to Forest")
	support.expect(world.archipelago.active_synergies().size() == 1 and world.archipelago.active_synergies()[0].id == "rare_spores", "neighbor mutation must activate one bounded Rare Spores synergy")
	support.expect(world.north_east_island_slot.installed and is_instance_valid(world.north_east_island_slot.materialized), "neighbor installation must physically change the archipelago")
	var synergy := world.archipelago.active_synergies()[0] as Dictionary
	support.expect(not String(synergy.benefit).is_empty() and not String(synergy.price).is_empty(), "active adjacency must retain advantage and potential price")
	forest_island = world.island_slot.materialized
	var forest_tree := forest_island.resource_node("tree_0")
	forest_tree.receive_attack(99)
	await scene_tree.process_frame
	var east_runtime := world.archipelago.slots.east.installed_island.runtime as Dictionary
	support.expect("tree_0" in (east_runtime.destroyed_resources as Array), "destroyed island resource must enter runtime state")
	support.expect(forest_island.resource_node("tree_0") == null, "destroyed resource must leave materialized island")
	world.moonleaf = 3
	var pickup_radius_before := world.player.pickup_radius
	support.expect(world.craft_herbal_compass() and world.moonleaf == 0, "Forest Moonleaf must craft its concrete Herbal Compass upgrade")
	support.expect(is_equal_approx(world.player.pickup_radius, pickup_radius_before + 40.0), "Herbal Compass must apply its pickup-radius effect")
	world.player.global_position = forest_island.event_marker.global_position
	support.expect(forest_island.event_marker.interact(world.player), "player must be able to complete the Forest event")
	await scene_tree.process_frame
	support.expect(String(forest_island.event_marker.event_id) in (east_runtime.collected_rewards as Array) and bool(east_runtime.encounter_completed), "event reward must be recorded once in runtime state")
	support.expect(_has_pickup(world, "moonleaf"), "Forest event must create its explained Moonleaf reward")
	var path := "user://m3-world-loot-flow.json"
	support.expect(world.save_game(path), "schema-5 world with runtime islands must save")
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	support.expect(restored.load_game(path), "schema-5 archipelago must load")
	var restored_runtime := restored.archipelago.slots.east.installed_island.runtime as Dictionary
	support.expect("tree_0" in (restored_runtime.destroyed_resources as Array), "load must preserve destroyed resource IDs")
	support.expect(restored.island_slot.materialized.resource_node("tree_0") == null, "load must not respawn destroyed resources")
	support.expect(not (restored_runtime.collected_rewards as Array).is_empty() and restored.island_slot.materialized.event_marker.claimed, "load must not duplicate a collected encounter reward")
	restored.player.global_position = restored.north_east_island_slot.global_position
	support.expect(not restored.remove_installed_shard("north_east"), "island containing the player must reject removal")
	restored.player.global_position = Vector2.ZERO
	support.expect(restored.remove_installed_shard("north_east"), "unoccupied island must support warned removal")
	support.expect(restored.north_east_island_slot.materialized == null and restored.island_shards.any(func(shard: Dictionary) -> bool: return shard.shard_id == swamp.shard_id), "removal must clear entities/references and return shard inventory")
	restored.open_island_panel()
	restored.hud.select_island(0)
	restored.hud.select_island_slot("east")
	restored.hud.island_install_button.pressed.emit()
	support.expect(restored.hud.island_status_label.text.contains("WARNING"), "replacement must require an explicit consequence warning")
	var old_materialized := restored.island_slot.materialized
	restored.hud.island_install_button.pressed.emit()
	support.expect(restored.archipelago.slots.east.installed_island.definition.biome == "volcano" and restored.island_slot.materialized != old_materialized and old_materialized.get_parent() == null, "confirmed replacement must clean old entities and materialize selected island")
	world.queue_free()
	restored.queue_free()
	await scene_tree.process_frame

func _has_pickup(world: Node, kind: String) -> bool:
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == kind:
			return true
	return false

func _node(root: Node, path: String) -> Node:
	return root.get_node(path)
