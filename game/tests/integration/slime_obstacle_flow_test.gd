extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var target := Node2D.new()
	target.position = Vector2(150, 0)
	scene_tree.root.add_child(target)
	var obstacle := StaticBody2D.new()
	obstacle.position = Vector2(60, 0)
	var obstacle_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(34, 90)
	obstacle_shape.shape = rectangle
	obstacle.add_child(obstacle_shape)
	scene_tree.root.add_child(obstacle)
	var slime := ChaserEnemy.new()
	slime.target = target
	slime.position = Vector2.ZERO
	scene_tree.root.add_child(slime)
	await scene_tree.process_frame
	var start_distance := slime.global_position.distance_to(target.global_position)
	for frame: int in 120:
		await scene_tree.physics_frame
	var end_distance := slime.global_position.distance_to(target.global_position)
	support.expect(slime.state in [ChaserEnemy.State.CHASE, ChaserEnemy.State.ATTACK], "Slime must expose an explicit pursuit or attack state")
	support.expect(end_distance < start_distance and absf(slime.global_position.y) > 5.0, "Slime must steer around a simple blocking obstacle instead of remaining stuck")
	var deaths: Array[int] = [0]
	slime.defeated.connect(func(_position: Vector2) -> void: deaths[0] += 1)
	slime.receive_attack(999)
	slime.receive_attack(999)
	support.expect(deaths[0] == 1 and slime.state == ChaserEnemy.State.DEAD, "Slime death must emit once and enter an explicit dead state")
	support.expect(slime.velocity == Vector2.ZERO and not slime.is_physics_processing(), "dead Slime must stop moving immediately")
	target.queue_free()
	obstacle.queue_free()
	await scene_tree.process_frame
