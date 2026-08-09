extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._automation_timer.stop()
	world._set_combat_processing(false)
	world.base_placement.begin_preview("lumber_mill", "west")
	world.base_placement.commit(Vector2i(999, 999))
	world.base_placement.begin_preview("collector", "east")
	world.base_placement.rotate_preview()
	world.base_placement.commit(Vector2i(999, 999))
	world.shared_storage.add("wood", 5)
	world.shared_storage.add("plank", 3)
	world.lumber_mill_simulation.add_input(6)
	world.lumber_mill_simulation.advance(1.5)
	world._materialize_base_buildings()
	world._refresh_base_ui("AUTOMATION ONLINE — SAFE OUTPUT")
	world.player.global_position = Vector2(0, -250)
	for _frame: int in range(30):
		await process_frame
	RenderingServer.force_draw()
	var image := root.get_texture().get_image()
	var error := image.save_png("res://evidence/m4-base-flow-1280x800.png")
	if error != OK:
		push_error("Could not save M4 base evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE res://evidence/m4-base-flow-1280x800.png %dx%d" % [image.get_width(), image.get_height()])
	quit(0)

