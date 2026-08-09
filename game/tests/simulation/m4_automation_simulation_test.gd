extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> Dictionary:
	var first: Dictionary = await _run_route(scene_tree)
	var second: Dictionary = await _run_route(scene_tree)
	support.expect(first == second, "fixed M4 route must be exactly repeatable")
	support.expect(int(first.buildings) == 2, "M4 route must place two cooperating buildings")
	support.expect(int(first.manual_wood_spent) == 10, "M4 route must begin from manually gathered recipe and production input")
	support.expect(int(first.planks_produced) == 3, "M4 route must produce deterministic processed planks")
	support.expect(int(first.collector_batch) == CollectorSimulation.BATCH_LIMIT, "M4 collector route must respect its batch limit")
	support.expect(int(first.storage_total) <= SharedStorage.DEFAULT_CAPACITY, "M4 route must stay within storage capacity")
	support.expect(int(first.upgrade_level) == 1, "M4 route must complete one protected item upgrade")
	support.expect(int(first.upgrade_power_gain) == 1, "first sharpening level must add predictable bounded power")
	support.expect(bool(first.round_trip_valid), "M4 route state must pass schema-six round trip")
	support.expect(bool(first.preview_absent), "M4 route serialization must exclude placement preview")
	return first

func _run_route(scene_tree: SceneTree) -> Dictionary:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world.reinforced_heart_crafted = true
	world.wood = 14
	world.stone = 4
	world.craft_building_kit("lumber_mill_kit")
	world.confirm_building_placement()
	world.deposit_base_resource("wood", 6)
	world.advance_base_automation(9.0)
	var produced: int = world.shared_storage.amount("plank")
	world.withdraw_base_resource("plank", 1)
	world.craft_building_kit("collector_kit")
	world.cycle_placement_socket(1)
	world.confirm_building_placement()
	var collector_position: Vector2 = world._building_position("collector")
	for index: int in range(10):
		world._spawn_pickup(collector_position + Vector2.RIGHT.rotated(float(index) * TAU / 10.0) * 110.0, "stone", 1)
	var collection: Dictionary = world.collect_automation_batch()
	world.advance_base_automation(0.5)
	var item: Dictionary = EquipmentGenerator.generate(424242)
	world._on_pickup_collected("equipment", item)
	world.equip_selected_item(world.equipment.size() - 1)
	world.equipment_inventory.scrap = 2
	world.upgrade_equipped_item(true)
	var state: Dictionary = world.snapshot_state()
	var decoded: Dictionary = SaveService.new().decode(SaveService.new().encode(state))
	var result: Dictionary = {
		"buildings": world.base_placement.buildings.size(),
		"manual_wood_spent": 10,
		"planks_produced": produced,
		"collector_batch": (collection.collected_ids as Array).size(),
		"storage_total": world.shared_storage.total(),
		"upgrade_level": int(world.equipment_inventory.equipped_item().upgrade_level),
		"upgrade_power_gain": int(world.equipment_inventory.equipped_item().power) - int(item.power),
		"round_trip_valid": bool(decoded.get("ok", false)),
		"preview_absent": not (state.base.placement as Dictionary).has("preview"),
	}
	world.queue_free()
	await scene_tree.process_frame
	return result
