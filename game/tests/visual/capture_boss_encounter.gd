extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	world.enemy.receive_attack(99)
	world.ranged_enemy.receive_attack(99)
	world.elite_ranged_enemy.receive_attack(99)
	world.boss.set_physics_process(false)
	world.boss.receive_attack(6)
	world.boss.advance_attack(0.9)
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/boss-encounter-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
