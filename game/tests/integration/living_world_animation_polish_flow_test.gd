extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	world._set_combat_processing(false)
	support.expect(world.living_world_prop_count() == 7, "starting island must contain seven bounded interactive living-world props")
	support.expect(scene_tree.get_nodes_in_group("living_world_prop").size() == 7, "all living-world props must register with the scene")
	var present_types: Dictionary = {}
	for prop_value: Node in scene_tree.get_nodes_in_group("living_world_prop"):
		present_types[(prop_value as LivingWorldProp).prop_id] = true
	support.expect(present_types.size() == 4, "four mechanically distinct living-world prop types must be present")
	support.expect(world.island_slot.get_node_or_null("EmberwoodSprite") != null and not world.island_slot.uses_plus_marker(), "empty island zone must render an authored pedestal without a plus glyph")
	support.expect((world.island_slot._visual_sprite.texture as AtlasTexture).region.position == Vector2(128, 128), "empty slot must use the dormant pedestal art")
	support.expect(not world.player.has_persistent_weapon_line(), "player presentation must not draw a persistent weapon line")
	var thicket := world.living_world_prop("moonleaf_west")
	world.player.global_position = thicket.global_position
	world._refresh_interaction_target()
	support.expect(world.current_interaction_target == thicket and world.hud.get_interaction_prompt().contains("FORAGE"), "controller interaction targeting must identify a nearby Moonleaf Thicket")
	var moonleaf_before := world.moonleaf
	support.expect(thicket.interact(world.player) and thicket.activation_count == 1 and thicket.cooldown_remaining > 0.0, "foraging must activate once and enter cooldown")
	await scene_tree.process_frame
	await scene_tree.process_frame
	support.expect(world.moonleaf == moonleaf_before + 1, "Moonleaf Thicket must grant a collectible gameplay resource")
	support.expect(not thicket.interact(world.player) and thicket.activation_count == 1, "cooldown must prevent duplicate forage rewards")
	var tidewell := world.living_world_prop("tidewell_north")
	world.player.health_component.set_current(4)
	world.player.global_position = tidewell.global_position
	support.expect(tidewell.interact(world.player) and world.player.health == 7, "Tidewell must heal the player through authoritative health rules")
	var hollow := world.living_world_prop("firefly_east")
	var wood_before := world.wood
	var stone_before := world.stone
	world.player.global_position = hollow.global_position
	support.expect(hollow.interact(world.player), "Firefly Hollow must accept controller-style interaction")
	var cache_wood := world._find_pickup("wood")
	var cache_stone := world._find_pickup("stone")
	support.expect(cache_wood != null and cache_stone != null, "Firefly Hollow must reveal both cache pickups in the world")
	cache_wood.collect_immediately()
	cache_stone.collect_immediately()
	await scene_tree.process_frame
	support.expect(world.wood == wood_before + 1 and world.stone == stone_before + 1, "released fireflies must reveal a bounded two-resource cache")
	world.wood = 5
	world.stone = 3
	world.learn_technology("fieldcraft")
	world.learn_technology("combat_training")
	var shrine := world.living_world_prop("whispering_shrine_south")
	world.player.global_position = shrine.global_position
	support.expect(shrine.interact(world.player) and world.active_living_world_guardian_count() == 1, "Whispering Shrine must create one guardian challenge")
	support.expect(not shrine.interact(world.player) and world.active_living_world_guardian_count() == 1, "active shrine guardian must cap challenge stacking")
	var guardian := world._living_world_guardians[shrine.stable_id] as RangedEnemy
	guardian.receive_attack(99)
	await scene_tree.process_frame
	support.expect(world.active_living_world_guardian_count() == 0 and not shrine.external_locked, "defeating the guardian must clean references and unlock the shrine lifecycle")
	world.queue_free()
	await scene_tree.process_frame
