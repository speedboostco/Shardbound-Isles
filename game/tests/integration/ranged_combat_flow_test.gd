extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	support.expect(world.ranged_enemy.position == Vector2(-390, -120) and world.elite_ranged_enemy.position == Vector2(360, 245), "ranged spawn positions must be fixed")
	world.ranged_enemy.set_physics_process(false)
	world.elite_ranged_enemy.set_physics_process(false)
	await scene_tree.process_frame
	var ordinary_volleys: Array[Array] = []
	var elite_volleys: Array[Array] = []
	world.ranged_enemy.volley_requested.connect(func(_origin: Vector2, _direction: Vector2, angles: Array[float], _damage: int) -> void: ordinary_volleys.append(angles))
	world.elite_ranged_enemy.volley_requested.connect(func(_origin: Vector2, _direction: Vector2, angles: Array[float], _damage: int) -> void: elite_volleys.append(angles))
	world.ranged_enemy.advance_attack(0.8)
	support.expect(world.ranged_enemy.is_telegraphing() and ordinary_volleys.is_empty(), "ordinary enemy must telegraph before firing")
	world.ranged_enemy.advance_attack(0.55)
	support.expect(ordinary_volleys.size() == 1 and ordinary_volleys[0].size() == 1, "ordinary telegraph must resolve into one projectile request")
	world.elite_ranged_enemy.advance_attack(0.8)
	world.elite_ranged_enemy.advance_attack(0.55)
	support.expect(elite_volleys.size() == 1 and elite_volleys[0].size() == 3, "elite telegraph must resolve into three projectile requests")
	var health_before := world.player.health
	var projectile := world.spawn_enemy_projectile(world.player.global_position - Vector2(8, 0), Vector2.RIGHT, 1)
	projectile.advance(0.02)
	support.expect(world.player.health == health_before - 1 and projectile.consumed, "projectile must damage player exactly once on contact")
	world._on_pickup_collected("island_shard", IslandShardGenerator.generate(9001))
	world.install_selected_shard(0)
	support.expect(is_equal_approx(world.enemy.move_speed, 93.75), "shard must accelerate chaser")
	support.expect(is_equal_approx(world.ranged_enemy.move_speed, 81.25) and is_equal_approx(world.elite_ranged_enemy.move_speed, 106.25), "shard must accelerate both ranged baselines")
	world.remove_installed_shard()
	support.expect(is_equal_approx(world.ranged_enemy.move_speed, 65.0) and is_equal_approx(world.elite_ranged_enemy.move_speed, 85.0), "shard removal must restore ranged baselines")
	world.ranged_enemy.receive_attack(99)
	await scene_tree.process_frame
	var ordinary_drop := _find_equipment_seed(world, FirstPlayableWorld.RANGED_LOOT_SEED)
	support.expect(ordinary_drop != null, "ordinary ranged death must emit deterministic equipment loot")
	support.expect(_find_island_seed(world, FirstPlayableWorld.RANGED_ISLAND_SHARD_SEED) != null, "ordinary ranged death must emit deterministic Emberglass shard loot")
	world.elite_ranged_enemy.receive_attack(99)
	await scene_tree.process_frame
	var elite_drop := _find_equipment_seed(world, FirstPlayableWorld.ELITE_LOOT_SEED)
	support.expect(elite_drop != null, "elite death must emit its deterministic equipment loot")
	support.expect(_find_island_seed(world, FirstPlayableWorld.ELITE_ISLAND_SHARD_SEED) != null, "elite death must emit deterministic Tempest shard loot")
	world.queue_free()
	await scene_tree.process_frame

func _find_equipment_seed(world: Node, seed_value: int) -> WorldPickup:
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == "equipment":
			var payload := (child as WorldPickup).payload as Dictionary
			if int(payload.get("seed", -1)) == seed_value:
				return child as WorldPickup
	return null

func _find_island_seed(world: Node, seed_value: int) -> WorldPickup:
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == "island_shard":
			var payload := (child as WorldPickup).payload as Dictionary
			if int(payload.get("seed", -1)) == seed_value:
				return child as WorldPickup
	return null
