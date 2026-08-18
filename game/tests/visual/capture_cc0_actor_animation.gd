extends SceneTree

const OUTPUT_PREFIX: String = "res://evidence/cc0-actors"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	for child: Node in world.get_children():
		if child is ResourceNode or child is LivingWorldProp or child is IslandSlot or child is Workbench or child is Tidecatcher or child is RiftPortal:
			(child as CanvasItem).visible = false
	world.second_slime.visible = false
	world.player.set_physics_process(false)
	world.player.global_position = Vector2.ZERO
	world.enemy.global_position = Vector2(-210, 115)
	world.ranged_enemy.global_position = Vector2(-205, -105)
	world.elite_ranged_enemy.global_position = Vector2(205, -105)
	world.boss.global_position = Vector2(205, 135)
	world.boss.activate(world.player)
	world.boss.set_physics_process(false)
	_set_idle(world)
	await _settle()
	if not _save("%s-idle-1280x800.png" % OUTPUT_PREFIX):
		return

	world.player.velocity = Vector2.RIGHT * world.player.move_speed
	world.enemy.state = ChaserEnemy.State.CHASE
	world.enemy.velocity = Vector2.RIGHT * world.enemy.move_speed
	world.ranged_enemy.velocity = Vector2.LEFT * world.ranged_enemy.move_speed
	world.elite_ranged_enemy.velocity = Vector2.RIGHT * world.elite_ranged_enemy.move_speed
	world.boss.velocity = Vector2.LEFT * world.boss.move_speed
	_update_all(world, 0.34)
	await _settle()
	if not _save("%s-motion-1280x800.png" % OUTPUT_PREFIX):
		return

	world.player.velocity = Vector2.ZERO
	world.player.request_attack()
	world.player._update_visual(0.31)
	world.enemy.velocity = Vector2.ZERO
	world.enemy.state = ChaserEnemy.State.ATTACK
	world.enemy._telegraph_remaining = 0.2
	world.ranged_enemy.velocity = Vector2.ZERO
	world.ranged_enemy._telegraph_remaining = 0.35
	world.elite_ranged_enemy.velocity = Vector2.ZERO
	world.elite_ranged_enemy._telegraph_remaining = 0.35
	world.boss.velocity = Vector2.ZERO
	world.boss._telegraph_remaining = 0.35
	_update_all(world, 0.21)
	await _settle()
	if not _save("%s-attack-1280x800.png" % OUTPUT_PREFIX):
		return
	quit(0)

func _set_idle(world: FirstPlayableWorld) -> void:
	world.player.velocity = Vector2.ZERO
	world.enemy.state = ChaserEnemy.State.IDLE
	world.enemy.velocity = Vector2.ZERO
	world.enemy._telegraph_remaining = 0.0
	world.ranged_enemy.velocity = Vector2.ZERO
	world.ranged_enemy._telegraph_remaining = 0.0
	world.elite_ranged_enemy.velocity = Vector2.ZERO
	world.elite_ranged_enemy._telegraph_remaining = 0.0
	world.boss.velocity = Vector2.ZERO
	world.boss._telegraph_remaining = 0.0
	_update_all(world, 0.0)

func _update_all(world: FirstPlayableWorld, delta: float) -> void:
	world.player._update_visual(delta)
	world.enemy._update_visual(delta)
	world.ranged_enemy._update_visual(delta)
	world.elite_ranged_enemy._update_visual(delta)
	world.boss._update_visual(delta)

func _settle() -> void:
	await process_frame
	RenderingServer.force_draw()
	await process_frame

func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save actor evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
