extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var art_scene := (load("res://game/content/art_validation.tscn") as PackedScene).instantiate()
	root.add_child(art_scene)
	await _settle(5)
	if not _save("res://evidence/tasks-31-45-art-validation-1280x800.png"):
		return
	art_scene.queue_free()
	await process_frame

	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.facing = Vector2.DOWN
	world.player._update_visual(0.0)
	await _settle(6)
	if not _save("res://evidence/tasks-31-45-core-forest-loop-1280x800.png"):
		return

	for index: int in 5:
		var enemy := ChaserEnemy.new()
		enemy.position = Vector2(-170 + index * 75, 105 + (index % 2) * 55)
		enemy.target = world.player
		world.add_child(enemy)
		enemy.set_physics_process(false)
	for index: int in 18:
		var rarity: String = ["common", "magic", "rare", "epic", "legendary"][index % 5]
		var item := LootGenerator.generate(61000 + index, "visual_foundation", 12 + index, "bow" if index % 2 == 0 else "sword", rarity)
		world._spawn_pickup(Vector2(-250 + (index % 9) * 60, 230 + (index / 9) * 48), "equipment", item)
	for index: int in 12:
		world._spawn_gameplay_vfx(Vector2(-220 + index * 42, 120 + (index % 3) * 28), "critical_hit" if index % 5 == 0 else "normal_hit")
	await _settle(2)
	if not _save("res://evidence/tasks-31-45-dense-combat-loot-1280x800.png"):
		return
	_clear_vfx(world)
	for pickup_value: Node in world.get_children():
		if pickup_value is WorldPickup:
			pickup_value.queue_free()
	await process_frame

	world.hud.set_encounter_feedback("")
	world.legendary_manager.sync(["chain_mining"])
	var chain_targets: Array[Dictionary] = []
	for candidate: Node in world.get_tree().get_nodes_in_group("attackable"):
		if candidate is Node2D and chain_targets.size() < 4:
			chain_targets.append({"id": str(candidate.get_instance_id()), "distance": 40.0 + chain_targets.size() * 20.0})
	world.legendary_event_bus.emit_resource_hit({"tick": 100, "source_damage": 2, "origin": Vector2.ZERO, "targets": chain_targets})
	await _settle(2)
	if not _save("res://evidence/tasks-31-45-chain-mining-1280x800.png"):
		return
	_clear_vfx(world)
	world.hud.set_encounter_feedback("")
	world.legendary_manager.sync(["burning_smelter"])
	world.legendary_event_bus.emit_enemy_killed({"enemy_id": "capture_burning_enemy", "burning": true, "nearby_ores": [], "position": Vector2.ZERO})
	await _settle(2)
	if not _save("res://evidence/tasks-31-45-burning-smelter-1280x800.png"):
		return
	_clear_vfx(world)
	world.hud.set_encounter_feedback("")
	world.legendary_manager.sync(["living_arrows"])
	for index: int in 100:
		world.legendary_event_bus.emit_hit({"weapon_type": "bow", "seed": 314159, "attack_index": index, "position": Vector2(-90 + (index % 3) * 90, 80)})
	await _settle(2)
	if not _save("res://evidence/tasks-31-45-living-arrows-1280x800.png"):
		return

	var equipped := LootGenerator.generate(62001, "visual_foundation", 24, "bow", "rare")
	var candidate := LootGenerator.generate(62002, "visual_foundation", 46, "bow", "legendary")
	candidate.name = "Verdant Oathbow of the Living Archipelago"
	candidate.legendary_effects = ["living_arrows"]
	candidate.legendary_affix_id = "living_arrows"
	world._on_pickup_collected("equipment", equipped)
	world._on_pickup_collected("equipment", candidate)
	world.equip_selected_item(world.equipment_inventory.items.size() - 2)
	world.open_equipment_panel()
	world.hud.select_equipment(world.equipment_inventory.items.size() - 1)
	await _settle(5)
	if not _save("res://evidence/tasks-31-45-equipment-comparison-1280x800.png"):
		return
	world.hud.salvage_button.pressed.emit()
	await _settle(3)
	if not _save("res://evidence/tasks-31-45-salvage-confirmation-1280x800.png"):
		return
	quit(0)

func _clear_vfx(world: Node) -> void:
	for visual: Node in world.get_tree().get_nodes_in_group("gameplay_vfx"):
		if world.is_ancestor_of(visual):
			visual.queue_free()

func _settle(frames: int) -> void:
	for _frame: int in frames:
		await process_frame
	RenderingServer.force_draw()
	await process_frame

func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save visual foundation evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
