extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var scene := load("res://src/gameplay/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var shard := IslandShardGenerator.generate(9001)
	world._on_pickup_collected("island_shard", shard)
	world.open_island_panel()
	await scene_tree.process_frame
	support.expect(world.hud.is_island_panel_open() and world.hud.has_valid_action_focus(), "island panel must open with controller focus")
	support.expect(world.install_selected_shard(0), "owned shard must install into neighboring slot")
	support.expect(world.island_slot.installed and world.installed_shard.get("id") == shard.id, "install must visibly and authoritatively fill slot")
	support.expect(world.tree.wood_yield == 4, "installed positive modifier must increase tree yield")
	support.expect(is_equal_approx(world.enemy.move_speed, 93.75), "installed risk modifier must increase enemy speed")
	support.expect(world.install_selected_shard(0), "installed slot must support controller replacement")
	support.expect(world.tree.wood_yield == 4 and is_equal_approx(world.enemy.move_speed, 93.75), "replacement must recompute modifiers without stacking")
	support.expect(world.remove_installed_shard(), "installed shard must be removable")
	support.expect(not world.island_slot.installed and world.tree.wood_yield == 3, "removal must clear slot and restore tree baseline")
	support.expect(is_equal_approx(world.enemy.move_speed, 75.0), "removal must restore enemy speed baseline")
	world.install_selected_shard(0)
	var path := "user://island-shard-integration.json"
	support.expect(world.save_game(path), "installed shard state must save")
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	support.expect(restored.load_game(path), "schema-2 save with island state must load")
	support.expect(restored.installed_shard.get("id") == shard.id and restored.island_slot.installed, "load must restore installed stable shard")
	support.expect(restored.tree.wood_yield == 4 and is_equal_approx(restored.enemy.move_speed, 93.75), "load must deterministically reapply shard modifiers")
	world.queue_free()
	restored.queue_free()
	await scene_tree.process_frame
