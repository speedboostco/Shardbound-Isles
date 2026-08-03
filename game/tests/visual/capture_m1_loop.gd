extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.resource_inventory.set_amount("wood", 3)
	world.resource_inventory.set_amount("stone", 2)
	world._on_pickup_collected("equipment", EquipmentGenerator.generate(424242))
	world.equip_selected_item(0)
	world.player.global_position = world.workbench.global_position + Vector2(60, 0)
	world._on_player_moved(world.player.global_position)
	for frame: int in 12:
		await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/m1-first-playable-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save M1 visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
