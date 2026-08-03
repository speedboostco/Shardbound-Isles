extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._on_pickup_collected("equipment", EquipmentGenerator.generate(424242))
	world._on_pickup_collected("equipment", EquipmentGenerator.generate(424243))
	world._on_pickup_collected("equipment", BossReward.generate())
	world.equip_selected_item(1)
	world.hud.select_equipment(2)
	world.open_equipment_panel()
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/equipment-inventory-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
