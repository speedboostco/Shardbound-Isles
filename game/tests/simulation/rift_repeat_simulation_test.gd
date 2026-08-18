extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> Dictionary:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world._on_boss_defeated(Vector2.ZERO)
	world.player.global_position = world.rift_portal.global_position
	world.try_enter_rift()
	var waves_cleared := 0
	var respites_observed := 0
	var maximum_active := world.rift_enemies.size()
	while world.rift_controller.status == RiftRunController.Status.ACTIVE:
		var current := world.rift_enemies.duplicate()
		for combatant: Node2D in current:
			combatant.receive_attack(999)
		if not current.is_empty():
			waves_cleared += 1
		if world.rift_controller.status == RiftRunController.Status.ACTIVE and world.rift_enemies.is_empty():
			respites_observed += 1
			world.advance_rift_spawn(RiftRules.WAVE_RESPITE_SECONDS)
		maximum_active = maxi(maximum_active, world.rift_enemies.size())
	var first_reward_seed := _reward_seed(world)
	support.expect(waves_cleared == 3, "simulation must clear exactly three deterministic waves")
	support.expect(world.rift_controller.status == RiftRunController.Status.COMPLETE, "first simulated run must complete")
	support.expect(first_reward_seed == 8801, "first simulated run must produce deterministic reward seed")
	support.expect(respites_observed == 2 and maximum_active == 1, "simulation must keep enemy density at one and expose two between-wave respites")
	world.handle_rift_action()
	world.player.global_position = world.rift_portal.global_position
	world.try_enter_rift()
	world.handle_rift_action()
	support.expect(world.rift_controller.run_index == 2, "simulation must start a distinct second run")
	support.expect(world.rift_controller.status == RiftRunController.Status.FAILED and world.rift_enemies.is_empty(), "second-run retreat must fail cleanly")
	var metrics := {"waves_cleared": waves_cleared, "respites": respites_observed, "maximum_active": maximum_active, "first_reward_seed": first_reward_seed, "runs_started": world.rift_controller.run_index, "second_run_status": "failed"}
	world.queue_free()
	await scene_tree.process_frame
	return metrics

func _reward_seed(world: Node) -> int:
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == "equipment":
			var payload := (child as WorldPickup).payload as Dictionary
			if String(payload.get("id", "")).begins_with("rift_cache_"):
				return int(payload.get("seed", -1))
	return -1
