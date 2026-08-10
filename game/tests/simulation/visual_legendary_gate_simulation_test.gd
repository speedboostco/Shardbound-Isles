extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> Dictionary:
	var domain_first := _legendary_scenario()
	var domain_repeat := _legendary_scenario()
	support.expect(domain_first == domain_repeat, "Tasks 31-45 legendary gate must repeat exactly for fixed seed 314159")
	support.expect(int(domain_first.chain_targets) == 4 and bool(domain_first.chain_unique), "Chain Mining gate must select four unique bounded targets")
	support.expect(int(domain_first.smelting_charges) == 1, "Burning Smelter gate must create one reward for repeated eligible death callbacks")
	support.expect(int(domain_first.living_plants) > 0 and int(domain_first.living_plants) <= 3, "Living Arrows gate must create a bounded deterministic summon set")
	support.expect(int(domain_first.maximum_connections) <= 1, "two hundred equipment syncs must never duplicate a legendary callback")
	support.expect((domain_first.triggered_effects as Array) == ["chain_mining", "burning_smelter", "living_arrows"], "fixed legendary route must expose all three behavior-changing effects")

	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var scripted_controller_navigation_failures := 0
	var smoke := world.run_scripted_smoke()
	support.expect(int(smoke.wood) == 3 and int(smoke.stone) == 2 and int(smoke.items_collected) == 1, "fixed gate route must complete gather, combat and first loot")
	support.expect(world.player.get_node_or_null("EmberwoodSprite") != null and world.tree.get_node_or_null("EmberwoodSprite") != null, "no prominent player/resource geometry placeholder may remain in the core route")
	var equipment_event := InputEventAction.new()
	equipment_event.action = "equipment"
	equipment_event.pressed = true
	world.hud._unhandled_input(equipment_event)
	await scene_tree.process_frame
	var equipment_opened_with_focus := world.hud.is_equipment_panel_open() and world.hud.get_viewport().gui_get_focus_owner() is Button
	if not equipment_opened_with_focus:
		scripted_controller_navigation_failures += 1
	support.expect(equipment_opened_with_focus, "fixed route equipment comparison must be controller accessible")
	support.expect(not world.hud.comparison_label.text.is_empty() and not world.hud.affix_label.text.is_empty(), "fixed route must present a readable loot comparison before the decision")
	var spare := LootGenerator.generate(45045, "visual_gate", 12, "sword", "rare")
	world._on_pickup_collected("equipment", spare)
	world.hud.refresh_equipment(world.equipment_inventory.items, world.equipment_inventory.equipped_item("weapon"), world.equipment_inventory.scrap, world.player.attack_damage, world.player.attack_speed, world.equipment_inventory.equipped_slots)
	world.hud.select_equipment(world.equipment_inventory.items.size() - 1)
	var items_before := world.equipment_inventory.items.size()
	var scrap_before := world.equipment_inventory.scrap
	world.hud.salvage_button.pressed.emit()
	var salvage_armed := world.hud.is_salvage_confirmation_armed() and "DESTROY" in world.hud.salvage_button.text
	if not salvage_armed:
		scripted_controller_navigation_failures += 1
	support.expect(salvage_armed, "controller salvage must require an explicit destructive confirmation")
	world.hud.salvage_button.pressed.emit()
	support.expect(world.equipment_inventory.items.size() == items_before - 1 and world.equipment_inventory.scrap > scrap_before, "confirmed salvage must atomically exchange exactly one item for scrap")
	world.hud.close_equipment_panel()

	for index: int in 5:
		var extra := ChaserEnemy.new()
		extra.position = Vector2(500 + index * 12, 300)
		world.add_child(extra)
		extra.set_physics_process(false)
	for index: int in 200:
		world._spawn_pickup(Vector2(560 + index % 8, 340 + index % 5), "equipment", LootGenerator.generate(50000 + index, "visual_gate", 5, "sword", "common"))
	await scene_tree.process_frame
	var equipment_drops := 0
	for pickup_value: Node in world.get_tree().get_nodes_in_group("world_pickups"):
		if pickup_value is WorldPickup and (pickup_value as WorldPickup).kind == "equipment" and not pickup_value.is_queued_for_deletion():
			equipment_drops += 1
	var dense_enemy_count := world.get_tree().get_nodes_in_group("attackable").size()
	support.expect(dense_enemy_count >= 5 and equipment_drops <= LootDropPolicy.MAX_WORLD_EQUIPMENT, "dense five-enemy/two-hundred-drop gate must retain bounded readable ownership")
	var stress_start := Time.get_ticks_usec()
	for index: int in 300:
		world._spawn_gameplay_vfx(Vector2(index % 30, index % 20), "critical_hit" if index % 10 == 0 else "normal_hit")
	for visual_value: Node in world.get_tree().get_nodes_in_group("gameplay_vfx"):
		if visual_value is GameplayVfx:
			(visual_value as GameplayVfx)._process(1.0)
		elif visual_value is LegendaryEffectVisual:
			(visual_value as LegendaryEffectVisual)._process(1.0)
	await scene_tree.process_frame
	var stress_usec := Time.get_ticks_usec() - stress_start
	support.expect(world.get_tree().get_nodes_in_group("gameplay_vfx").is_empty(), "three-hundred-effect stress must return to zero active VFX")
	support.expect(stress_usec < 1000000, "bounded VFX stress must complete in under one second on the validation host")
	var capped_plants: Array[LivingArrowPlant] = []
	for plant_index: int in 3:
		var plant := LivingArrowPlant.new()
		plant.plant_id = "perf_%d" % plant_index
		plant.lifetime = 100.0
		plant.position = Vector2(500 + plant_index * 12, 300)
		world.add_child(plant)
		capped_plants.append(plant)
	var plant_stress_start := Time.get_ticks_usec()
	for _frame: int in 600:
		for plant: LivingArrowPlant in capped_plants:
			plant._process(1.0 / 60.0)
	var plant_cap_usec := Time.get_ticks_usec() - plant_stress_start
	support.expect(plant_cap_usec < 1000000, "ten simulated seconds at the three-plant cap must complete in under one second on the validation host")
	support.expect(world.hud.equipment_panel.get_rect().end.y <= 800.0 and world.hud.health_bar.size.y >= 20.0, "dense gate HUD and modal bounds must remain readable at 1280x800")
	var metrics := {
		"seed": 314159,
		"movement_steps_to_first_route_completion": int(smoke.movement_steps),
		"time_to_first_item_proxy_steps": int(smoke.movement_steps),
		"comparison_opened": true,
		"salvage_decision_completed": true,
		"scripted_controller_navigation_failures": scripted_controller_navigation_failures,
		"dense_enemies": dense_enemy_count,
		"bounded_equipment_drops": equipment_drops,
		"vfx_stress_usec": stress_usec,
		"plant_cap_stress_usec": plant_cap_usec,
		"triggered_effects": domain_first.triggered_effects,
		"living_plants": domain_first.living_plants,
	}
	world.queue_free()
	await scene_tree.process_frame
	return metrics

