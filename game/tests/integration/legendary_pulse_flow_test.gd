extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world._set_combat_processing(false)
	world._on_pickup_collected("equipment", BossReward.generate())
	support.expect(world.equip_selected_item(0) and world.player.legendary_affix_id == "riftwake_pulse", "equipping Riftwake Core must activate legendary behavior")
	world.enemy.global_position = world.player.global_position + Vector2(40, 0)
	world.ranged_enemy.global_position = world.player.global_position + Vector2(0, 70)
	world.elite_ranged_enemy.global_position = world.player.global_position + Vector2(180, 0)
	world.boss.activate(world.player)
	world.boss.set_physics_process(false)
	world.boss.global_position = world.player.global_position + Vector2(-70, 0)
	var primary_before := world.enemy.remaining_health
	var secondary_before := world.ranged_enemy.remaining_health
	var far_before := world.elite_ranged_enemy.remaining_health
	var boss_before := world.boss.health
	world._on_attack_requested(world.player.global_position, Vector2.RIGHT)
	support.expect(world.enemy.remaining_health == primary_before - world.player.attack_damage, "primary target must receive strike damage exactly once")
	support.expect(world.ranged_enemy.remaining_health == secondary_before - 2, "nearby secondary enemy must receive one pulse hit")
	support.expect(world.elite_ranged_enemy.remaining_health == far_before, "out-of-radius enemy must not receive pulse damage")
	support.expect(world.boss.health == boss_before - 2, "active boss inside the pulse must receive legendary damage")
	support.expect(_find_pulse(world) != null, "legendary attack must create visible pulse evidence")
	world._on_boss_defeated(world.boss.global_position)
	world.player.global_position = world.rift_portal.global_position
	support.expect(world.try_enter_rift(), "legendary interaction test must enter the unlocked rift")
	var rift_primary := world.rift_enemies[0] as ChaserEnemy
	var rift_secondary := world.rift_enemies[1] as ChaserEnemy
	rift_primary.set_physics_process(false)
	rift_secondary.set_physics_process(false)
	rift_primary.global_position = world.player.global_position + Vector2(40, 0)
	rift_secondary.global_position = world.player.global_position + Vector2(0, 70)
	var rift_secondary_before := rift_secondary.remaining_health
	world._on_attack_requested(world.player.global_position, Vector2.RIGHT)
	support.expect(rift_secondary.remaining_health == rift_secondary_before - 2, "pulse must damage a secondary enemy spawned by the rift")
	world.unequip_item()
	support.expect(world.player.legendary_affix_id.is_empty(), "unequipping legendary must disable pulse behavior")
	var path := "user://legendary-pulse-integration.json"
	world.equip_selected_item(0)
	world.save_game(path)
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	support.expect(restored.load_game(path) and restored.player.legendary_affix_id == "riftwake_pulse", "save/load must restore derived legendary behavior")
	world.queue_free()
	restored.queue_free()
	await scene_tree.process_frame

func _find_pulse(world: Node) -> LegendaryPulseVisual:
	for child: Node in world.get_children():
		if child is LegendaryPulseVisual:
			return child as LegendaryPulseVisual
	return null
