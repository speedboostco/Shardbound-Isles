extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world._set_combat_processing(false)
	var obstacles := scene_tree.get_nodes_in_group("world_obstacle")
	support.expect(obstacles.size() >= 12, "opening arena must contain at least twelve deliberate solid world props")
	var contracts_valid := true
	for obstacle_value: Node in obstacles:
		var obstacle := obstacle_value as WorldObstacle
		contracts_valid = contracts_valid and obstacle != null and obstacle.get_node_or_null("CollisionShape2D") != null and obstacle.blocks_movement() and not obstacle.deals_contact_damage()
	support.expect(contracts_valid, "every world obstacle must block movement through an explicit shape without contact damage")
	support.expect(world.non_colliding_detail_count() >= 24, "opening arena must include at least twenty-four non-colliding terrain details")
	var target := obstacles[obstacles.size() - 1] as WorldObstacle
	var shape := target.get_node("CollisionShape2D") as CollisionShape2D
	var radius := float((shape.shape as CircleShape2D).radius)
	world.player.global_position = target.global_position + Vector2(-radius - 18.0, 0.0)
	var health_before := world.player.health
	for frame: int in 20:
		world.player.velocity = Vector2.RIGHT * world.player.move_speed
		world.player.move_and_slide()
		await scene_tree.physics_frame
	var separation := world.player.global_position.distance_to(target.global_position)
	support.expect(separation >= radius + 15.0 and world.player.global_position.x < target.global_position.x, "player physics body must stop at a solid terrain object")
	support.expect(world.player.health == health_before, "colliding with terrain objects must never damage the hero")
	support.expect(world.tree.get_node_or_null("CollisionShape2D") != null and world.stone_node.get_node_or_null("CollisionShape2D") != null, "gatherable terrain objects must retain solid collision")
	world.queue_free()
	await scene_tree.process_frame
