extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	var current := LootGenerator.generate(120001, "visual", 18, "bow", "rare")
	var candidate := LootGenerator.generate(120002, "visual", 32, "bow", "legendary")
	candidate["legendary_effects"] = ["living_arrows"]
	candidate["legendary_affix_id"] = "living_arrows"
	candidate["legendary_affix_name"] = "Living Arrows"
	candidate["legendary_affix_description"] = String(LegendaryBehaviorRegistry.definition("living_arrows").description)
	world._on_pickup_collected("equipment", current)
	world._on_pickup_collected("equipment", candidate)
	world.equip_selected_item(0)
	world.open_equipment_panel()
	world.hud.select_equipment(1)
	for _frame: int in 12:
		await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/m2-loot-tooltip-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save M2 visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
