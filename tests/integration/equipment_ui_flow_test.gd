extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://src/gameplay/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var item := EquipmentGenerator.generate(424242)
	world._on_pickup_collected("equipment", item)
	support.expect(world.hud.get_inventory_item_count() == 1, "equipment collection must refresh the panel")
	world.open_equipment_panel()
	await scene_tree.process_frame
	support.expect(world.hud.is_equipment_panel_open(), "equipment action must open the panel")
	support.expect(world.hud.has_valid_action_focus(), "opened equipment panel must focus a controller action")
	world.equip_selected_item(0)
	support.expect(world.player.attack_damage == 6, "equipping fixed loot must update player damage")
	support.expect(world.hud.get_displayed_attack_damage() == 6, "HUD must visibly report changed attack damage")
	world._on_attack_requested(world.enemy.global_position + Vector2(50.0, 0.0), Vector2.LEFT)
	support.expect(world.enemy.remaining_health <= 0, "equipped attack power must change damage dealt")
	support.expect(world.salvage_selected_item(0) == 0, "world must protect currently equipped item")
	world.unequip_item()
	support.expect(world.salvage_selected_item(0) == 2, "world salvage action must grant deterministic scrap")
	support.expect(world.hud.get_inventory_item_count() == 0, "salvage must refresh the displayed inventory")
	support.expect(world.hud.get_displayed_scrap() == 2, "HUD must report salvage currency")
	world.close_equipment_panel()
	support.expect(not world.hud.is_equipment_panel_open(), "cancel action must close the equipment panel")
	world.queue_free()
	await scene_tree.process_frame
