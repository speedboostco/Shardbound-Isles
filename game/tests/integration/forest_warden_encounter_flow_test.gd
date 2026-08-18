extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var forest := IslandShardGenerator.generate_for_biome(314159, "forest", 4)
	world.island_shards.append(forest)
	world.player.global_position = Vector2.ZERO
	world.install_selected_shard(0, "east")
	world.island_story.accept()
	world.island_story.record("survey_site", 2, "warden_test_survey")
	world.island_story.choose_branch("restoration")
	world.island_story.record("restoration_site", 2, "warden_test_restore")
	world._sync_island_story()
	await scene_tree.process_frame
	var warden := world._island_story_warden as IslandStoryWarden
	support.expect(is_instance_valid(warden), "forest story climax materializes one Warden encounter")
	warden.set_physics_process(false)
	var materialization := world.get_tree().get_first_node_in_group("island_materialization_vfx") as IslandMaterializationVfx
	support.expect(not world.island_slot.uses_circular_zone_overlay() and not world.island_slot.materialized.uses_circular_zone_overlay() and not world.island_slot.materialized.event_marker.uses_circular_zone_overlay() and is_instance_valid(materialization) and not materialization.uses_circular_overlay() and world.island_slot.materialized.story_climax_active, "installation, island events, and pedestal remove old circular zones while the climax clears ordinary threats")
	support.expect(warden.display_name == "Verdant Warden" and warden.biome == "forest" and warden.elite, "encounter retains stable quest, biome, and elite identity")
	support.expect(warden.remaining_health == 12 and not warden.deals_contact_damage(), "Warden owns a twelve-health combat profile without contact damage")
	support.expect(warden.presentation_asset_path().ends_with("emberwood_forest_warden_v1_atlas.png"), "Forest Warden uses its bespoke atlas instead of Ranger presentation")
	support.expect(VisualAssetLibrary.FOREST_WARDEN_V1_ATLAS.get_size() == Vector2(256, 256) and VisualAssetLibrary.forest_warden_frame_count("attack") == 4, "registered 4x4 atlas exposes a four-frame root-slam clip")
	support.expect(warden.has_audio_layer() and warden.audio_profile() == "forest_warden_wood_rune_v1", "encounter creates one offline authored audio layer")
	support.expect(["windup", "impact", "phase", "hit", "defeat"].all(func(cue: String) -> bool: return warden.audio_cue_is_ready(cue)), "every combat beat has non-empty synchronized PCM data")
	support.expect(world.hud.get_encounter_feedback().contains("STEP SIDEWAYS"), "Tala introduces the root-lane counterplay when the Warden appears")

	world.player.health_component.set_current(world.player.health_component.maximum)
	world.player.global_position = warden.global_position + Vector2(120, 0)
	var health_before_root: int = world.player.health_component.current
	support.expect(warden.begin_attack(ForestWardenPattern.ROOT_ERUPTION) and warden.telegraph_seconds_remaining() >= 0.75, "root eruption begins with the guaranteed dodge window")
	support.expect(warden.animation_state() == AnimationStateRules.IDLE or warden.animation_state() == AnimationStateRules.ATTACK, "root windup resolves through the authored animation state")
	support.expect(not warden.uses_circular_combat_overlay() and warden.current_root_lane().size() == 4, "telegraph is a bounded lane and never a full white circle")
	warden.advance_attack(1.0)
	support.expect(world.player.health_component.current == health_before_root - 2, "remaining inside the root lane applies its exact impact damage")
	support.expect(warden.audio_cue_count() == 2 and warden.last_audio_cue() == "impact", "root windup and impact each emit one synchronized cue")

	warden._physics_process(0.30)
	world.player.global_position = warden.global_position + Vector2(120, 72)
	var health_before_dodge: int = world.player.health_component.current
	support.expect(warden.begin_attack(ForestWardenPattern.ROOT_ERUPTION), "a settled encounter can begin the next authored attack")
	warden.advance_attack(1.0)
	support.expect(world.player.health_component.current == health_before_dodge, "sidestepping beyond the lane is a real safe response")

	warden._physics_process(0.30)
	world.player.global_position = warden.global_position + Vector2(150, 0)
	var volley_capture := {"angles": []}
	warden.volley_requested.connect(func(_origin: Vector2, _direction: Vector2, angles: Array[float], _damage: int) -> void: volley_capture.angles = angles.duplicate())
	support.expect(warden.begin_attack(ForestWardenPattern.THORN_VOLLEY), "aimed thorn volley remains a distinct attack family")
	warden.advance_attack(1.0)
	support.expect((volley_capture.angles as Array).size() == 3, "phase-one thorn attack resolves as a bounded three-shot fan")
	support.expect(_projectile_count(world) == 3, "thorn resolution creates exactly the visible projectiles described by its telegraph")

	warden.receive_attack(6)
	support.expect(warden.phase == 2 and warden.remaining_health == 6 and is_equal_approx(warden.move_speed, 72.0), "half health enters the faster second phase")
	support.expect(world.hud.get_encounter_feedback().contains("ROOTS NOW ERUPT MORE OFTEN"), "Tala reacts once with actionable phase-two guidance")
	support.expect(warden.last_audio_cue() == "phase", "phase transition owns a distinct audio cue")
	warden._physics_process(0.30)
	volley_capture.angles = []
	support.expect(warden.begin_attack(ForestWardenPattern.THORN_VOLLEY) and warden.telegraph_seconds_remaining() < 0.58, "phase two visibly shortens attack cadence while preserving a positive warning")
	warden.advance_attack(1.0)
	support.expect((volley_capture.angles as Array).size() == 5, "phase-two thorn fan increases spatial pressure but remains capped")

	warden.receive_attack(99)
	support.expect(world.island_story.status == "completed" and warden.last_audio_cue() == "defeat", "defeat synchronizes its cue and completes the authoritative story exactly once")
	support.expect(world.hud.get_encounter_feedback().contains("ITS MEMORY IS QUIET"), "Tala confirms the selected restoration outcome after victory")
	await scene_tree.create_timer(0.65).timeout
	support.expect(not is_instance_valid(warden) and not world.has_island_story_warden() and _projectile_count(world) == 0, "defeat cleans the Warden, its audio owner, and every outstanding projectile")
	world.player.global_position = Vector2.ZERO
	support.expect(world.remove_installed_shard("east") and world.world_resident_count() == 2, "island removal remains safe after the bespoke encounter")
	world.queue_free()
	await scene_tree.process_frame

func _projectile_count(world: FirstPlayableWorld) -> int:
	var result := 0
	for child: Node in world.find_children("*", "EnemyProjectile", true, false):
		if not child.is_queued_for_deletion():
			result += 1
	return result
