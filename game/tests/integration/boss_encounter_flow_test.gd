extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(not world.boss.active and not world.boss.visible, "boss must begin locked and hidden")
	world.enemy.receive_attack(99)
	world.ranged_enemy.receive_attack(99)
	world.elite_ranged_enemy.receive_attack(99)
	support.expect(world.boss.active and world.boss.position == Vector2(0, 230), "three enemy defeats must activate boss at fixed spawn")
	support.expect(world.hud.get_encounter_feedback().contains("ABYSSAL WARDEN"), "boss entrance must provide clear feedback")
	world.boss.set_physics_process(false)
	await scene_tree.process_frame
	var volleys: Array[Array] = []
	world.boss.volley_requested.connect(func(_origin: Vector2, directions: Array[Vector2], _damage: int) -> void: volleys.append(directions))
	world.boss.advance_attack(0.9)
	support.expect(world.boss.is_telegraphing() and volleys.is_empty(), "boss phase one must telegraph before firing")
	world.boss.advance_attack(0.7)
	support.expect(volleys.size() == 1 and volleys[0].size() == 2, "phase-one telegraph must resolve into two lances")
	world.boss.receive_attack(6)
	support.expect(world.boss.phase == 2 and is_equal_approx(world.boss.move_speed, 105.0), "half health must trigger faster phase-two behavior")
	world.boss.advance_attack(1.8)
	world.boss.advance_attack(0.4)
	support.expect(volleys.size() == 2 and volleys[1].size() == 8, "phase two must resolve into radial Maelstrom volley")
	world._on_pickup_collected("island_shard", IslandShardGenerator.generate(9001))
	world.install_selected_shard(0)
	support.expect(is_equal_approx(world.boss.move_speed, 131.25), "Verdant risk must multiply current boss phase speed")
	var defeat_signals: Array[int] = [0]
	world.boss.defeated.connect(func(_position: Vector2) -> void: defeat_signals[0] += 1)
	world.boss.receive_attack(99)
	world.boss.receive_attack(99)
	support.expect(defeat_signals[0] == 1, "boss must emit victory only once")
	await scene_tree.process_frame
	support.expect(world.hud.get_encounter_feedback().contains("WARDEN DEFEATED"), "boss death must provide victory feedback")
	var reward := _find_reward(world)
	support.expect(reward != null, "boss death must drop deterministic legendary reward")
	world.queue_free()
	await scene_tree.process_frame

func _find_reward(world: Node) -> WorldPickup:
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == "equipment":
			var payload := (child as WorldPickup).payload as Dictionary
			if payload.get("id") == "riftwake_core_7777":
				return child as WorldPickup
	return null
