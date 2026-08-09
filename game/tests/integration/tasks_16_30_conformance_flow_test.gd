extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world._set_combat_processing(false)
	var bow := LootGenerator.generate(26001, "conformance", 20, "bow", "rare")
	world._on_pickup_collected("equipment", bow)
	world.equip_selected_item(0)
	support.expect(world.hud.get_displayed_equipment_id() == String(bow.id), "equipment mutation event must refresh the observed HUD")

	var duplicate_pickup := world._spawn_pickup(world.player.global_position, "equipment", bow)
	support.expect(not duplicate_pickup.collect_immediately(), "a failed duplicate pickup must report rejection")
	await scene_tree.process_frame
	support.expect(is_instance_valid(duplicate_pickup) and not duplicate_pickup.is_queued_for_deletion() and world.equipment_inventory.items.size() == 1, "failed pickup must preserve the world item and owned instance exactly once")

	for candidate: Node in world.get_tree().get_nodes_in_group("attackable"):
		candidate.remove_from_group("attackable")
	var projectile_target := ChaserEnemy.new()
	projectile_target.hit_points = 50
	projectile_target.target = world.player
	world.add_child(projectile_target)
	projectile_target.set_physics_process(false)
	projectile_target.global_position = Vector2(180, 0)
	world.player.global_position = Vector2.ZERO
	var health_before := projectile_target.remaining_health
	world._on_attack_requested(Vector2.ZERO, Vector2.RIGHT)
	support.expect(world.get_tree().get_nodes_in_group("player_weapon_projectile").size() == 1 and projectile_target.remaining_health == health_before, "bow attack must create a traveling projectile before applying damage")
	await scene_tree.create_timer(0.5).timeout
	support.expect(projectile_target.remaining_health < health_before and world.get_tree().get_nodes_in_group("player_weapon_projectile").is_empty(), "bow projectile must resolve one hit and clean itself up")
	world._on_attack_requested(Vector2.ZERO, Vector2.RIGHT)
	var sword := LootGenerator.generate(26002, "conformance", 20, "sword", "rare")
	world._on_pickup_collected("equipment", sword)
	world.equip_selected_item(1)
	await scene_tree.process_frame
	support.expect(world.get_tree().get_nodes_in_group("player_weapon_projectile").is_empty(), "switching weapons must clean transient player projectiles")

	var spare := LootGenerator.generate(26003, "conformance", 20, "wand", "epic")
	spare["name"] = "An Exceptionally Long Emberglass Wand Name That Must Wrap Safely"
	world._on_pickup_collected("equipment", spare)
	world.open_equipment_panel()
	world.hud.select_equipment(2)
	await scene_tree.process_frame
	support.expect(world.hud.has_valid_action_focus() and world.hud.get_displayed_affix_text().contains("CANDIDATE"), "controller tooltip must open with focus and identify the candidate side")
	support.expect(world.hud.get_displayed_comparison_text().contains("EQUIPPED") and not world.hud.get_displayed_comparison_text().contains("ITEM SCORE"), "same-slot comparison must identify the equipped side without fake scoring")
	world.hud.scroll_equipment_details(1)
	support.expect(world.hud.equipment_tooltip_scroll.scroll_vertical > 0 and InputMap.action_get_events("islands").any(func(event: InputEvent) -> bool: return event is InputEventJoypadButton) and InputMap.action_get_events("rift").any(func(event: InputEvent) -> bool: return event is InputEventJoypadButton), "long tooltip details must scroll through documented controller shoulder actions")
	var size_before := world.equipment_inventory.items.size()
	var scrap_before := world.equipment_inventory.scrap
	world.hud.salvage_button.pressed.emit()
	support.expect(world.equipment_inventory.items.size() == size_before and world.hud.is_salvage_confirmation_armed(), "first controller salvage action must only arm destructive confirmation")
	world.hud.salvage_button.pressed.emit()
	support.expect(world.equipment_inventory.items.size() == size_before - 1 and world.equipment_inventory.scrap > scrap_before, "confirmed salvage must remove one item and grant material once")
	world.hud.select_equipment(0)
	world.hud.salvage_button.pressed.emit()
	world.hud.select_equipment(1)
	support.expect(not world.hud.is_salvage_confirmation_armed(), "changing selection must cancel pending destructive confirmation")

	duplicate_pickup.queue_free()
	world.queue_free()
	await scene_tree.process_frame
