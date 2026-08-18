extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(world.survival.rations == 0 and world.journey.entries().size() == 11, "new world initializes survival preparation and the full first-hour journey")
	support.expect(world.forage_node_count() == 4 and world.field_camp != null, "safe opening contains four survival forage nodes and one field camp")
	world._on_pickup_collected("fiber", 2)
	world._on_pickup_collected("emberberry", 2)
	support.expect(world.resource_inventory.amount("fiber") == 3 and world.resource_inventory.amount("emberberry") == 2, "fiber and emberberries plus the one-time forage reward use authoritative resource inventory")
	support.expect(int(world.journey.entry("forage_supplies").progress) == 4, "forage pickups advance combined journey progress")
	support.expect(world.craft_trail_ration() and world.survival.rations == 1, "gathered ingredients craft one Trail Ration")
	support.expect(world.resource_inventory.amount("fiber") == 1 and world.resource_inventory.amount("emberberry") == 1, "crafting and the one-time ration milestone reward leave exact survival resources")
	world.player.health = world.player.maximum_health - 4
	world.player.mana_pool.spend(24.0)
	var mana_before: float = world.player.mana_pool.current
	support.expect(world.rest_at_field_camp() and world.survival.rations == 0, "field camp consumes one ration through the authoritative survival state")
	support.expect(world.player.health == world.player.maximum_health and world.player.mana_pool.current > mana_before and world.survival.prepared_harvests == 6, "camp rest restores bounded vitals and grants prepared harvests")
	var yield_before: int = world.survival.prepared_harvests
	world._on_resource_depleted(Vector2.ZERO, "fiber", 1)
	support.expect(world.survival.prepared_harvests == yield_before - 1, "the next real resource depletion consumes one prepared harvest")
	var spawned_pickups := world.get_tree().get_nodes_in_group("world_pickups")
	var expected_fiber := 2 + int(world.expedition.effects(world.current_biome()).forage_yield_bonus)
	support.expect(spawned_pickups.any(func(node: Node) -> bool: return node is WorldPickup and (node as WorldPickup).kind == "fiber" and int((node as WorldPickup).payload) == expected_fiber), "prepared harvest and current weather create one resolved visible pickup")
	world.open_equipment_panel()
	await scene_tree.process_frame
	support.expect(world.hud.open_journey_button.visible and world.hud.open_journey_button.disabled == false, "inventory exposes a controller-focusable Journey entry point")
	world.hud.open_journey_button.pressed.emit()
	await scene_tree.process_frame
	support.expect(world.hud.is_journey_page_open() and world.hud.has_valid_action_focus(), "Journey page opens with valid controller focus")
	support.expect(world.hud.journey_details_label.text.contains("SHELTER MATERIALS") and world.hud.journey_details_label.text.contains("REWARD"), "journal presents objective, progress, and reward without hidden hover text")
	world.close_equipment_panel()
	var state := world.snapshot_state()
	support.expect(state.survival.rations == 0 and int(state.survival.prepared_harvests) == 5 and state.journey.completed is Array, "snapshot contains survival charges and stable journal progress")
	var encoded := world.save_service.encode(state)
	var decoded: Dictionary = world.save_service.decode(encoded)
	support.expect(bool(decoded.ok) and int(decoded.schema_version) == 11, "schema 11 validates story-aware survival/journey state")
	var replay := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(replay)
	await scene_tree.process_frame
	replay._apply_state(decoded.state as Dictionary)
	support.expect(replay.survival.to_dictionary() == world.survival.to_dictionary() and replay.journey.to_dictionary() == world.journey.to_dictionary(), "loaded world restores preparation and claimed milestone rewards without duplication")
	world.queue_free()
	replay.queue_free()
	await scene_tree.process_frame
