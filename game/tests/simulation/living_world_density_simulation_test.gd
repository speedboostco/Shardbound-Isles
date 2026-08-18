extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> Dictionary:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world._set_combat_processing(false)
	support.expect(world.living_world_prop_count() == FirstPlayableWorld.LIVING_WORLD_LAYOUT.size(), "living-world density must remain explicitly bounded")
	world.player.health_component.set_current(4)
	var activated := 0
	for stable_id: String in ["moonleaf_west", "moonleaf_south", "moonleaf_edge", "tidewell_north", "firefly_east", "firefly_south_east"]:
		var prop := world.living_world_prop(stable_id)
		world.player.global_position = prop.global_position
		if prop.interact(world.player):
			activated += 1
	support.expect(activated == 6, "all non-combat living-world opportunities must activate in a fixed route")
	for pickup_value: Node in scene_tree.get_nodes_in_group("world_pickups"):
		if pickup_value is WorldPickup and not pickup_value.is_queued_for_deletion():
			(pickup_value as WorldPickup).collect_immediately()
	await scene_tree.process_frame
	support.expect(world.moonleaf == 3 and world.wood == 2 and world.stone == 2, "fixed living-world route must produce deterministic resource totals")
	support.expect(world.player.health == 7, "fixed living-world route must deterministically heal three health")
	var activation_total := 0
	for stable_id: String in ["moonleaf_west", "moonleaf_south", "moonleaf_edge", "firefly_east", "firefly_south_east"]:
		var prop := world.living_world_prop(stable_id)
		prop.interact(world.player)
		activation_total += prop.activation_count
	support.expect(activation_total == 5, "cooldowns must block immediate resource duplication")
	var shrine := world.living_world_prop("whispering_shrine_south")
	world.player.global_position = shrine.global_position
	shrine.interact(world.player)
	shrine.interact(world.player)
	support.expect(world.active_living_world_guardian_count() == 1, "repeated shrine input must never stack guardians")
	var guardian := world._living_world_guardians[shrine.stable_id] as RangedEnemy
	guardian.receive_attack(99)
	await scene_tree.process_frame
	support.expect(world.active_living_world_guardian_count() == 0 and not shrine.external_locked, "guardian completion must leave no active reference")
	shrine._process(37.0)
	world.player.global_position = shrine.global_position
	support.expect(shrine.interact(world.player) and world.active_living_world_guardian_count() == 1, "completed shrine must become replayable after its bounded cooldown")
	var metrics := {
		"prop_count": world.living_world_prop_count(),
		"prop_types": LivingWorldPropRules.prop_ids().size(),
		"activated": activated,
		"resources": {"moonleaf": world.moonleaf, "wood": world.wood, "stone": world.stone},
		"health": world.player.health,
		"maximum_guardians": 1,
	}
	world.queue_free()
	await scene_tree.process_frame
	return metrics
