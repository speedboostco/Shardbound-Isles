extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var scene := load("res://src/gameplay/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var shard := IslandShardGenerator.generate(9001)
	world._on_pickup_collected("island_shard", shard)
	world._on_pickup_collected("island_shard", IslandShardGenerator.generate(9002))
	world._on_pickup_collected("island_shard", IslandShardGenerator.generate(9003))
	world.open_island_panel()
	await scene_tree.process_frame
	support.expect(world.hud.is_island_panel_open() and world.hud.has_valid_action_focus(), "island panel must open with controller focus")
	support.expect(world.hud.island_install_button.get_node(world.hud.island_install_button.focus_neighbor_top) == world.hud.island_previous_button, "controller focus must navigate from Install to shard selection")
	support.expect(world.hud.get_island_count() == 3, "island UI must expose all three owned shards")
	world.hud.island_next_button.pressed.emit()
	support.expect(world.hud.get_selected_island_index() == 1, "controller Next action must inspect the second shard")
	support.expect(world.install_selected_shard(world.hud.get_selected_island_index()), "selected Emberglass shard must install")
	support.expect(world.player.attack_damage == 3 and world.tree.wood_yield == 2, "Emberglass must apply its attack and gathering tradeoff")
	support.expect(world.hud.select_island(0), "controller island UI must return to Verdant")
	support.expect(world.install_selected_shard(0), "owned shard must install into neighboring slot")
	support.expect(world.island_slot.installed and world.installed_shard.get("id") == shard.id, "install must visibly and authoritatively fill slot")
	support.expect(world.tree.wood_yield == 4, "installed positive modifier must increase tree yield")
	support.expect(is_equal_approx(world.enemy.move_speed, 93.75), "installed risk modifier must increase enemy speed")
	support.expect(world.install_selected_shard(0), "installed slot must support controller replacement")
	support.expect(world.tree.wood_yield == 4 and is_equal_approx(world.enemy.move_speed, 93.75), "replacement must recompute modifiers without stacking")
	support.expect(world.remove_installed_shard(), "installed shard must be removable")
	support.expect(not world.island_slot.installed and world.tree.wood_yield == 3, "removal must clear slot and restore tree baseline")
	support.expect(is_equal_approx(world.enemy.move_speed, 75.0), "removal must restore enemy speed baseline")
	support.expect(world.player.attack_damage == 1, "removal must restore baseline attack")
	world.reinforced_heart_crafted = true
	world.build_tidecatcher()
	support.expect(world.hud.select_island(2) and world.install_selected_shard(2), "selected Tempest shard must replace Verdant")
	world.tidecatcher.advance_production(2.0)
	support.expect(world.tidecatcher.stored_wood() == 2, "Tempest must halve Tidecatcher production time")
	var one_angle: Array[float] = [0.0]
	world._on_enemy_volley_requested(world.player.global_position - Vector2(20, 0), Vector2.RIGHT, one_angle, 1)
	support.expect(_latest_projectile_damage(world) == 2, "Tempest risk must add one enemy projectile damage")
	support.expect(world.remove_installed_shard() and is_equal_approx(world.tidecatcher.production_interval_multiplier(), 1.0), "removing Tempest must reset production cadence")
	support.expect(world.install_selected_shard(2) and world.island_slot.shard_biome == "tempest", "reinstall must restore Tempest behavior and physical biome identity")
	var path := "user://island-shard-integration.json"
	support.expect(world.save_game(path), "installed shard state must save")
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	support.expect(restored.load_game(path), "schema-2 save with island state must load")
	support.expect(restored.installed_shard.get("id") == "tempest_loom_9003" and restored.island_slot.installed, "load must restore installed stable shard")
	restored.tidecatcher.advance_production(2.0)
	support.expect(restored.tidecatcher.stored_wood() == 4, "load must deterministically restore Tempest production cadence and stored output")
	world.queue_free()
	restored.queue_free()
	await scene_tree.process_frame

func _latest_projectile_damage(world: Node) -> int:
	var result := -1
	for child: Node in world.get_children():
		if child is EnemyProjectile:
			result = (child as EnemyProjectile).damage
	return result
