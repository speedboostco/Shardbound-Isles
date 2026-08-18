extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.facing = Vector2.RIGHT
	world.player.request_attack()
	world.player._update_visual(0.02)
	world.enemy.state = ChaserEnemy.State.ATTACK
	world.enemy._telegraph_remaining = 0.2
	world.enemy._update_visual(0.0)
	world.ranged_enemy._telegraph_remaining = 0.4
	world.ranged_enemy._update_visual(0.0)
	world.tree.receive_attack(1)
	world.player.global_position = world.workbench.global_position + Vector2(-85, 0)
	world._refresh_interaction_target()
	await _settle(2)
	if not _save("res://evidence/tasks-46-60-animation-interaction-1280x800.png"):
		return

	for definition: Dictionary in [
		{"seed": 47001, "base": "sword", "rarity": "magic"},
		{"seed": 47002, "base": "bow", "rarity": "rare"},
		{"seed": 47003, "base": "wand", "rarity": "epic"},
		{"seed": 47004, "base": "iron_helmet", "rarity": "rare"},
		{"seed": 47005, "base": "coral_ring", "rarity": "legendary"},
	]:
		world._on_pickup_collected("equipment", LootGenerator.generate(int(definition.seed), "tasks_46_60", 18, String(definition.base), String(definition.rarity)))
	world.open_equipment_panel()
	world.hud.select_equipment(4)
	await _settle(4)
	if not _save("res://evidence/tasks-46-60-equipment-icons-1280x800.png"):
		return
	world.close_equipment_panel()

	world._on_pickup_collected("island_shard", IslandShardGenerator.generate_for_biome(9001, "forest", 12))
	world.open_island_panel()
	world.hud.select_island_slot("east")
	await _settle(4)
	if not _save("res://evidence/tasks-46-60-shard-inspection-1280x800.png"):
		return
	world.close_island_panel()
	world.install_selected_shard(0, "east")
	world.player.global_position = Vector2(250, 30)
	world._set_combat_processing(false)
	await _settle(2)
	if not _save("res://evidence/tasks-46-60-island-materialization-1280x800.png"):
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
		push_error("Could not save Tasks 46-60 visual evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
