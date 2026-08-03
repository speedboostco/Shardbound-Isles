extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	for shard: Dictionary in [
		IslandShardGenerator.generate_for_biome(106001, "forest", 14),
		IslandShardGenerator.generate_for_biome(106002, "swamp", 14),
		IslandShardGenerator.generate_for_biome(106003, "volcano", 14),
		IslandShardGenerator.generate_for_biome(106004, "settlement", 14),
	]:
		world._on_pickup_collected("island_shard", shard)
	world.install_selected_shard(0, "east")
	world.open_island_panel()
	world.hud.select_island(0)
	world.hud.select_island_slot("north_east")
	for _frame: int in 10:
		await process_frame
	if not _save("res://evidence/m3-shard-preview-1280x800.png"):
		return
	world.close_island_panel()
	world.install_selected_shard(0, "north_east")
	world.install_selected_shard(0, "south_east")
	world.player.global_position = Vector2(520, 20)
	world._set_combat_processing(false)
	for candidate: Node in world.get_tree().get_nodes_in_group("attackable"):
		if candidate is ChaserEnemy or candidate is RangedEnemy:
			candidate.set_physics_process(false)
	for _frame: int in 16:
		await process_frame
	if not _save("res://evidence/m3-physical-archipelago-1280x800.png"):
		return
	quit(0)

func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save M3 visual evidence: %s" % error_string(error))
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
