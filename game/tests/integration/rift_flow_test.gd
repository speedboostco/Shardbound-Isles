extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(not world.rift_portal.unlocked and not world.try_enter_rift(), "rift must remain locked before boss victory")
	world._on_boss_defeated(Vector2.ZERO)
	support.expect(world.rift_portal.unlocked, "boss victory must unlock physical rift portal")
	support.expect(not world.try_enter_rift(), "rift entry must enforce portal proximity")
	world.player.global_position = world.rift_portal.global_position
	world._on_pickup_collected("island_shard", IslandShardGenerator.generate(9001))
	world.install_selected_shard(0)
	support.expect(world.try_enter_rift(), "nearby player must enter unlocked rift")
	support.expect(world.rift_controller.wave_index == 1 and world.rift_enemies.size() == 2, "entry must spawn deterministic first wave")
	support.expect(_all_speeds(world.rift_enemies, [93.75, 93.75]), "Verdant risk must affect wave-one chasers")
	_defeat_wave(world)
	support.expect(world.rift_controller.wave_index == 2 and world.rift_enemies.size() == 2, "clearing wave one must start wave two")
	_defeat_wave(world)
	support.expect(world.rift_controller.wave_index == 3 and world.rift_enemies.size() == 2, "clearing wave two must start wave three")
	_defeat_wave(world)
	support.expect(world.rift_controller.status == RiftRunController.Status.COMPLETE and world.rift_enemies.is_empty(), "clearing wave three must complete and clean rift combatants")
	support.expect(_find_reward(world, 8801) != null and world.hud.get_rift_feedback().contains("COMPLETE"), "completion must drop first run reward and show exit guidance")
	world.handle_rift_action()
	world.player.global_position = world.rift_portal.global_position
	support.expect(world.try_enter_rift() and world.rift_controller.run_index == 2, "resolved exit must permit a repeat run")
	world.player.take_damage(999)
	support.expect(world.rift_controller.status == RiftRunController.Status.FAILED and world.rift_enemies.is_empty(), "player defeat must fail run and clean enemies")
	support.expect(world.hud.get_rift_feedback().contains("FAILED"), "rift failure must provide clear feedback")
	world.queue_free()
	await scene_tree.process_frame

func _defeat_wave(world: FirstPlayableWorld) -> void:
	var current := world.rift_enemies.duplicate()
	for combatant: Node2D in current:
		combatant.receive_attack(999)

func _all_speeds(enemies: Array[Node2D], expected: Array[float]) -> bool:
	if enemies.size() != expected.size():
		return false
	for index: int in range(enemies.size()):
		if not is_equal_approx(float(enemies[index].get("move_speed")), expected[index]):
			return false
	return true

func _find_reward(world: Node, seed_value: int) -> WorldPickup:
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == "equipment":
			var payload := (child as WorldPickup).payload as Dictionary
			if int(payload.get("seed", -1)) == seed_value:
				return child as WorldPickup
	return null
