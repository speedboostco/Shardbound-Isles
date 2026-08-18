extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(world.expedition.phase() == "dawn" and world.hud.expedition_status_label.text.contains("DAY 1"), "world scene exposes the active expedition phase in the HUD")
	support.expect(world.fiber_patch_west.is_renewable() and world.emberberry_bush_north.is_renewable(), "authored fiber and emberberry nodes use renewable runtime rules")

	world.expedition.elapsed_seconds = 180.0
	world._apply_expedition_effects()
	support.expect(world.expedition.phase() == "night" and world.hud.expedition_status_label.text.contains("NIGHT"), "night transition updates the player-facing expedition status")
	support.expect(is_equal_approx(world.enemy.move_speed, world.BASE_ENEMY_SPEED * 1.12), "night pressure updates a live enemy without per-frame polling")
	support.expect(world.expedition_light.color != Color.WHITE, "night applies a visible world-lighting treatment while the HUD remains independent")
	var cycle_effects: Dictionary = world.expedition.effects(world.current_biome())
	world._on_resource_depleted(Vector2(30.0, 0.0), "fiber", 1)
	var fiber_pickups := world.get_tree().get_nodes_in_group("world_pickups").filter(func(node: Node) -> bool: return node is WorldPickup and (node as WorldPickup).kind == "fiber")
	var expected_yield := 1 + int(cycle_effects.manual_yield_bonus) + int(cycle_effects.forage_yield_bonus)
	support.expect(fiber_pickups.any(func(node: Node) -> bool: return int((node as WorldPickup).payload) == expected_yield), "night and weather opportunity bonuses resolve into the actual pickup payload")

	world.survival.add_ration()
	world.player.health = 5
	world.player.mana_pool.spend(20.0)
	support.expect(world.rest_at_field_camp() and is_equal_approx(world.expedition.shelter_remaining, 90.0), "field-camp rest activates the expedition shelter window")
	support.expect(world.player.expedition_damage_reduction == 1 and is_equal_approx(world.player.mana_pool.regeneration_per_second, 8.0), "shelter grants one damage reduction and two mana regeneration")
	var health_before := world.player.health
	world.player.take_damage(3)
	support.expect(world.player.health == health_before - 2, "live player damage passes through bounded shelter protection")
	var expiry: Dictionary = world.advance_expedition(90.0)
	support.expect(bool(expiry.shelter_expired) and world.player.expedition_damage_reduction == 0, "shelter expiry removes protection through the event update")
	support.expect(is_equal_approx(world.player.mana_pool.regeneration_per_second, 6.0), "shelter expiry restores baseline mana regeneration")

	var forage: ResourceNode = world.fiber_patch_west
	forage.receive_attack(1)
	support.expect(is_instance_valid(forage) and not forage.is_available() and forage.regrow_remaining() > 0.0, "harvested forage remains as a depleted renewable world object")
	support.expect(not forage.is_in_group("attackable"), "depleted forage leaves combat targeting until regrown")
	var depleted_state: Dictionary = forage.runtime_state()
	support.expect(float(depleted_state.regrow_remaining) <= 45.0 and float(depleted_state.regrow_remaining) > 0.0, "depleted forage exposes serializable remaining regrowth time")
	forage.restore_runtime_state({"available": false, "regrow_remaining": 1.0})
	forage._process(1.0)
	support.expect(forage.is_available() and forage.is_in_group("attackable"), "renewable forage returns at its exact regrowth boundary")

	world.emberberry_bush_north.receive_attack(1)
	var snapshot: Dictionary = world.snapshot_state()
	support.expect(snapshot.expedition is Dictionary and not bool(snapshot.forage.emberberry_north.available), "snapshot captures expedition time and an in-progress forage timer")
	var decoded: Dictionary = world.save_service.decode(world.save_service.encode(snapshot))
	support.expect(bool(decoded.ok) and int(decoded.schema_version) == 11, "schema eleven validates expedition and renewable-forage state")
	var replay := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(replay)
	await scene_tree.process_frame
	replay._apply_state(decoded.state as Dictionary)
	support.expect(replay.expedition.to_dictionary() == world.expedition.to_dictionary(), "loaded world restores exact day, time, seed, and shelter duration")
	var replay_regrow := replay.emberberry_bush_north.regrow_remaining()
	var source_regrow := world.emberberry_bush_north.regrow_remaining()
	support.expect(not replay.emberberry_bush_north.is_available() and absf(replay_regrow - source_regrow) < 0.2, "loaded world preserves depleted forage and its remaining timer without duplicating its reward")
	var legacy_state := snapshot.duplicate(true)
	legacy_state.erase("expedition")
	legacy_state.erase("forage")
	var migrated: Dictionary = world.save_service.decode(JSON.stringify({"schema_version": 8, "state": legacy_state}))
	support.expect(bool(migrated.ok) and int(migrated.migrated_from) == 8 and float(migrated.state.expedition.elapsed_seconds) == 0.0, "schema-eight saves migrate to a safe first-dawn expedition")
	support.expect(bool(migrated.state.forage.fiber_west.available) and bool(migrated.state.forage.emberberry_east.available), "schema-eight migration restores every forage source as available")
	world.queue_free()
	replay.queue_free()
	await scene_tree.process_frame
