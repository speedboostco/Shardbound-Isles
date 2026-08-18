extends SceneTree

const OUTPUT_PREFIX: String = "res://evidence/living-world-polish"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.global_position = Vector2.ZERO
	world.player.facing = Vector2.RIGHT
	world.player._update_visual(0.2)
	world._refresh_interaction_target()
	await _settle(4)
	if not _save("%s-exploration-1280x800.png" % OUTPUT_PREFIX):
		return

	var thicket := world.living_world_prop("moonleaf_west")
	world.player.global_position = thicket.global_position + Vector2(72, 12)
	world.player.facing = Vector2.LEFT
	world._refresh_interaction_target()
	thicket.interact(world.player)
	await _settle(3)
	if not _save("%s-interaction-1280x800.png" % OUTPUT_PREFIX):
		return

	var tidewell := world.living_world_prop("tidewell_north")
	world.player.health_component.set_current(5)
	world.player.global_position = tidewell.global_position
	tidewell.interact(world.player)
	var hollow := world.living_world_prop("firefly_east")
	world.player.global_position = hollow.global_position
	hollow.interact(world.player)
	var shrine := world.living_world_prop("whispering_shrine_south")
	world.player.global_position = shrine.global_position + Vector2(-90, 0)
	shrine.interact(world.player)
	world._refresh_interaction_target()
	await _settle(3)
	if not _save("%s-depth-1280x800.png" % OUTPUT_PREFIX):
		return

	world._living_world_guardians[shrine.stable_id].set_physics_process(false)
	world.player.global_position = Vector2(335, 65)
	world.player.facing = Vector2.RIGHT
	world._refresh_interaction_target()
	await _settle(3)
	if not _save("%s-island-pedestal-1280x800.png" % OUTPUT_PREFIX):
		return

	for child: Node in world.get_children():
		if child is Node2D and child != world.player:
			(child as Node2D).visible = false
	world.player.global_position = Vector2.ZERO
	world.player.facing = Vector2.RIGHT
	world.player._update_visual(0.2)
	await _settle(3)
	if not _save("%s-player-clean-1280x800.png" % OUTPUT_PREFIX):
		return
	quit(0)

func _settle(frames: int) -> void:
	for _frame: int in frames:
		await process_frame
	RenderingServer.force_draw()
	await process_frame

func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save living-world visual evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
