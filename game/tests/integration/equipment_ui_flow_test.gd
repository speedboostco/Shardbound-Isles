extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var item := EquipmentGenerator.generate(424242)
	var second := EquipmentGenerator.generate(424243)
	var legendary := BossReward.generate()
	world._on_pickup_collected("equipment", item)
	world._on_pickup_collected("equipment", second)
	world._on_pickup_collected("equipment", legendary)
	world.wood = 5
	world.stone = 3
	world.learn_technology("fieldcraft")
	world.learn_technology("combat_training")
	support.expect(world.hud.get_inventory_item_count() == 3, "all collected equipment must enter the browsable panel")
	world.open_equipment_panel()
	await scene_tree.process_frame
	support.expect(world.hud.is_equipment_panel_open(), "equipment action must open the panel")
	support.expect(world.hud.has_valid_action_focus(), "opened equipment panel must focus a controller action")
	support.expect(world.hud.equip_button.get_node(world.hud.equip_button.focus_neighbor_top) == world.hud.equipment_previous_button, "controller focus must navigate from Equip to item selection")
	support.expect(world.hud.get_selected_equipment_index() == 0 and world.hud.get_displayed_equipment_id() == item.id, "equipment panel must initially display the first item")
	world.hud.equipment_next_button.pressed.emit()
	support.expect(world.hud.get_selected_equipment_index() == 1 and world.hud.get_displayed_equipment_id() == second.id, "controller Next action must inspect the second item")
	world.hud.equip_button.pressed.emit()
	support.expect(world.equipment_inventory.equipped_id == second.id, "Equip action must target the displayed item")
	support.expect(world.player.attack_damage == 1 + int(second.power), "selected equipment must update player damage")
	support.expect(world.hud.get_displayed_attack_damage() == world.player.attack_damage, "HUD must visibly report actual changed attack damage")
	world.hud.equipment_next_button.pressed.emit()
	support.expect(world.hud.get_selected_equipment_index() == 2 and world.hud.get_displayed_equipment_id() == legendary.id and world.hud.get_displayed_affix_text().contains("RIFTWAKE") and world.hud.get_displayed_comparison_text().contains("SALVAGE VALUE  10"), "browsing must expose legendary identity, behavior, and authoritative salvage value")
	world.hud.salvage_button.pressed.emit()
	support.expect(world.hud.is_salvage_confirmation_armed() and world.hud.get_inventory_item_count() == 3, "first Salvage action must arm a destructive confirmation without mutating inventory")
	world.hud.salvage_button.pressed.emit()
	support.expect(world.hud.get_inventory_item_count() == 2 and world.hud.get_displayed_scrap() == 10, "Salvage action must remove the displayed legendary and grant its value")
	support.expect(world.hud.get_selected_equipment_index() == 1 and world.equipment_inventory.equipped_id == second.id, "selection must clamp to the equipped item after removing the last entry")
	world.hud.salvage_button.pressed.emit()
	support.expect(world.hud.get_inventory_item_count() == 2 and world.hud.get_displayed_scrap() == 10, "displayed equipped item must remain protected from salvage")
	world.hud.unequip_button.pressed.emit()
	support.expect(world.equipment_inventory.equipped_id.is_empty() and world.hud.has_valid_action_focus(), "Unequip must clear the slot and recover valid focus")
	world.hud.salvage_button.pressed.emit()
	world.hud.salvage_button.pressed.emit()
	support.expect(world.hud.get_inventory_item_count() == 1 and world.hud.get_displayed_scrap() == 12 and world.hud.get_selected_equipment_index() == 0, "salvage must clamp selection to the remaining item")
	world.hud.equip_button.pressed.emit()
	support.expect(world.equipment_inventory.equipped_id == item.id and world.player.attack_damage == 1 + int(item.power), "remaining item must equip from the clamped selection")
	world._on_attack_requested(world.enemy.global_position + Vector2(50.0, 0.0), Vector2.LEFT)
	await scene_tree.create_timer(0.4).timeout
	support.expect(not is_instance_valid(world.enemy) or world.enemy.remaining_health <= 0, "equipped attack power must change damage dealt")
	world.close_equipment_panel()
	support.expect(not world.hud.is_equipment_panel_open(), "cancel action must close the equipment panel")
	world.queue_free()
	await scene_tree.process_frame
