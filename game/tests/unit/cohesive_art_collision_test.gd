extends RefCounted

func run(support: TestSupport) -> void:
	support.expect(VisualAssetLibrary.validate_cohesive_family().is_empty(), "the cohesive Puny actor/world family must satisfy its runtime atlas contract")
	support.expect(VisualAssetLibrary.PUNY_DIRECTION_ROWS == {"south": 0, "south_east": 1, "east": 2, "north_east": 3, "north": 4, "north_west": 5, "west": 6, "south_west": 7} and VisualAssetLibrary.animation_cell("hero_sword", "idle", "east").y == 2 and VisualAssetLibrary.animation_cell("hero_sword", "idle", "west").y == 6, "Puny horizontal facings must map right input to east art and left input to west art")
	var hero_directions_valid := true
	for direction: String in FacingRules.DIRECTIONS:
		for actor_id: String in ["hero_unarmed", "hero_sword", "hero_bow", "hero_wand"]:
			for state_name: String in ["idle", "move", "attack", "hit", "death"]:
				var frame_count := VisualAssetLibrary.animation_frame_count(actor_id, state_name, direction)
				var texture := VisualAssetLibrary.animation_texture(actor_id, state_name, direction, frame_count - 1)
				hero_directions_valid = hero_directions_valid and frame_count >= 1 and texture.region.size == Vector2(32, 32) and texture.get_image().get_used_rect().has_area()
	support.expect(hero_directions_valid, "hero must expose non-blank idle/move/weapon/hit/death frames in all eight authored directions")
	support.expect(VisualAssetLibrary.animation_frame_count("hero_sword", "attack") == 4, "sword equipment must use the complete four-frame sword action")
	support.expect(VisualAssetLibrary.animation_frame_count("hero_bow", "attack") == 4, "ranged equipment must use the complete four-frame bow action")
	support.expect(VisualAssetLibrary.animation_frame_count("hero_wand", "attack") == 4, "magic equipment must use the complete four-frame staff action")
	support.expect(VisualAssetLibrary.animation_frame_count("hero_unarmed", "attack") == 2, "unarmed equipment must retain the authored two-frame throw action")
	support.expect(VisualAssetLibrary.animation_frame_count("hero_sword", "death") == 5 and VisualAssetLibrary.animation_frame_count("hero_sword", "hit") == 1, "hurt and death must retain their authored complete source sequences")
	var enemy_directions_valid := true
	for actor_id: String in ["slime", "ranger", "boss"]:
		for direction: String in FacingRules.DIRECTIONS:
			for state_name: String in ["idle", "move", "attack", "hit", "death"]:
				var texture := VisualAssetLibrary.animation_texture(actor_id, state_name, direction, 0, actor_id == "ranger")
				enemy_directions_valid = enemy_directions_valid and texture.region.size == Vector2(32, 32) and texture.get_image().get_used_rect().has_area()
	support.expect(enemy_directions_valid, "enemy families must use the same eight-direction 32px source grammar")
	support.expect(VisualAssetLibrary.puny_terrain_region("grass") == Rect2(0, 0, 16, 16) and VisualAssetLibrary.puny_terrain_region("path_horizontal") == Rect2(80, 48, 16, 16) and VisualAssetLibrary.puny_terrain_region("path_vertical") == Rect2(48, 16, 16, 16), "cohesive terrain semantics must map to stable Puny World grass and directional paths")
	support.expect(VisualAssetLibrary.world_object_texture("forest_tree").get_image().get_used_rect().has_area(), "solid world trees must use registered non-blank art")
	support.expect(VisualAssetLibrary.world_object_texture("boulder").get_image().get_used_rect().has_area(), "solid boulders must use registered non-blank art")
