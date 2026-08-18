extends RefCounted

const IslandStoryEventScript := preload("res://game/features/island_story_event.gd")
const IslandStoryWardenScript := preload("res://game/features/island_story_warden.gd")

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(StartingIslandTerrain.GROUND_TEXTURE.get_size() == Vector2(1792, 1152) and world.non_colliding_detail_count() == 128 and world.terrain_micro_biome_count() == 4, "starting island uses the authored 1792x1152 four-region terrain plate")
	support.expect(world.starting_island_terrain.has_shore_collision() and not world.uses_plus_terrain_markers(), "terrain owns an explicit shoreline collision and contains no plus markers")

	var forest := IslandShardGenerator.generate_for_biome(99117, "forest", 4)
	world.island_shards.append(forest)
	world._refresh_island_ui()
	world.player.global_position = Vector2.ZERO
	support.expect(world.install_selected_shard(0, "east"), "valid forest shard installs into the east slot")
	await scene_tree.process_frame
	support.expect(world.world_resident_count() == 3 and world.island_story.status == "offered", "installation materializes Tala and binds one offered island story")
	support.expect(is_instance_valid(world._island_story_resident) and world._island_story_resident.global_position.distance_to(world.island_slot.global_position) < 70.0, "Tala is physically grounded on the installed island")

	world._on_resident_spoken("tala", "TALA", "The shard remembers.")
	support.expect(world.hud.is_island_story_panel_open() and world.hud.island_story_action_a.text == "BEGIN SURVEY", "Tala opens an explicit story offer")
	support.expect(world.hud.has_valid_action_focus() and not world.player.input_enabled, "story offer traps controller focus and suspends gameplay")
	support.expect(world.hud.island_story_title_label.text.contains("VERDANT CRUCIBLE") and world.hud.island_story_reward_label.text.contains("RESTORE") and world.hud.island_story_reward_label.text.contains("PURGE"), "offer names the island and previews both distinct payoffs")
	world.hud.island_story_action_a.pressed.emit()
	support.expect(world.island_story.status == "active" and world.active_island_story_event_count() == 2, "acceptance materializes two stable biome survey events")
	support.expect(world.player.input_enabled and world.hud.island_story_status_label.text.contains("SURVEY"), "acceptance restores control and exposes one concise field objective")

	var first_event := world._island_story_events.values()[0] as IslandStoryEventScript
	support.expect(first_event.interaction_label().contains("GROVE ECHO") and not first_event.deals_contact_damage(), "forest survey site is readable, interactive, and non-damaging")
	world.player.global_position = first_event.global_position
	support.expect(first_event.interact(world.player) and world.island_story.progress == 1, "first unique survey interaction advances exact progress")
	await scene_tree.process_frame
	var second_event := world._island_story_events.values()[0] as IslandStoryEventScript
	world.player.global_position = second_event.global_position
	second_event.interact(world.player)
	await scene_tree.process_frame
	support.expect(world.island_story.stage == IslandStoryQuest.BRANCH_STAGE and world.island_story.branch.is_empty() and world.active_island_story_event_count() == 0, "survey completion pauses physical events for an explicit player choice")
	support.expect(world.hud.island_story_status_label.text.contains("CHOOSE RESTORATION OR PURGE"), "field objective directs the player back to Tala without hidden state")

	world.open_island_story()
	support.expect(world.hud.island_story_action_a.text == "RESTORE ISLAND" and world.hud.island_story_action_b.text == "PURGE CORRUPTION" and world.hud.has_valid_action_focus(), "branch panel exposes both controller-focusable choices")
	support.expect(world.hud.island_story_details_label.text.contains("stronger shard") and world.hud.island_story_details_label.text.contains("epic equipment"), "branch copy explains the lasting loot tradeoff before commitment")
	world.hud.island_story_action_a.pressed.emit()
	support.expect(world.island_story.branch == "restoration" and world.active_island_story_event_count() == 2, "restoration choice materializes two biome-specific restoration sites")
	var restoration_event := world._island_story_events.values()[0] as IslandStoryEventScript
	support.expect(restoration_event.interaction_label().contains("RESTORE ROOT BOND"), "forest restoration uses its authored Root Bond identity")
	world.player.global_position = restoration_event.global_position
	restoration_event.interact(world.player)
	await scene_tree.process_frame
	support.expect(world.island_story.progress == 1 and world.active_island_story_event_count() == 1, "first restoration site advances without duplicating the other site")
	var final_site := world._island_story_events.values()[0] as IslandStoryEventScript
	world.player.global_position = final_site.global_position
	final_site.interact(world.player)
	await scene_tree.process_frame
	support.expect(world.island_story.stage == IslandStoryQuest.WARDEN_STAGE and world.has_island_story_warden(), "second site awakens one special Warden enemy")
	var warden := world._island_story_warden as IslandStoryWardenScript
	support.expect(warden.display_name == "Verdant Warden" and warden.is_in_group("island_story_warden") and warden.elite, "special enemy has the correct biome identity and elite combat profile")
	warden.receive_attack(99)
	await scene_tree.process_frame
	support.expect(world.island_story.status == "completed" and not world.has_island_story_warden(), "Warden defeat completes the chain and cleans its combat actor")
	support.expect(world.hud.island_story_status_label.text.contains("RETURN TO TALA"), "completion exposes an unambiguous turn-in objective")

	world.open_island_story()
	world.hud.island_story_action_a.pressed.emit()
	await scene_tree.process_frame
	var shard_pickup := _find_pickup(world, "island_shard")
	support.expect(world.island_story.status == "claimed" and world.expedition_marks == 2 and is_instance_valid(shard_pickup), "restoration claim grants two Marks and a visible higher-level shard")
	shard_pickup.collect_immediately()
	support.expect(world.island_shards.size() == 1 and int(world.island_shards[0].level) == 5, "claimed story shard reaches the ordinary shard inventory at the promised level")

	world.open_island_story()
	support.expect(world.hud.island_story_details_label.text.contains("MARK EXCHANGE") and world.hud.island_story_action_a.visible and world.hud.island_story_action_b.visible and world.hud.island_story_action_c.visible, "claimed story opens a three-offer controller shop")
	world.hud.island_story_action_a.pressed.emit()
	await scene_tree.process_frame
	var equipment_pickup := _find_pickup(world, "equipment")
	support.expect(world.expedition_marks == 1 and world.island_story.offer_purchased("wayfinder_cache") and is_instance_valid(equipment_pickup), "Wayfinder Cache atomically spends one Mark and creates visible equipment loot")
	equipment_pickup.collect_immediately()
	support.expect(world.equipment_inventory.items.size() == 1 and String(world.equipment_inventory.items[0].rarity) == "rare", "exchange equipment reaches the ordinary inventory with rare rarity")
	var shard_count_before := world.island_shards.size()
	world.hud.island_story_action_b.pressed.emit()
	support.expect(world.expedition_marks == 1 and world.island_shards.size() == shard_count_before and not world.island_story.offer_purchased("focused_shard"), "insufficient Marks reject a focused-shard purchase without mutation")
	world.hud.island_story_action_c.pressed.emit()
	await scene_tree.process_frame
	var supplies := _find_pickup(world, "moonleaf")
	if is_instance_valid(supplies):
		supplies.collect_immediately()
	support.expect(world.expedition_marks == 0 and world.moonleaf == 3 and world.island_story.offer_purchased("field_supplies"), "field supplies spend the final Mark and enter the resource inventory")

	var snapshot := world.snapshot_state()
	var decoded: Dictionary = world.save_service.decode(world.save_service.encode(snapshot))
	support.expect(bool(decoded.ok) and int(decoded.schema_version) == 11, "schema eleven validates installed-island story, branch, shop, and currency state")
	var replay := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(replay)
	await scene_tree.process_frame
	replay._apply_state(decoded.state as Dictionary)
	support.expect(replay.island_story.to_dictionary() == world.island_story.to_dictionary() and replay.world_resident_count() == 3 and replay.active_island_story_event_count() == 0, "load restores claimed shop state and Tala without replaying story events")
	var schema_ten := snapshot.duplicate(true)
	schema_ten.erase("island_story")
	var migrated: Dictionary = world.save_service.decode(JSON.stringify({"schema_version": 10, "state": schema_ten}))
	support.expect(bool(migrated.ok) and int(migrated.migrated_from) == 10 and String(migrated.state.island_story.status) == "locked", "schema-ten migration adds a safe empty island story")
	replay.player.global_position = Vector2.ZERO
	support.expect(replay.remove_installed_shard("east") and replay.world_resident_count() == 2 and replay.active_island_story_event_count() == 0 and not replay.has_island_story_warden(), "removing the island clears Tala and all story scene entities without corrupting state")
	world.queue_free()
	replay.queue_free()
	await scene_tree.process_frame

func _find_pickup(world: FirstPlayableWorld, kind: String) -> WorldPickup:
	for node: Node in world.get_tree().get_nodes_in_group("world_pickups"):
		if node is WorldPickup and (node as WorldPickup).kind == kind and node.is_ancestor_of(world) == false:
			# Pickups are world descendants; avoid returning a pickup owned by a second test world.
			if world.is_ancestor_of(node):
				return node as WorldPickup
	return null
