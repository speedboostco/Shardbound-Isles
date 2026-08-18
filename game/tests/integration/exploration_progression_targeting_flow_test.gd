extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(world.hud.get_node_or_null("Margin/VBox/Title") == null, "field HUD must not display the game name")
	support.expect(not world.hud.wood_label.visible and not world.hud.attack_label.visible and not world.hud.loot_label.visible, "numeric resources and combat stats must leave the field HUD")
	support.expect(world.hud.mana_bar.visible and world.hud.mana_bar.size.x <= 260.0, "compact mana must remain readable inside the field HUD")
	support.expect(not world.is_combat_unlocked() and not world.enemy.visible and not world.enemy.is_in_group("attackable"), "a new game must begin in a safe exploration phase")
	support.expect(world.hud.technology_heading_label.text.contains("EXPLORATION PHASE"), "inventory technology UI must explain the opening phase")
	world.wood = 5
	world.stone = 3
	support.expect(world.hud.stats_summary_label.text.contains("WOOD 5") and world.hud.stats_summary_label.text.contains("STONE 3"), "inventory must own current resource statistics")
	world.open_equipment_panel()
	await scene_tree.process_frame
	support.expect(world.hud.has_valid_action_focus() and world.hud.open_technology_button.visible, "inventory must expose a controller-focusable technology entry point")
	world.hud.open_technology_button.pressed.emit()
	await scene_tree.process_frame
	support.expect(world.hud.is_technology_page_open() and world.hud.technology_tree_view.visible and world.hud.technology_tree_view.node_count() == 7, "technology entry point must open the seven-node visual graph")
	support.expect(world.hud.technology_details_label.text.contains("UNLOCKS RECIPES"), "technology description must name its craftable unlocks before purchase")
	support.expect(world.hud.has_valid_action_focus(), "visual technology page must establish controller focus")
	world.hud.technology_learn_button.pressed.emit()
	support.expect(world.technology_tree.is_learned("fieldcraft"), "controller learn action must commit Fieldcraft")
	support.expect(world.wood == 3 and world.stone == 2, "Fieldcraft must consume its authored gathering cost")
	world.hud.technology_learn_button.pressed.emit()
	support.expect(world.technology_tree.is_learned("combat_training"), "second controller learn action must commit Combat Training")
	support.expect(world.is_combat_unlocked() and world.enemy.visible and world.enemy.is_in_group("attackable"), "Combat Training must awaken authored threats exactly through progression")
	support.expect(world.terrain_micro_biome_count() == 4 and world.world_obstacle_count() >= 28 and world.world_resident_count() == 2, "terrain must contain distinct dressed micro-biomes, collision landmarks, and interactive residents")
	support.expect(RecipeRegistry.all().size() >= 13 and RecipeRegistry.validate().is_empty(), "workbench content must expose at least thirteen validated recipes")
	world.crafted_building_kits["precision_quiver"] = true
	world.crafted_building_kits["foresters_toolkit"] = true
	world.crafted_building_kits["surveyors_lens"] = true
	world._sync_player_equipment()
	support.expect(world.player.attack_speed >= 1.08, "Precision Quiver recipe must apply its authored attack-speed effect")
	support.expect(world.player.gathering_power >= 1.35, "Forester's Toolkit recipe must apply its authored gathering effect")
	support.expect(world.player.pickup_radius >= 165.0, "Surveyor's Lens recipe must apply its authored pickup effect")
	world.close_equipment_panel()
	world._set_combat_processing(false)
	for target: Node in world.get_tree().get_nodes_in_group("attackable"):
		target.remove_from_group("attackable")
	world.player.set_weapon_stats(3, 1.0, "ranged", "", {"style": "projectile", "range": 260.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0})
	support.expect(world.player.has_weapon_aim_indicator(), "bow equipment must expose a directional range indicator")
	world._on_attack_requested(world.player.global_position, Vector2.RIGHT)
	support.expect(world.get_tree().get_nodes_in_group("player_weapon_projectile").size() == 1 and world.get_tree().get_nodes_in_group("weapon_cast_visual").size() == 1, "an empty-space bow shot must still launch visible causal feedback")
	world.player.set_weapon_stats(3, 1.0, "magic", "", {"style": "arcane_strike", "range": 230.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0})
	world.player._attack_cooldown = 0.0
	var mana_before: float = world.player.mana_pool.current
	support.expect(world.player.request_attack() and world.player.mana_pool.current == mana_before - PlayerCharacter.MAGIC_ATTACK_MANA_COST, "magic casts must emit visuals through the attack signal and consume mana")
	var state := world.snapshot_state()
	support.expect(state.technologies.learned == ["fieldcraft", "combat_training"] and float(state.player.mana) < float(state.player.maximum_mana), "technology and current mana must serialize as authoritative progression")
	world.queue_free()
	await scene_tree.process_frame
