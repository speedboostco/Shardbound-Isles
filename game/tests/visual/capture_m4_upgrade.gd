extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._automation_timer.stop()
	world._set_combat_processing(false)
	world.reinforced_heart_crafted = true
	var item: Dictionary = EquipmentGenerator.generate(424242)
	world._on_pickup_collected("equipment", item)
	world.equip_selected_item(world.equipment.size() - 1)
	world.equipment_inventory.scrap = 2
	world.player.global_position = world.workbench.global_position
	world.refresh_all_ui()
	world.try_open_workbench()
	world.hud.upgrade_button.pressed.emit()
	world.hud.upgrade_button.grab_focus()
	for _frame: int in range(30):
		await process_frame
	RenderingServer.force_draw()
	var image := root.get_texture().get_image()
	var error := image.save_png("res://evidence/m4-upgrade-confirm-1280x800.png")
	if error != OK:
		push_error("Could not save M4 upgrade evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE res://evidence/m4-upgrade-confirm-1280x800.png %dx%d" % [image.get_width(), image.get_height()])
	quit(0)
