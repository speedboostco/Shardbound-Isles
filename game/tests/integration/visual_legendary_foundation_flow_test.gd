extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var art_scene_resource := load("res://game/content/art_validation.tscn") as PackedScene
	support.expect(art_scene_resource != null, "pixel-perfect validation scene must load")
	var art_scene := art_scene_resource.instantiate() as ArtValidationScene
	scene_tree.root.add_child(art_scene)
	await scene_tree.process_frame
	support.expect(art_scene.sample_count() == 6, "validation scene must include representative hero, enemies, resources and loot")
	art_scene.queue_free()
	await scene_tree.process_frame

	var world_scene := load("res://game/content/world.tscn") as PackedScene
	var world := world_scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var hero_sprite := world.player.get_node_or_null("EmberwoodSprite") as Sprite2D
	support.expect(hero_sprite != null and hero_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "hero must use the registered nearest-filtered production sprite")
	world.player.facing = Vector2.UP
	world.player._update_visual(0.0)
	support.expect(String(world.player.visual_state().facing) == "north", "hero visual direction must follow deterministic facing rules")
	support.expect(world.tree.get_node_or_null("EmberwoodSprite") != null and world.stone_node.get_node_or_null("EmberwoodSprite") != null, "tree and stone must use cohesive registered art")
	support.expect(world.tree.get_node_or_null("CollisionShape2D") != null and world.stone_node.get_node_or_null("CollisionShape2D") != null, "visual replacement must preserve separate resource collisions")
	world.tree.receive_attack(1)
	support.expect(world.tree.hit_feedback_active() and world.tree.remaining_hits == 1, "resource hit feedback must be visible without changing authoritative damage")

	world.enemy.set_physics_process(false)
	world.enemy.global_position = world.player.global_position + Vector2(30, 0)
	var player_health := world.player.health
	world.enemy._physics_process(0.01)
	support.expect(world.enemy.is_telegraphing() and world.player.health == player_health, "Slime contact attack must begin with an actionable visual tell")
	world.enemy._physics_process(0.23)
	support.expect(not world.enemy.is_telegraphing() and world.player.health == player_health - 1, "Slime tell must resolve exactly one gameplay damage event")
	world.ranged_enemy.set_physics_process(false)
	world.ranged_enemy.advance_attack(0.9)
	support.expect(world.ranged_enemy.is_telegraphing(), "Forest Ranger must preserve its ranged attack tell")
	world.ranged_enemy._update_visual()
	support.expect(world.ranged_enemy._visual_asset_id == "ranger_attack", "Forest Ranger tell must select a distinct attack silhouette")

	var normal := world._spawn_gameplay_vfx(Vector2.ZERO, "normal_hit")
	var critical := world._spawn_gameplay_vfx(Vector2(20, 0), "critical_hit")
	support.expect(normal.effect_kind != critical.effect_kind and critical.duration > normal.duration, "normal and critical hit feedback must remain visibly distinct contracts")
	support.expect(world.get_tree().get_nodes_in_group("gameplay_vfx").size() >= 2, "spawned gameplay VFX must be trackable for lifecycle validation")
	normal._process(1.0)
	critical._process(1.0)
	await scene_tree.process_frame
	support.expect(not is_instance_valid(normal) and not is_instance_valid(critical), "ordinary combat VFX must clean themselves up")

	world.hud.set_health(4, 12)
	var hud_backdrop := world.hud.get_node("Backdrop") as Control
	support.expect(is_equal_approx(world.hud.health_bar.max_value, 12.0) and is_equal_approx(world.hud.health_bar.value, 4.0) and hud_backdrop.get_global_rect().end.y >= world.hud.loot_label.get_global_rect().end.y, "cohesive HUD must mirror observed health and contain every status line inside its backdrop")
	var focus_style := world.hud.equip_button.get_theme_stylebox("focus") as StyleBoxFlat
	support.expect(focus_style != null and focus_style.border_width_left == 4, "controller focus must use the shared high-contrast four-pixel outline")
	var important_item := LootGenerator.generate(45001, "visual_flow", 30, "bow", "legendary")
	var important_pickup := world._spawn_pickup(Vector2(500, 400), "equipment", important_item)
	support.expect(important_pickup != null and important_pickup.important and important_pickup.get_node_or_null("EmberwoodSprite") != null, "Legendary drop must combine shape/beam importance with a registered sprite")
	var rarity_cues: Array[String] = []
	for rarity: String in ["common", "magic", "rare", "epic", "legendary"]:
		var rarity_item := LootGenerator.generate(45100 + rarity_cues.size(), "rarity_flow", 20, "sword", rarity)
		var rarity_pickup := world._spawn_pickup(Vector2(300 + rarity_cues.size() * 25, 300), "equipment", rarity_item)
		rarity_cues.append(rarity_pickup.rarity_cue())
	support.expect(rarity_cues == ["gray_circle", "cyan_triangle", "blue_diamond", "violet_star", "gold_hex_beam"], "all five equipment tiers must have distinct non-color-only world cues")

	var chain_item := LootGenerator.generate(45002, "visual_flow", 30, "sword", "legendary")
	chain_item.legendary_effects = ["chain_mining"]
	chain_item.legendary_affix_id = "chain_mining"
	world._on_pickup_collected("equipment", chain_item)
	world.equip_selected_item(0)
	support.expect(world.legendary_manager.active_ids() == ["chain_mining"], "equipping Chain Mining must attach exactly its behavior")
	var chain_target := ChaserEnemy.new()
	world.add_child(chain_target)
	chain_target.set_physics_process(false)
	var chain_before := chain_target.remaining_health
	world.legendary_event_bus.emit_resource_hit({"tick": 80, "source_damage": 2, "origin": Vector2.ZERO, "targets": [{"id": str(chain_target.get_instance_id()), "distance": 20.0}, {"id": str(chain_target.get_instance_id()), "distance": 21.0}]})
	support.expect(chain_target.remaining_health == chain_before - 1, "duplicate Chain Mining targets must be damaged only once per activation")
	support.expect(_effect_visual(world, "chain_mining") != null, "Chain Mining must create its distinct zig-zag presentation")

	var smelter_item := LootGenerator.generate(45003, "visual_flow", 30, "wand", "legendary")
	smelter_item.legendary_effects = ["burning_smelter"]
	smelter_item.legendary_affix_id = "burning_smelter"
	world._on_pickup_collected("equipment", smelter_item)
	world.equip_selected_item(1)
	support.expect(world.legendary_manager.active_ids() == ["burning_smelter"], "equipping Burning Smelter must detach Chain Mining cleanly")
	var charge_before: int = int(world.resource_inventory.amount("smelting_charge"))
	world.legendary_event_bus.emit_enemy_killed({"enemy_id": "burned_flow", "burning": true, "nearby_ores": [], "position": Vector2(80, 80)})
	world.legendary_event_bus.emit_enemy_killed({"enemy_id": "burned_flow", "burning": true, "nearby_ores": [], "position": Vector2(80, 80)})
	support.expect(world.resource_inventory.amount("smelting_charge") == charge_before + 1 and "SMELT CHARGE" in world.hud.smelting_charge_label.text, "Burning Smelter world reward must remain one-shot and visible")
	var stone_before: int = world.resource_inventory.amount("stone")
	world._on_pickup_collected("stone", 1)
	support.expect(world.resource_inventory.amount("smelting_charge") == charge_before and world.resource_inventory.amount("stone") == stone_before + 2, "one visible smelting charge must be consumed into one bounded bonus Stone")
	support.expect(_effect_visual(world, "burning_smelter") != null, "Burning Smelter must create its distinct fire/diamond presentation")

	var living_item := LootGenerator.generate(45004, "visual_flow", 30, "bow", "legendary")
	living_item.legendary_effects = ["living_arrows"]
	living_item.legendary_affix_id = "living_arrows"
	world._on_pickup_collected("equipment", living_item)
	world.equip_selected_item(2)
	support.expect(world.legendary_manager.active_ids() == ["living_arrows"], "equipping Living Arrows must attach through the shared lifecycle")
	var impact_target := ChaserEnemy.new()
	impact_target.set_physics_process(false)
	impact_target.global_position = world.player.global_position + Vector2(60, 0)
	world.add_child(impact_target)
	var proc_index := 0
	while SeededRngStreams.from_seed(45004 ^ (proc_index * 104729)).randf() > 0.35:
		proc_index += 1
	world._attack_index = proc_index
	world._resolve_player_projectiles_immediately = false
	var impact_projectile := world._spawn_player_projectile(world.player.global_position, Vector2.RIGHT, impact_target, 1)
	support.expect(world.get_tree().get_nodes_in_group("temporary_legendary").is_empty(), "Living Arrows must not summon before a projectile impact")
	impact_projectile.resolve_immediately()
	await scene_tree.process_frame
	support.expect(world.get_tree().get_nodes_in_group("temporary_legendary").size() == 1, "a deterministic eligible projectile impact must summon exactly one Living Arrows plant")
	world.unequip_item("weapon")
	world.equip_selected_item(2)
	var missed_target := ChaserEnemy.new()
	missed_target.set_physics_process(false)
	world.add_child(missed_target)
	world._spawn_player_projectile(world.player.global_position, Vector2.RIGHT, missed_target, 1)
	missed_target.queue_free()
	await scene_tree.process_frame
	support.expect(world.get_tree().get_nodes_in_group("temporary_legendary").is_empty(), "expired or targetless arrows must not summon Living Arrows plants")
	for index: int in 100:
		world.legendary_event_bus.emit_hit({"weapon_type": "bow", "seed": 45004, "attack_index": index, "position": Vector2(120 + index, 100)})
	await scene_tree.process_frame
	var plants := world.get_tree().get_nodes_in_group("temporary_legendary")
	support.expect(plants.size() > 0 and plants.size() <= 3, "Living Arrows world summons must remain visible and capped")
	world.unequip_item("weapon")
	await scene_tree.process_frame
	support.expect(not world.legendary_manager.is_active("living_arrows") and world.get_tree().get_nodes_in_group("temporary_legendary").is_empty(), "unequipping Living Arrows must prevent new summons and safely clean existing ones")

	world.open_equipment_panel()
	await scene_tree.process_frame
	support.expect(world.hud.equipment_panel.visible and world.hud.get_viewport().gui_get_focus_owner() is Button, "restyled equipment UI must open with valid controller focus")
	support.expect(world.hud.equipment_tooltip_scroll.size.y >= 150.0 and world.hud.equipment_panel.get_rect().end.y <= 800.0, "long tooltip region and actions must remain inside the 1280x800 frame")
	world.hud.set_encounter_feedback("ENCOUNTER STATUS")
	world.hud.set_rift_feedback("RIFT STATUS")
	world.hud.open_equipment_panel()
	world.hud.close_equipment_panel()
	support.expect(world.hud.encounter_label.visible and world.hud.rift_label.visible, "closing equipment must restore non-empty encounter and rift status labels")
	world.queue_free()
	await scene_tree.process_frame

func _effect_visual(world: Node, effect_id: String) -> LegendaryEffectVisual:
	for child: Node in world.get_children():
		if child is LegendaryEffectVisual and (child as LegendaryEffectVisual).effect_id == effect_id:
			return child as LegendaryEffectVisual
	return null
