extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world.stone = 2
	world.stone_node.receive_attack(1)
	world.player.global_position = world.workbench.global_position
	world.refresh_all_ui()
	world.try_open_workbench()
	world.hud.workbench_next_button.pressed.emit()
	world.hud.craft_button.grab_focus()
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/stone-whetstone-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
