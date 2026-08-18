extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(world.player.visual_state().state == "idle", "player must enter the normalized idle state")
	var loadout_attack_atlases: Array[Texture2D] = []
	for loadout: Dictionary in [{"type": "unarmed", "damage": 1}, {"type": "melee", "damage": 2}, {"type": "ranged", "damage": 3}, {"type": "magic", "damage": 4}]:
		world.player.set_weapon_stats(int(loadout.damage), 1.0, String(loadout.type))
		world.player.request_attack()
		world.player._update_visual(0.08)
		loadout_attack_atlases.append((world.player._visual_sprite.texture as AtlasTexture).atlas)
		world.player._attack_cooldown = 0.0
		world.player._attack_flash_remaining = 0.0
	support.expect(loadout_attack_atlases == [VisualAssetLibrary.HERO_UNARMED_ATLAS, VisualAssetLibrary.HERO_MELEE_ATLAS, VisualAssetLibrary.HERO_RANGED_ATLAS, VisualAssetLibrary.HERO_MAGIC_ATLAS], "every weapon family must select its authored full-body action atlas")
	world.player.set_weapon_stats(1, 1.0, "unarmed")
	support.expect(world.player.weapon_base_type == "unarmed" and world.player.attack_damage == 1 and (world.player._visual_sprite.texture as AtlasTexture).atlas == VisualAssetLibrary.HERO_IDLE_ATLAS, "unequip must return to the coherent production hero without changing presentation authority")
	world.player.velocity = Vector2.RIGHT * world.player.move_speed
	world.player._update_visual(0.2)
	support.expect(world.player.visual_state().state == "move", "player movement must bind to the move animation")
	var attack_triggers := world.player.animation_attack_trigger_count()
	support.expect(world.player.request_attack() and world.player.animation_attack_trigger_count() == attack_triggers + 1 and world.player.visual_state().state == "attack", "one accepted attack must trigger exactly one attack animation")
	world.player.take_damage(1)
	world.player._update_visual(0.0)
	support.expect(world.player.visual_state().state == "hit", "player hit reaction must override the active attack pose")
	world.player.facing = Vector2.UP
	world.player._update_visual(0.0)
	support.expect(world.player.visual_state().facing == "north" and not world.player.has_persistent_selection_circle(), "directional animation must remain readable without a persistent player circle")
	var tree_position_before := world.tree._visual_sprite.position
	world.tree._process(0.8)
	support.expect(not world.tree._visual_sprite.position.is_equal_approx(tree_position_before), "tree idle sway must advance through bounded presentation motion")
	world.tree.receive_attack(1)
	support.expect(world.tree.hit_feedback_active() and world.tree._visual_sprite.position.x != 0.0, "resource damage must visibly interrupt idle motion")
	support.expect(world.workbench.get_node_or_null("EmberwoodSprite") != null, "workbench must use its animated authored presentation")
	world.player.global_position = world.workbench.global_position
	world._refresh_interaction_target()
	support.expect(world.current_interaction_target == world.workbench and world.workbench._interaction_targeted, "interaction clarity must move to a target-local bracket highlight")
	world.enemy.state = ChaserEnemy.State.CHASE
	world.enemy.velocity = Vector2.RIGHT
	world.enemy._update_visual(0.2)
	support.expect(world.enemy.animation_state() == "move", "Slime chase state must bind to movement animation")
	world.enemy.state = ChaserEnemy.State.ATTACK
	world.enemy._update_visual(0.0)
	support.expect(world.enemy.animation_state() == "attack", "Slime danger state must bind to a distinct attack tell")
	world.ranged_enemy.advance_attack(0.9)
	world.ranged_enemy._update_visual(0.0)
	support.expect(world.ranged_enemy.animation_state() == "attack", "Forest Ranger telegraph must bind to attack animation")
	world.elite_ranged_enemy._update_visual(0.0)
	var elite_texture := world.elite_ranged_enemy._visual_sprite.texture as AtlasTexture
	support.expect(elite_texture.region.position.x < 768.0 and elite_texture.region.position.y < 256.0 and elite_texture.atlas == VisualAssetLibrary.PUNY_MAGE_ATLAS, "elite enemy presentation must stay inside its distinct cohesive Mage sheet")
	var item := LootGenerator.generate(46053, "ui_icon", 12, "coral_ring", "epic")
	world._on_pickup_collected("equipment", item)
	world.open_equipment_panel()
	await scene_tree.process_frame
	support.expect(world.hud.get_displayed_icon_id() == "ring" and world.hud.equipment_icon.texture != null and world.hud.inventory_strip.get_child_count() == 6, "item definition must resolve to a visible equipment icon and bounded slot strip")
	support.expect(world.hud.has_valid_action_focus() and world.hud.equipment_panel.get_rect().end.y <= 800.0, "controller focus and equipment bounds must remain valid at 1280x800")
	world.close_equipment_panel()
	var pickup := world._spawn_pickup(Vector2(80, 80), "island_shard", IslandShardGenerator.generate(9001))
	support.expect((pickup._visual_sprite.texture as AtlasTexture).region.position == Vector2(448, 256), "world shard drops must use the authored v3 shard icon")
	pickup.collect_immediately()
	await scene_tree.process_frame
	world.open_island_panel()
	await scene_tree.process_frame
	support.expect(world.hud.island_icon.texture != null and world.hud.get_island_preview_text().contains("RISKS"), "shard inspection must combine icon identity with risk/reward text")
	world.close_island_panel()
	support.expect(world.install_selected_shard(0, "east"), "inspected shard must install through the existing transactional M3 path")
	var materialize_vfx := scene_tree.get_nodes_in_group("island_materialization_vfx")
	support.expect(materialize_vfx.size() == 1, "successful installation must produce one bounded materialization payoff")
	support.expect(world.island_slot.materialized != null and world.island_slot.materialized.resource_ids().has("moonleaf"), "installed Forest must visibly create a new gameplay opportunity")
	world.queue_free()
	await scene_tree.process_frame
