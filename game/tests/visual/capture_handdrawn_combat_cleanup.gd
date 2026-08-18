extends SceneTree

const WALKING_OUTPUT: String = "res://evidence/handdrawn-island-walking-1280x800.png"
const COMBAT_OUTPUT: String = "res://evidence/handdrawn-island-combat-1280x800.png"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.set_physics_process(false)
	world.player.global_position = Vector2.ZERO
	world.player.facing = Vector2.RIGHT
	world.player.velocity = Vector2.RIGHT * world.player.move_speed
	for _frame: int in 4:
		world.player._update_visual(0.12)
	await _settle()
	if not _save(WALKING_OUTPUT):
		return

	world.player.velocity = Vector2.ZERO
	world.player.request_attack()
	world.player.confirm_hit()
	world.enemy.visible = true
	world.enemy.global_position = Vector2(115, 55)
	world.enemy.target = world.player
	world.enemy._telegraph_remaining = 0.2
	world.enemy.queue_redraw()
	world.ranged_enemy.visible = true
	world.ranged_enemy.global_position = Vector2(-125, 45)
	world.ranged_enemy.target = world.player
	world.ranged_enemy._telegraph_remaining = 0.2
	world.ranged_enemy.queue_redraw()
	await _settle()
	if not _save(COMBAT_OUTPUT):
		return
	quit(0)

func _settle() -> void:
	await process_frame
	RenderingServer.force_draw()
	await process_frame

func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save cleanup evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
