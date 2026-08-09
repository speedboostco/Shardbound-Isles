extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world.reinforced_heart_crafted = true
	world.wood = 10
	world.stone = 4
	world.refresh_all_ui()
	support.expect(world.craft_building_kit("lumber_mill_kit"), "unlocked lumber mill kit must craft and enter placement")
	support.expect(world.wood == 6 and world.stone == 2, "lumber mill recipe must deduct exact authoritative resources")
	support.expect(world.hud.is_placement_panel_open() and world.hud.has_valid_action_focus(), "placement must open with controller focus")
	support.expect(world.base_placement.preview is Dictionary and not world.snapshot_state().base.placement.has("preview"), "temporary placement preview must not enter save state")
	support.expect(world.rotate_building_preview() == 90, "placement rotation must be available through controller intent")
	world.player.global_position = FirstPlayableWorld.PLACEMENT_WORLD_POSITIONS.west
	world._refresh_placement_preview()
	support.expect(world.base_placement.validate_preview(BasePlacementModel.SOCKETS.west).reason == "player_overlap" and world.hud.placement_confirm_button.disabled, "player overlap must produce a visibly invalid preview")
	world.cycle_placement_socket(1)
	support.expect(not world.hud.placement_confirm_button.disabled and world.confirm_building_placement(), "free rotated socket must confirm placement")
	support.expect(world.has_base_building("lumber_mill") and not world.hud.is_placement_panel_open(), "committed lumber mill must materialize and close temporary placement")
	world.player.global_position = world.workbench.global_position
	world.try_open_workbench()
	world.hud.base_deposit_button.pressed.emit()
	support.expect(world.wood == 0 and world.shared_storage.amount("wood") == 6, "controller workbench action must deposit gathered wood into shared storage")
	world.close_workbench_panel()
	var production: Dictionary = world.advance_base_automation(9.0)
	support.expect(production.cycles == 3 and world.shared_storage.amount("plank") == 3, "lumber mill must batch-convert stored wood into planks")
	support.expect(world.hud.get_base_status().contains("STORAGE") and world.hud.get_base_status().contains("MILL"), "HUD must explain automation flow direction and state")
	world.player.global_position = world.workbench.global_position
	world.try_open_workbench()
	world.hud.base_withdraw_button.pressed.emit()
	support.expect(world.plank == 3 and world.shared_storage.amount("plank") == 0, "controller workbench action must safely collect processed output")
	world.close_workbench_panel()
	world.wood = 3
	world.plank = 1
	world.refresh_all_ui()
	support.expect(world.craft_building_kit("collector_kit"), "planks from the mill must enable the collector recipe")
	support.expect(world.confirm_building_placement() and world.has_base_building("collector"), "second building must share the same bounded placement model")
	var collector_position := world._building_position("collector")
	var ordinary := world._spawn_pickup(collector_position + Vector2(10, 0), "wood", 2)
	var rare := world._spawn_pickup(collector_position + Vector2(20, 0), "stone", 2)
	rare.rarity = "rare"
	var owned := world._spawn_pickup(collector_position + Vector2(30, 0), "moonleaf", 1)
	owned.owner_id = "player"
	var collection: Dictionary = world.collect_automation_batch()
	support.expect(collection.amount == 2 and (collection.collected_ids as Array).size() == 1, "collector must batch only ordinary world resources")
	support.expect(is_instance_valid(rare) and is_instance_valid(owned) and ordinary.is_queued_for_deletion(), "collector must leave rare and player-owned rewards untouched")
	world.advance_base_automation(0.5)
	support.expect(world.collector_simulation.total_stored() == 0, "collector output must flow into shared storage")
	world.lumber_mill_simulation.input_wood = 2
	world.lumber_mill_simulation.output_planks = LumberMillSimulation.OUTPUT_CAPACITY
	world.shared_storage.amounts.clear()
	world.shared_storage.add("stone", world.shared_storage.capacity)
	var input_before: int = world.lumber_mill_simulation.input_wood
	world.advance_base_automation(30.0)
	support.expect(world.lumber_mill_simulation.blocked_output and world.lumber_mill_simulation.input_wood == input_before, "full mill output must stop safely without consuming input")

	var item := EquipmentGenerator.generate(424242)
	world._on_pickup_collected("equipment", item)
	world.equip_selected_item(world.equipment.size() - 1)
	world.equipment_inventory.scrap = 2
	world._refresh_upgrade_ui()
	world.hud.upgrade_button.pressed.emit()
	support.expect(world.hud.is_upgrade_confirmation_armed() and int(world.equipment_inventory.equipped_item().get("upgrade_level", 0)) == 0, "first upgrade press must arm confirmation without changing the item")
	world.hud.upgrade_button.pressed.emit()
	var upgraded: Dictionary = world.equipment_inventory.equipped_item()
	support.expect(int(upgraded.upgrade_level) == 1 and int(upgraded.power) == int(item.power) + 1 and world.equipment_inventory.scrap == 0, "second confirmation must apply predictable upgrade and cost")
	support.expect(upgraded.get("affixes", []) == item.get("affixes", []) and upgraded.get("legendary_effects", []) == item.get("legendary_effects", []), "scene upgrade must preserve item affixes and behaviors")

	world.last_simulation_unix = 2000
	var rollback: Dictionary = world.simulate_offline(1900)
	support.expect(float(rollback.elapsed) == 0.0, "world catch-up must reject system-clock rollback")
	var path := "user://m4-base-flow.json"
	support.expect(world.save_game(path), "M4 world state must save")
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	support.expect(restored.load_game(path), "M4 world state must load")
	support.expect(restored.has_base_building("lumber_mill") and restored.has_base_building("collector"), "load must restore committed building placement")
	support.expect(restored.shared_storage.to_dictionary() == world.shared_storage.to_dictionary() and restored.lumber_mill_simulation.input_wood == world.lumber_mill_simulation.input_wood, "load must restore storage and production inventories")
	support.expect(int(restored.equipment_inventory.equipped_item().upgrade_level) == 1, "load must preserve item sharpening level")
	support.expect(restored.base_placement.preview.is_empty(), "load must never restore temporary preview nodes")
	world.queue_free()
	restored.queue_free()
	await scene_tree.process_frame
