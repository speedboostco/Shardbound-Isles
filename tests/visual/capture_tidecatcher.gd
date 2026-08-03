extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://src/gameplay/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world.reinforced_heart_crafted = true
	world.build_tidecatcher()
	world.tidecatcher.advance_production(6.0)
	world.player.global_position = world.workbench.global_position
	world.try_open_workbench()
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/tidecatcher-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
