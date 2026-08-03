extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world.wood = 5
	world.stone = 2
	world.reinforced_heart_crafted = true
	world.runed_whetstone_crafted = true
	world._sync_player_equipment()
	world.player.maximum_health = 12
	world.player.health = 12
	world.build_tidecatcher()
	world.tidecatcher.restore_state(true, 4, world.player)
	world.refresh_all_ui()
	world.save_game("user://visual-evidence-save.json")
	world.open_system_menu()
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/system-menu-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
