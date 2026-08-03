extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame

	support.expect(world.camera.position_smoothing_enabled and world.camera.position_smoothing_speed > 0.0, "camera must follow with smoothing enabled")
	support.expect(world.camera.limit_right - world.camera.limit_left >= 1280 and world.camera.limit_bottom - world.camera.limit_top >= 800, "camera limits must contain a full 1280x800 viewport")
	support.expect(not world.camera.request_shake() and world.camera.offset == Vector2.ZERO, "camera shake must be independently disabled by default")
	world.camera.shake_enabled = true
	support.expect(world.camera.request_shake(5.0, 0.1), "camera shake must be explicitly enableable")
	world.camera._process(0.02)
	support.expect(not world.camera.offset.is_zero_approx(), "enabled camera shake must create visible offset")
	world.camera._process(0.2)
	support.expect(world.camera.offset == Vector2.ZERO, "camera shake must settle back to its independent follow position")
	var start_position := world.player.global_position
	Input.action_press("move_right", 0.5)
	world.player._physics_process(1.0 / 60.0)
	Input.action_release("move_right")
	support.expect(world.player.velocity.length() > 0.0 and world.player.velocity.length() < 240.0 and world.player.facing == Vector2.RIGHT and world.player.global_position.x > start_position.x, "actual player input must preserve partial analog stick strength and facing")
	Input.action_press("move_right")
	Input.action_press("move_down")
	world.player._physics_process(1.0 / 60.0)
	Input.action_release("move_right")
	Input.action_release("move_down")
	support.expect(is_equal_approx(world.player.velocity.length(), 240.0), "actual diagonal player input must remain capped at straight-line speed")
	world.player.global_position = Vector2.ZERO

	support.expect(world.tree is ResourceNode and world.stone_node is ResourceNode, "tree and stone must use one shared runtime resource node")
	support.expect(world.tree.resource_id == "wood" and world.stone_node.resource_id == "stone", "typed definitions must select each resource result")
	support.expect(world.tree.hit_points == 2 and world.stone_node.hit_points == 3 and world.tree.wood_yield == 3, "typed definitions must own health and yield")
	world.tree.receive_attack(1)
	support.expect(world.tree.damage_stage() == 1, "resource hits must produce inspectable visual damage stage feedback")

	world.player.global_position = world.workbench.global_position + Vector2(60, 0)
	world._on_player_moved(world.player.global_position)
	support.expect(world.hud.get_interaction_prompt().contains("WORKBENCH"), "nearby universal interaction must show a contextual prompt")
	support.expect(world.current_interaction_target == world.workbench, "interaction controller must expose the selected nearby target")
	world._on_interaction_requested()
	support.expect(world.hud.is_workbench_panel_open(), "the universal interaction action must activate the selected target")
	world.close_workbench_panel()
	var interact_events := InputMap.action_get_events("interact")
	support.expect(interact_events.any(func(event: InputEvent) -> bool: return event is InputEventJoypadButton), "interaction must have a controller binding")
	var attack_events := InputMap.action_get_events("attack")
	support.expect(attack_events.any(func(event: InputEvent) -> bool: return event is InputEventJoypadButton), "melee attack must have a controller binding")

	var start_usec := Time.get_ticks_usec()
	for index: int in 100:
		world._spawn_pickup(Vector2(700, 450), "wood", 1)
	var elapsed_usec := Time.get_ticks_usec() - start_usec
	print("M1_PICKUP_METRICS %s" % JSON.stringify({"drops": 100, "elapsed_usec": elapsed_usec}))
	var resource_pickups: Array[WorldPickup] = []
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == "wood":
			resource_pickups.append(child as WorldPickup)
	support.expect(resource_pickups.size() == 1, "one hundred identical nearby drops must coalesce into one physical stack")
	support.expect(resource_pickups[0].payload == 100 and resource_pickups[0].target == world.player, "merged resource stack must preserve quantity and magnetic target")
	support.expect(elapsed_usec < 500000, "coalescing one hundred drops must complete within the measured half-second budget")
	world.resource_inventory.add("stone", 1)
	support.expect(world.hud.get_displayed_stone() == 1, "resource inventory signals must update HUD without frame polling")

	world.player.attack_speed = 1.0
	support.expect(world.player.request_attack() and not world.player.request_attack(), "melee attack must enforce one request per cooldown")
	world.player._physics_process(1.0)
	world.player.attack_speed = 2.0
	support.expect(world.player.request_attack() and world.player.attack_cooldown_remaining() < 0.2, "weapon attack speed must shorten the real cooldown")
	world.player.confirm_hit()
	support.expect(world.player.is_hit_feedback_active(), "successful hits must activate explicit player feedback")
	support.expect(world.player.health_component != null and world.enemy.health_component != null, "player and Slime must share the health-component contract")
	support.expect(world.enemy.get_node_or_null("CollisionShape2D") != null and world.enemy.state != ChaserEnemy.State.DEAD, "Slime must have collision and an explicit living AI state")

	world.queue_free()
	await scene_tree.process_frame