func _legendary_scenario() -> Dictionary:
	var bus := LegendaryEventBus.new()
	var manager := LegendaryBehaviorManager.new(bus)
	var effects: Array[Dictionary] = []
	bus.effect_triggered.connect(func(effect_id: String, payload: Dictionary) -> void: effects.append({"id": effect_id, "payload": payload.duplicate(true)}))
	var maximum_connections := 0
	for index: int in 200:
		manager.sync(["chain_mining", "chain_mining"])
		maximum_connections = maxi(maximum_connections, bus.resource_hit.get_connections().size())
	var targets: Array[Dictionary] = []
	for index: int in 12:
		targets.append({"id": "target_%02d" % index, "distance": float(index + 1)})
	bus.emit_resource_hit({"tick": 20, "source_damage": 8, "origin": Vector2.ZERO, "targets": targets})
	manager.sync(["burning_smelter"])
	for _repeat: int in 100:
		bus.emit_enemy_killed({"enemy_id": "one_burning_enemy", "burning": true, "nearby_ores": []})
	manager.sync(["living_arrows"])
	for index: int in 100:
		bus.emit_hit({"weapon_type": "bow", "seed": 314159, "attack_index": index, "position": Vector2.ZERO})
	var triggered: Array[String] = []
	var chain_ids: Dictionary = {}
	var chain_targets := 0
	var smelting_charges := 0
	var living_plants := 0
	for effect: Dictionary in effects:
		var effect_id := String(effect.id)
		if effect_id not in triggered:
			triggered.append(effect_id)
		if effect_id == "chain_mining":
			chain_targets = (effect.payload.targets as Array).size()
			for target: Dictionary in effect.payload.targets:
				chain_ids[String(target.id)] = true
		elif effect_id == "burning_smelter":
			smelting_charges += int(effect.payload.get("smelting_charges", 0))
		elif effect_id == "living_arrows":
			living_plants += 1
	return {
		"seed": 314159,
		"triggered_effects": triggered,
		"chain_targets": chain_targets,
		"chain_unique": chain_ids.size() == chain_targets,
		"smelting_charges": smelting_charges,
		"living_plants": living_plants,
		"maximum_connections": maximum_connections,
	}
