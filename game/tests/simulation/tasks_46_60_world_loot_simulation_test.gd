extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> Dictionary:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var opening := world.run_scripted_smoke()
	support.expect(int(opening.wood) == 3 and int(opening.stone) == 2, "Task 60 route must begin by gathering deterministic resources")
	support.expect(int(opening.enemies_defeated) == 2 and int(opening.items_collected) == 1, "Task 60 route must fight enemies and collect loot")
	var shard_pickup := world._find_pickup("island_shard")
	support.expect(shard_pickup != null and int((shard_pickup.payload as Dictionary).seed) == 9001, "first arena enemy must drop the fixed-seed island shard")
	shard_pickup.collect_immediately()
	world.open_island_panel()
	await scene_tree.process_frame
	var preview := world.hud.get_island_preview_text().to_upper()
	support.expect(preview.contains("FOREST") and preview.contains("POSITIVE") and preview.contains("RISKS") and preview.contains("EXPECTED REWARDS"), "controller inspection must explain purpose, gain, and risk before placement")
	world.hud.select_island_slot("east")
	world.close_island_panel()
	support.expect(world.install_selected_shard(0, "east"), "fixed-seed shard must install into the chosen neighboring slot")
	support.expect(world.island_slot.materialized != null and world.archipelago.slots.east.installed_island.definition.seed == 9001, "installation must visibly and deterministically transform the world")
	var island := world.island_slot.materialized
	world.player.global_position = island.event_marker.global_position
	support.expect(island.event_marker.interact(world.player), "player must be able to access the new island opportunity")
	await scene_tree.process_frame
	support.expect(world._find_pickup("moonleaf") != null, "new island encounter must grant its unique Moonleaf opportunity")
	var animated_enemies: Array[ChaserEnemy] = []
	var animated_resources: Array[ResourceNode] = []
	for index: int in 24:
		var enemy := ChaserEnemy.new()
		enemy.position = Vector2(index * 3, 500)
		world.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.state = ChaserEnemy.State.CHASE
		enemy.velocity = Vector2.RIGHT
		animated_enemies.append(enemy)
	for index: int in 32:
		var resource := ResourceNode.new()
		resource.position = Vector2(index * 3, 540)
		world.add_child(resource)
		animated_resources.append(resource)
	support.expect(animated_enemies.size() == 24 and animated_resources.size() == 32, "animation stress must include many enemies and resource nodes")
	var animation_started := Time.get_ticks_usec()
	for _frame: int in 60:
		for enemy: ChaserEnemy in animated_enemies:
			enemy._update_visual(1.0 / 60.0)
		for resource: ResourceNode in animated_resources:
			resource._process(1.0 / 60.0)
	var animation_stress_usec := Time.get_ticks_usec() - animation_started
	support.expect(animation_stress_usec < 750000, "56 animated presentations over 60 frames must stay within a bounded smoke budget")
	for enemy: ChaserEnemy in animated_enemies:
		enemy.queue_free()
	for resource: ResourceNode in animated_resources:
		resource.queue_free()
	await scene_tree.process_frame
	var save_path := "user://tasks-46-60-world-loot.json"
	support.expect(world.save_game(save_path), "completed world-loot route must save")
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	support.expect(restored.load_game(save_path) and restored.island_slot.materialized != null, "save/load must restore the installed island")
	support.expect(restored.island_slot.materialized.event_marker.claimed, "save/load must not duplicate the claimed island opportunity")
	var metrics := {
		"seed": 9001,
		"gathered": {"wood": opening.wood, "stone": opening.stone},
		"enemies_defeated": opening.enemies_defeated,
		"shard_inspected": true,
		"slot": "east",
		"installed_biome": String(restored.archipelago.slots.east.installed_island.definition.biome),
		"new_opportunity": "moonleaf",
		"animated_presentations": 56,
		"animation_stress_usec": animation_stress_usec,
		"save_restored": true,
	}
	support.expect(metrics.installed_biome == "forest" and metrics.new_opportunity == "moonleaf", "Task 60 metrics must expose the signature payoff")
	world.queue_free()
	restored.queue_free()
	await scene_tree.process_frame
	return metrics
