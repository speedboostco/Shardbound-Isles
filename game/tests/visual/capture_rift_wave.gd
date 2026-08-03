extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	world._on_boss_defeated(Vector2.ZERO)
	world.player.global_position = world.rift_portal.global_position
	world.try_enter_rift()
	for _wave: int in range(2):
		var current := world.rift_enemies.duplicate()
		for combatant: Node2D in current:
			combatant.receive_attack(999)
	for combatant: Node2D in world.rift_enemies:
		combatant.set_physics_process(false)
		if combatant is RangedEnemy:
			(combatant as RangedEnemy).advance_attack(0.8)
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var output_path := "res://evidence/rift-wave-1280x800.png"
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save visual evidence: %s" % error_string(error))
		quit(1)
		return
	print("VISUAL_EVIDENCE %s %dx%d" % [output_path, image.get_width(), image.get_height()])
	quit(0)
