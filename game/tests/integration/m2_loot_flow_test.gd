extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world._set_combat_processing(false)
	var sword := LootGenerator.generate(81001, "m2", 12, "sword", "rare")
	var bow := LootGenerator.generate(81002, "m2", 12, "bow", "rare")
	var wand := LootGenerator.generate(81003, "m2", 12, "wand", "rare")
	for item: Dictionary in [sword, bow, wand]:
		world._on_pickup_collected("equipment", item)
	support.expect(world.equipment_inventory.items.size() == 3, "three generated weapon archetypes must enter one inventory")
	_isolate_targets(world, [world.enemy])
	world.enemy.global_position = Vector2(210, 0)
	world.player.global_position = Vector2.ZERO
	world.equip_selected_item(0)
	support.expect(String(world.player.attack_profile.style) == "slash", "equipped sword must select slash behavior from shared data")
	support.expect(InputMap.action_get_events("attack").any(func(event: InputEvent) -> bool: return event is InputEventJoypadButton), "all weapon styles must retain controller attack input")
	var sword_target_health := world.enemy.remaining_health
	world._on_attack_requested(Vector2.ZERO, Vector2.RIGHT)
	support.expect(world.enemy.remaining_health == sword_target_health, "sword must not reach a distant target")
	world.equip_selected_item(1)
	world._on_attack_requested(Vector2.ZERO, Vector2.RIGHT)
	await scene_tree.create_timer(0.4).timeout
	support.expect(not is_instance_valid(world.enemy) or world.enemy.remaining_health < sword_target_health, "bow must hit the same distant target through its long narrow profile")
	_isolate_targets(world, [world.ranged_enemy, world.elite_ranged_enemy])
	world.ranged_enemy.global_position = Vector2(105, 0)
	world.elite_ranged_enemy.global_position = Vector2(120, 30)
	world.equip_selected_item(2)
	support.expect(String(world.player.attack_profile.style) == "arcane_burst", "equipped wand must select arcane burst behavior")
	var wand_primary_before := world.ranged_enemy.remaining_health
	var wand_secondary_before := world.elite_ranged_enemy.remaining_health
	world._on_attack_requested(Vector2.ZERO, Vector2.RIGHT)
	support.expect(world.ranged_enemy.remaining_health < wand_primary_before and world.elite_ranged_enemy.remaining_health < wand_secondary_before, "wand must damage primary and nearby splash target in one shared attack path")

	var helmet := LootGenerator.generate(81004, "m2", 20, "iron_helmet", "rare")
	world._on_pickup_collected("equipment", helmet)
	var health_before := world.player.maximum_health
	support.expect(world.equip_selected_item(3) and String(world.equipment_inventory.equipped_slots.get("helmet", "")).ends_with("81004"), "typed helmet must equip without replacing weapon")
	support.expect(world.player.maximum_health > health_before, "equipped armor stats must affect the player")
	var stable_health := world.player.maximum_health
	world._sync_player_equipment()
	support.expect(world.player.maximum_health == stable_health, "repeated scene stat sync must not stack bonuses")
	var snapshot := world.snapshot_state()
	support.expect((snapshot.equipment.equipped_slots as Dictionary).has("weapon") and (snapshot.equipment.equipped_slots as Dictionary).has("helmet"), "snapshot must serialize every occupied typed slot")
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	support.expect(restored.apply_save_payload(world.save_service.encode(snapshot)) and restored.equipment_inventory.equipped_slots == world.equipment_inventory.equipped_slots, "schema-four load must restore all equipment slots")

	var chain_item := LootGenerator.generate(82001, "legend", 30, "sword", "legendary")
	chain_item["legendary_effects"] = ["chain_mining"]
	chain_item["legendary_affix_id"] = "chain_mining"
	world._on_pickup_collected("equipment", chain_item)
	world.equip_selected_item(4)
	support.expect(world.legendary_manager.active_ids().has("chain_mining"), "equipping Chain Mining must attach its behavior component")
	var chain_target := world.second_slime
	chain_target.set_physics_process(false)
	var chain_before := chain_target.remaining_health
	world.legendary_event_bus.emit_resource_hit({"tick": 100, "chain_depth": 0, "source_damage": 6, "targets": [{"id": str(chain_target.get_instance_id()), "kind": "enemy", "distance": 20.0}]})
	support.expect(chain_target.remaining_health < chain_before, "world Chain Mining handler must apply bounded chained damage")
	support.expect(_find_effect_visual(world, "chain_mining") != null, "Chain Mining must create readable visual feedback")

	var smelter_item := LootGenerator.generate(82002, "legend", 30, "wand", "legendary")
	smelter_item["legendary_effects"] = ["burning_smelter"]
	smelter_item["legendary_affix_id"] = "burning_smelter"
	world._on_pickup_collected("equipment", smelter_item)
	world.equip_selected_item(5)
	support.expect(world.legendary_manager.active_ids().has("burning_smelter"), "equipping Burning Smelter must replace the prior behavior cleanly")
	var burned_id := str(chain_target.get_instance_id())
	world._burning_targets[burned_id] = true
	world._emit_enemy_killed(chain_target, Vector2(-800, -500))
	support.expect(world.resource_inventory.amount("smelting_charge") == 1, "burning death without nearby ore must safely create one smelting charge")
	support.expect(_find_effect_visual(world, "burning_smelter") != null, "Burning Smelter must create readable trigger feedback")

	var living_item := LootGenerator.generate(82003, "legend", 30, "bow", "legendary")
	living_item["legendary_effects"] = ["living_arrows"]
	living_item["legendary_affix_id"] = "living_arrows"
	world._on_pickup_collected("equipment", living_item)
	world.equip_selected_item(6)
	support.expect(world.legendary_manager.active_ids().has("living_arrows"), "equipping Living Arrows must attach its separate behavior component")
	for index: int in 100:
		world.legendary_event_bus.emit_hit({"weapon_type": "bow", "seed": 82003, "attack_index": index, "position": Vector2(50, 50)})
	await scene_tree.process_frame
	var plants := world.get_tree().get_nodes_in_group("temporary_legendary")
	support.expect(not plants.is_empty(), "Living Arrows must deterministically create a temporary attacking plant")
	support.expect(plants.size() <= 3, "Living Arrows world integration must enforce the active plant cap")
	support.expect(not snapshot.has("temporary_legendary"), "temporary plants must never enter persistent save state")

	for index: int in 200:
		world._spawn_pickup(Vector2(600 + index % 5, 350), "equipment", LootGenerator.generate(90000 + index, "ground", 5, "sword", "common"))
	await scene_tree.process_frame
	var ground_drops := _equipment_drops(world)
	support.expect(ground_drops.size() <= LootDropPolicy.MAX_WORLD_EQUIPMENT, "two hundred ordinary items must be reduced to the bounded world-drop cap")
	var protected_item := LootGenerator.generate(93000, "ground", 40, "bow", "legendary")
	world._spawn_pickup(Vector2(620, 350), "equipment", protected_item)
	await scene_tree.process_frame
	var protected_pickup := _pickup_by_id(world, String(protected_item.id))
	support.expect(protected_pickup != null and protected_pickup.important, "legendary ground loot must survive cleanup and receive important presentation")

	world.open_equipment_panel()
	world.hud.select_equipment(6)
	await scene_tree.process_frame
	support.expect(world.hud.is_equipment_panel_open() and world.hud.has_valid_action_focus(), "M2 tooltip must be reachable through controller-focused equipment browsing")
	support.expect(world.hud.get_displayed_affix_text().contains("BASE") and world.hud.get_displayed_affix_text().contains("LEGENDARY"), "tooltip must show base stats and legendary behavior")
	support.expect(world.hud.get_displayed_affix_text().contains("LIVING ARROWS"), "tooltip must resolve behavior text from the legendary registry")
	var comparison := world.hud.get_displayed_comparison_text()
	support.expect(comparison.contains("DMG") and comparison.contains("SPEED") and not comparison.contains("ITEM SCORE"), "comparison must show signed real differences without a fake item score")
	world.hud.favorite_button.pressed.emit()
	support.expect(bool(world.equipment_inventory.items[6].favorite), "KEEP action must mark the selected item as favorite")
	support.expect(world.salvage_selected_item(6) == 0 and world.equipment_inventory.items.any(func(item: Dictionary) -> bool: return String(item.get("id", "")) == String(living_item.id)), "favorite protection must prevent accidental salvage")
	world.set_item_favorite(6, false)
	support.expect(not bool(world.equipment_inventory.items[6].favorite), "controller KEEP action must be reversible before salvage")

	world.queue_free()
	restored.queue_free()
	await scene_tree.process_frame

func _isolate_targets(world: FirstPlayableWorld, targets: Array[Node2D]) -> void:
	for candidate: Node in world.get_tree().get_nodes_in_group("attackable"):
		candidate.remove_from_group("attackable")
	for target: Node2D in targets:
		target.add_to_group("attackable")

func _equipment_drops(world: Node) -> Array[WorldPickup]:
	var result: Array[WorldPickup] = []
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == "equipment" and not child.is_queued_for_deletion():
			result.append(child as WorldPickup)
	return result

func _pickup_by_id(world: Node, item_id: String) -> WorldPickup:
	for pickup: WorldPickup in _equipment_drops(world):
		if pickup.payload is Dictionary and String((pickup.payload as Dictionary).get("id", "")) == item_id:
			return pickup
	return null

func _find_effect_visual(world: Node, effect_id: String) -> LegendaryEffectVisual:
	for child: Node in world.get_children():
		if child is LegendaryEffectVisual and (child as LegendaryEffectVisual).effect_id == effect_id:
			return child as LegendaryEffectVisual
	return null
