extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var fog_day := 0
	for day: int in 64:
		world.expedition.elapsed_seconds = day * ExpeditionCycle.DAY_LENGTH_SECONDS + 60.0
		if world.expedition.weather(world.current_biome()) == "fog":
			fog_day = day
			break
	world._apply_expedition_effects()
	support.expect(world._weather_presentation.weather_kind() == "fog" and world._weather_presentation.visual_element_count() == 5 and world._weather_presentation.has_audio_layer() and world._weather_presentation.audio_profile() == "fog", "seeded fog configures bounded visual and ambient-audio presentation")

	world._on_resident_spoken("mira", "MIRA", "A route is ready.")
	support.expect(world.hud.is_contract_panel_open() and world.expedition_contract.status == "offered", "Mira opens an explicit offered-contract modal")
	support.expect(world.hud.has_valid_action_focus() and not world.player.input_enabled, "contract offer captures valid controller focus and suspends gameplay")
	var first_id := String(world.expedition_contract.definition.contract_id)
	support.expect(world.expedition_contract.definition.weather == "fog" and world.hud.contract_details_label.text.contains("wisp caches"), "offer explains the current weather objective before acceptance")
	world.hud.contract_close_button.pressed.emit()
	support.expect(world.expedition_contract.status == "none" and not world.hud.is_contract_panel_open(), "Not Now explicitly declines an unresolved offer")
	support.expect(world.player.input_enabled, "declining returns control without changing gameplay state")

	world._on_resident_spoken("mira", "MIRA", "A route is ready.")
	support.expect(String(world.expedition_contract.definition.contract_id) == first_id, "declined contract regenerates identically during the same day and weather")
	world.hud.contract_action_button.pressed.emit()
	support.expect(world.expedition_contract.status == "active" and not world.hud.is_contract_panel_open(), "focused Accept commits the offered contract and closes the modal")
	support.expect(world.active_expedition_event_count() == 3, "acceptance materializes three stable weather-event opportunities")
	support.expect(world.hud.contract_status_label.visible and world.hud.contract_status_label.text.contains("0/2"), "field HUD presents one concise active objective")
	support.expect(world.player.input_enabled, "acceptance restores player control")

	var first_event: Variant = world._expedition_events.values()[0]
	support.expect(String(first_event.interaction_label()).contains("WISP") and not bool(first_event.deals_contact_damage()), "fog event is readable, interactive, and cannot deal collision damage")
	world.player.global_position = first_event.global_position
	var first_event_id := String(first_event.stable_id)
	support.expect(bool(first_event.interact(world.player)), "player can activate the weather event through the shared interaction contract")
	support.expect(world.expedition_contract.progress == 1 and world.active_expedition_event_count() == 2, "first unique wisp advances exact progress and removes one event")
	var reward_count := world.get_tree().get_nodes_in_group("world_pickups").size()
	support.expect(world.get_tree().get_nodes_in_group("world_pickups").any(func(node: Node) -> bool: return node is WorldPickup and (node as WorldPickup).kind == "moonleaf"), "weather event creates a visible ordinary loot pickup")
	world._on_expedition_event_activated(first_event_id, "wisp_cache", "moonleaf", 1)
	support.expect(world.expedition_contract.progress == 1 and world.get_tree().get_nodes_in_group("world_pickups").size() == reward_count, "duplicate event callback grants neither progress nor loot")

	var second_event: Variant = world._expedition_events.values()[0]
	world.player.global_position = second_event.global_position
	support.expect(bool(second_event.interact(world.player)), "second stable weather event activates normally")
	support.expect(world.expedition_contract.status == "completed" and world.active_expedition_event_count() == 0, "target completion clears remaining contract-only events")
	support.expect(world.hud.contract_status_label.text.contains("RETURN TO MIRA"), "completion gives an unambiguous turn-in objective")

	world._on_resident_spoken("mira", "MIRA", "Well charted.")
	support.expect(world.hud.is_contract_panel_open() and world.hud.contract_action_button.text == "CLAIM LOOT", "Mira presents the completed reward before claim")
	world.hud.contract_action_button.pressed.emit()
	support.expect(world.expedition_contract.status == "claimed" and world.expedition_marks == 1, "claim grants exactly one persistent Expedition Mark")
	var pickups := world.get_tree().get_nodes_in_group("world_pickups")
	var equipment_pickup: WorldPickup
	var shard_pickup: WorldPickup
	for pickup_value: Node in pickups:
		if pickup_value is WorldPickup and (pickup_value as WorldPickup).kind == "equipment":
			equipment_pickup = pickup_value as WorldPickup
		elif pickup_value is WorldPickup and (pickup_value as WorldPickup).kind == "island_shard":
			shard_pickup = pickup_value as WorldPickup
	support.expect(is_instance_valid(equipment_pickup) and is_instance_valid(shard_pickup), "claim materializes rare gear and an island shard through the normal loot pipeline")
	support.expect(equipment_pickup.rarity == "rare" and String((equipment_pickup.payload as Dictionary).rarity) == "rare", "contract equipment has matching data and world rarity presentation")
	equipment_pickup.collect_immediately()
	shard_pickup.collect_immediately()
	support.expect(world.equipment_inventory.items.size() == 1 and world.island_shards.size() == 1, "collecting reward loot reaches equipment and shard inventories")
	support.expect(not world.claim_expedition_contract() and world.expedition_marks == 1, "claimed contract cannot duplicate currency or loot")
	world.open_equipment_panel()
	await scene_tree.process_frame
	support.expect(world.hud.stats_summary_label.text.contains("MARKS 1"), "inventory owns the numeric Expedition Mark display")
	world.close_equipment_panel()

	var snapshot: Dictionary = world.snapshot_state()
	var decoded: Dictionary = world.save_service.decode(world.save_service.encode(snapshot))
	support.expect(bool(decoded.ok) and int(decoded.schema_version) == 11, "schema eleven validates claimed contract, event IDs, currency, and loot inventory")
	var replay := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(replay)
	await scene_tree.process_frame
	replay._apply_state(decoded.state as Dictionary)
	support.expect(replay.expedition_marks == 1 and replay.expedition_contract.to_dictionary() == world.expedition_contract.to_dictionary(), "load restores exact contract and currency state")
	support.expect(replay.active_expedition_event_count() == 0 and replay.island_shards.size() == 1 and replay.equipment_inventory.items.size() == 1, "claimed save cannot respawn events or duplicate rewards")
	var legacy := snapshot.duplicate(true)
	legacy.erase("expedition_marks")
	legacy.erase("expedition_contract")
	var migrated: Dictionary = world.save_service.decode(JSON.stringify({"schema_version": 9, "state": legacy}))
	support.expect(bool(migrated.ok) and int(migrated.migrated_from) == 9 and int(migrated.state.expedition_marks) == 0 and String(migrated.state.expedition_contract.status) == "none" and String(migrated.state.island_story.status) == "locked", "schema-nine migration starts with safe empty contract and island-story progression")

	world.expedition.elapsed_seconds = (fog_day + 1) * ExpeditionCycle.DAY_LENGTH_SECONDS + 60.0
	world._apply_expedition_effects()
	world._on_resident_spoken("mira", "MIRA", "A new route is ready.")
	support.expect(String(world.expedition_contract.definition.contract_id) != first_id and int(world.expedition_contract.definition.day_index) == fog_day + 1, "claimed work rolls to a deterministic new-day contract")
	world._weather_presentation.configure("rain", 1)
	var rain_elements: int = world._weather_presentation.visual_element_count()
	world._weather_presentation.configure("gale", 1)
	var gale_elements: int = world._weather_presentation.visual_element_count()
	world._weather_presentation.configure("clear", 1)
	support.expect(rain_elements == 64 and gale_elements == 34 and world._weather_presentation.visual_element_count() == 16, "rain, gale, and clear each expose distinct bounded presentation density")
	world.queue_free()
	replay.queue_free()
	await scene_tree.process_frame
