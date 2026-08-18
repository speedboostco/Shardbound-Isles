extends RefCounted

func run(support: TestSupport) -> void:
	var ids := LivingWorldPropRules.prop_ids()
	support.expect(ids == ["firefly_hollow", "moonleaf_thicket", "tidewell", "whispering_shrine"], "living-world prop IDs must be stable and complete")
	support.expect(LivingWorldPropRules.validate_contract().is_empty(), "living-world definitions must validate")
	support.expect(String(LivingWorldPropRules.definition("moonleaf_thicket").effect) == "resource_reward", "Moonleaf must provide a resource interaction")
	support.expect(String(LivingWorldPropRules.definition("tidewell").effect) == "heal", "Tidewell must provide healing")
	support.expect(String(LivingWorldPropRules.definition("whispering_shrine").effect) == "guardian_challenge", "shrine must provide a combat challenge")
	support.expect(String(LivingWorldPropRules.definition("firefly_hollow").effect) == "resource_cache", "Firefly Hollow must reveal resources")
	support.expect(VisualAssetLibrary.living_world_texture("moonleaf_thicket", 2).region.position == Vector2(128, 0), "Moonleaf active state must map to its authored atlas cell")
	support.expect(VisualAssetLibrary.living_world_texture("tidewell", 3).region.position == Vector2(192, 64), "Tidewell depleted state must map to its authored atlas cell")
	support.expect(VisualAssetLibrary.living_world_texture("whispering_shrine", 2).region.position == Vector2(128, 128), "shrine awakened state must map to its authored atlas cell")
	support.expect(VisualAssetLibrary.living_world_texture("firefly_hollow", 3).region.position == Vector2(192, 192), "Firefly cooldown state must map to its authored atlas cell")
	var first_wave := PresentationMotion.wave(1.25, 0.7, 0.2)
	support.expect(is_equal_approx(first_wave, PresentationMotion.wave(1.25, 0.7, 0.2)), "presentation motion must be deterministic")
	var bounded := true
	for index: int in 1000:
		bounded = bounded and absf(PresentationMotion.wave(float(index) / 60.0, 2.1, 0.37)) <= 1.00001
	support.expect(bounded, "presentation waves must stay bounded")
	support.expect(PresentationMotion.response_alpha(1.0 / 60.0, 18.0) > 0.0 and PresentationMotion.response_alpha(1.0 / 60.0, 18.0) < 1.0, "presentation response must ease instead of snapping")
	var slot := IslandSlot.new()
	support.expect(not slot.uses_plus_marker(), "island slots must not use the reported plus marker")
	slot.free()
	support.expect(VisualAssetLibrary.handdrawn_terrain_region("grass") == Rect2(0, 0, 16, 16) and VisualAssetLibrary.handdrawn_terrain_region("path_cross") == Rect2(80, 16, 16, 16) and VisualAssetLibrary.HANDDRAWN_DECO_ATLAS.get_size() == Vector2(432, 1040), "cohesive terrain and decoration atlas must use stable authored Puny World regions")
	var combatants: Array[Node] = [PlayerCharacter.new(), ChaserEnemy.new(), RangedEnemy.new(), AbyssalWarden.new()]
	support.expect(combatants.all(func(combatant: Node) -> bool: return not bool(combatant.call("uses_circular_combat_overlay"))), "player and enemy combat presentation must not use circular overlays")
	for combatant: Node in combatants:
		combatant.free()
	var actor_clips_valid := true
	for actor_definition: Dictionary in [{"id": "slime", "elite": false}, {"id": "ranger", "elite": false}, {"id": "ranger", "elite": true}, {"id": "boss", "elite": false}]:
		for state_name: String in ["idle", "move", "attack"]:
			var expected_frames := 4 if state_name == "attack" else 2
			actor_clips_valid = actor_clips_valid and VisualAssetLibrary.animation_frame_count(String(actor_definition.id), state_name, "south", bool(actor_definition.elite)) == expected_frames
			for frame: int in expected_frames:
				var texture := VisualAssetLibrary.animation_texture(String(actor_definition.id), state_name, "south", frame, bool(actor_definition.elite))
				actor_clips_valid = actor_clips_valid and texture.region.size == Vector2(32, 32) and texture.get_image().get_used_rect().has_area()
	support.expect(actor_clips_valid, "all Puny enemy roles must expose complete non-blank 32px idle, move, and attack clips")
	var hero_clips_valid := true
	for actor_id: String in ["hero_unarmed", "hero_sword", "hero_bow", "hero_wand"]:
		for direction: String in FacingRules.DIRECTIONS:
			for state_name: String in AnimationStateRules.STATES:
				var frame_count := VisualAssetLibrary.animation_frame_count(actor_id, state_name, direction)
				hero_clips_valid = hero_clips_valid and frame_count >= 1
				for frame: int in frame_count:
					var texture := VisualAssetLibrary.animation_texture(actor_id, state_name, direction, frame)
					hero_clips_valid = hero_clips_valid and texture.region.size == Vector2(32, 32) and texture.get_image().get_used_rect().has_area()
	support.expect(hero_clips_valid, "the cohesive hero must expose non-blank idle, move, weapon, hit, and death clips in all eight directions")
