extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(not world.try_open_workbench(), "workbench must reject interaction outside its range")
	world.player.global_position = world.workbench.global_position
	support.expect(world.try_open_workbench(), "nearby player must be able to open workbench")
	await scene_tree.process_frame
	support.expect(world.hud.is_workbench_panel_open(), "workbench interaction must open crafting panel")
	support.expect(world.hud.has_valid_action_focus() and scene_tree.root.get_viewport().gui_get_focus_owner() == world.hud.workbench_next_button, "unaffordable workbench must focus controller recipe browsing")
	world.wood = 3
	world.equipment_inventory.scrap = 2
	world.refresh_all_ui()
	var crafted := world.craft_reinforced_heart()
	support.expect(crafted, "affordable workbench recipe must succeed")
	support.expect(world.wood == 0 and world.equipment_inventory.scrap == 0, "craft must deduct authoritative resources")
	support.expect(world.player.maximum_health == 12 and world.player.health == 12, "crafted heart must visibly increase current and maximum health")
	support.expect(world.hud.get_crafting_feedback().contains("CRAFTED"), "successful craft must provide explicit feedback")
	support.expect(world.hud.is_tidecatcher_build_focused(), "craft completion must move controller focus to unlocked construction")
	support.expect(not world.craft_reinforced_heart(), "unique recipe must reject a duplicate attempt")
	support.expect(world.hud.get_crafting_feedback().contains("ALREADY"), "duplicate rejection must provide explicit feedback")
	world.stone = 2
	world.refresh_all_ui()
	support.expect(world.hud.workbench_next_button.get_node(world.hud.workbench_next_button.focus_neighbor_bottom) == world.hud.craft_button, "controller focus must link recipe selection to Craft")
	world.hud.workbench_next_button.pressed.emit()
	support.expect(world.hud.get_selected_recipe_id() == "runed_whetstone" and world.hud.get_recipe_cost_text().contains("2 / 2 STONE"), "controller Next must display the Whetstone and exact stone cost")
	world.hud.craft_button.pressed.emit()
	support.expect(world.runed_whetstone_crafted and world.stone == 0, "Whetstone action must deduct authoritative stone")
	support.expect(world.player.attack_damage == 2 and world.hud.get_displayed_attack_damage() == 2, "crafted Whetstone must visibly add one base attack")
	world.hud.craft_button.pressed.emit()
	support.expect(world.stone == 0 and world.hud.get_crafting_feedback().contains("ALREADY"), "duplicate Whetstone attempt must consume nothing and explain rejection")
	world.close_workbench_panel()
	support.expect(not world.hud.is_workbench_panel_open() and world.player.input_enabled, "closing workbench must restore gameplay input")
	world.queue_free()
	await scene_tree.process_frame
