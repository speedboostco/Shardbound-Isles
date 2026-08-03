extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://src/gameplay/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.global_position = Vector2(-430, 180)
	world._on_pickup_collected("equipment", BossReward.generate())
	world.equip_selected_item(0)
	world.enemy.global_position = world.player.global_position + Vector2(42, 0)
	world.ranged_enemy.global_position = world.player.global_position + Vector2(0, -72)
	world.elite_ranged_enemy.global_position = world.player.global_position + Vector2(190, 0)
	world._on_attack_requested(world.player.global_position, Vector2.RIGHT)
	for child: Node in world.get_children():
		if child is LegendaryPulseVisual:
			(child as LegendaryPulseVisual).remaining = LegendaryPulseVisual.DURATION * 0.55
			child.queue_redraw()
	world.open_equipment_panel()
	await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/legendary-pulse-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
