extends SceneTree

const DIRECTION_OUTPUT: String = "res://evidence/cohesive-hero-directions-1280x800.png"
const ACTION_OUTPUT: String = "res://evidence/cohesive-hero-actions-1280x800.png"
const COMBAT_OUTPUT: String = "res://evidence/cohesive-world-collision-1280x800.png"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	for enemy: Node in [world.enemy, world.second_slime, world.ranged_enemy, world.elite_ranged_enemy, world.boss]:
		(enemy as CanvasItem).visible = false
	for node: Node in world.get_children():
		if node is ResourceNode or node is WorldPickup:
			(node as CanvasItem).visible = false
	world.hud.visible = false

	var heroes: Array[PlayerCharacter] = [world.player]
	var directions: Array[Dictionary] = [
		{"vector": Vector2.DOWN, "title": "S", "position": Vector2(-330, -105)},
		{"vector": Vector2(-1, 1), "title": "SW", "position": Vector2(-110, -105)},
		{"vector": Vector2.LEFT, "title": "W", "position": Vector2(110, -105)},
		{"vector": Vector2(-1, -1), "title": "NW", "position": Vector2(330, -105)},
		{"vector": Vector2.UP, "title": "N", "position": Vector2(-330, 125)},
		{"vector": Vector2(1, -1), "title": "NE", "position": Vector2(-110, 125)},
		{"vector": Vector2.RIGHT, "title": "E", "position": Vector2(110, 125)},
		{"vector": Vector2(1, 1), "title": "SE", "position": Vector2(330, 125)},
	]
	for index: int in directions.size():
		var hero := world.player if index == 0 else PlayerCharacter.new()
		if index > 0:
			world.add_child(hero)
			heroes.append(hero)
		hero.set_physics_process(false)
		hero.global_position = directions[index].position as Vector2
		hero.facing = directions[index].vector as Vector2
		hero.velocity = Vector2.ZERO
		hero.set_weapon_stats(4, 1.0, "unarmed")
		hero._update_visual(0.58)
		_add_world_label(hero, String(directions[index].title))
	await _settle()
	if not _save(DIRECTION_OUTPUT):
		return
	for index: int in range(1, heroes.size()):
		heroes[index].queue_free()
	await process_frame
	for child: Node in world.player.get_children():
		if child is Label:
			child.queue_free()
	heroes = [world.player]
	var actions: Array[Dictionary] = [
		{"type": "unarmed", "title": "UNARMED", "position": Vector2(-285, -90), "state": "attack"},
		{"type": "melee", "title": "MELEE", "position": Vector2(0, -90), "state": "attack"},
		{"type": "ranged", "title": "RANGED", "position": Vector2(285, -90), "state": "attack"},
		{"type": "magic", "title": "ARCANE", "position": Vector2(-285, 145), "state": "attack"},
		{"type": "unarmed", "title": "IMPACT", "position": Vector2(0, 145), "state": "hit"},
		{"type": "unarmed", "title": "DEFEAT", "position": Vector2(285, 145), "state": "death"},
	]
	for index: int in actions.size():
		var hero := world.player if index == 0 else PlayerCharacter.new()
		if index > 0:
			world.add_child(hero)
			heroes.append(hero)
		hero.set_physics_process(false)
		hero.global_position = actions[index].position as Vector2
		hero.facing = Vector2.RIGHT
		hero.velocity = Vector2.ZERO
		hero.set_weapon_stats(index + 2, 1.0, String(actions[index].type))
		match String(actions[index].state):
			"attack":
				hero.request_attack()
				hero._update_visual(0.31)
			"hit":
				hero._hit_flash_remaining = PlayerCharacter.VISUAL_HIT_DURATION
				hero._update_visual(0.0)
				hero._update_visual(0.18)
			"death":
				hero._death_flash_remaining = PlayerCharacter.VISUAL_DEATH_DURATION
				hero._update_visual(0.0)
				hero._update_visual(0.82)
		_add_world_label(hero, String(actions[index].title))
	await _settle()
	if not _save(ACTION_OUTPUT):
		return

	for index: int in range(1, heroes.size()):
		heroes[index].queue_free()
	await process_frame
	for child: Node in world.player.get_children():
		if child is Label:
			child.queue_free()
	world.player.global_position = Vector2(-75, 35)
	world.hud.visible = true
	world.player.set_weapon_stats(5, 1.2, "ranged")
	world.player.request_attack()
	world.player._update_visual(0.31)
	world.enemy.visible = true
	world.enemy.global_position = Vector2(155, 55)
	world.enemy.state = ChaserEnemy.State.ATTACK
	world.enemy._telegraph_remaining = 0.18
	world.enemy._update_visual(0.18)
	world.ranged_enemy.visible = true
	world.ranged_enemy.global_position = Vector2(310, -115)
	world.ranged_enemy._telegraph_remaining = 0.32
	world.ranged_enemy._update_visual(0.18)
	var equipped := {"id": "customer_bow", "name": "Tideglass Bow", "base_type": "ranged", "damage": 5, "attack_speed": 1.2}
	world.hud.refresh_equipment([], equipped, 0, 5, 1.2, {"weapon": "customer_bow"})
	await _settle()
	if not _save(COMBAT_OUTPUT):
		return
	quit(0)

func _add_world_label(hero: PlayerCharacter, title: String) -> void:
	var label := Label.new()
	label.position = Vector2(-70, 48)
	label.size = Vector2(140, 28)
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("fff0ad"))
	label.add_theme_color_override("font_outline_color", Color("10212a"))
	label.add_theme_constant_override("outline_size", 5)
	label.z_index = 10
	hero.add_child(label)

func _settle() -> void:
	await process_frame
	RenderingServer.force_draw()
	await process_frame

func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save customer-presentation evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
