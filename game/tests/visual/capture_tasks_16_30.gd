extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	await _settle()
	if not _save("res://evidence/tasks-16-30-m1-normal-1280x800.png"):
		return
	world.player.take_damage(3)
	await _settle()
	if not _save("res://evidence/tasks-16-30-m1-damaged-1280x800.png"):
		return
	var starter := EquipmentGenerator.generate(424242)
	var pickup := world._spawn_pickup(world.player.global_position + Vector2(150, -100), "equipment", starter)
	await _settle()
	if not _save("res://evidence/tasks-16-30-m1-pickup-1280x800.png"):
		return
	pickup.global_position = world.player.global_position
	pickup.collect_immediately()
	world.equip_selected_item(0)
	await _settle()
	if not _save("res://evidence/tasks-16-30-m1-equipped-1280x800.png"):
		return

	var common := LootGenerator.generate(16030, "visual", 1, "iron_helmet", "common")
	world._on_pickup_collected("equipment", common)
	world.open_equipment_panel()
	world.hud.select_equipment(1)
	await _settle()
	if not _save("res://evidence/tasks-16-30-tooltip-short-empty-slot-1280x800.png"):
		return
	var long_item := LootGenerator.generate(16031, "visual", 60, "bow", "legendary")
	long_item["name"] = "Legendary Tideglass Longbow of the Unending Shardbound Current"
	long_item["legendary_effects"] = ["living_arrows"]
	long_item["legendary_affix_id"] = "living_arrows"
	world._on_pickup_collected("equipment", long_item)
	world.hud.select_equipment(2)
	await _settle()
	if not _save("res://evidence/tasks-16-30-tooltip-long-comparison-1280x800.png"):
		return
	world.hud.salvage_button.pressed.emit()
	await _settle()
	if not _save("res://evidence/tasks-16-30-salvage-confirmation-1280x800.png"):
		return
	quit(0)

func _settle() -> void:
	for _frame: int in 8:
		await process_frame

func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save visual evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
