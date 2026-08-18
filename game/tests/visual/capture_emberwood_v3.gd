extends SceneTree

const OUTPUT_PREFIX: String = "res://evidence/emberwood-v3"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.global_position = Vector2(-35, 15)
	world.player.facing = Vector2.RIGHT
	world.player.request_attack()
	world.player._update_visual(0.06)
	world.enemy.global_position = Vector2(-240, 95)
	world.enemy.state = ChaserEnemy.State.ATTACK
	world.enemy._telegraph_remaining = 0.18
	world.enemy._update_visual(0.08)
	world.ranged_enemy.global_position = Vector2(205, -100)
	world.ranged_enemy._telegraph_remaining = 0.38
	world.ranged_enemy._update_visual(0.22)
	world.tree.receive_attack(1)
	world.player.global_position = world.workbench.global_position + Vector2(-85, 0)
	world._refresh_interaction_target()
	await _settle(3)
	if not _save("%s-exploration-1280x800.png" % OUTPUT_PREFIX):
		return

	for definition: Dictionary in [
		{"seed": 61801, "base": "sword", "rarity": "magic"},
		{"seed": 61802, "base": "bow", "rarity": "rare"},
		{"seed": 61803, "base": "wand", "rarity": "epic"},
		{"seed": 61804, "base": "iron_helmet", "rarity": "rare"},
		{"seed": 61805, "base": "coral_ring", "rarity": "legendary"},
	]:
		world._on_pickup_collected("equipment", LootGenerator.generate(int(definition.seed), "emberwood_v3", 18, String(definition.base), String(definition.rarity)))
	world.open_equipment_panel()
	world.hud.select_equipment(4)
	await _settle(4)
	if not _save("%s-equipment-1280x800.png" % OUTPUT_PREFIX):
		return
	world.close_equipment_panel()
	var structure_showcase := Node2D.new()
	structure_showcase.name = "StructureShowcase"
	world.add_child(structure_showcase)
	for definition: Dictionary in [
		{"id": "lumber_mill", "position": Vector2(-260, 115)},
		{"id": "collector", "position": Vector2(-80, 115)},
		{"id": "shared_storage", "position": Vector2(100, 115)},
	]:
		var building := BaseBuildingVisual.new()
		structure_showcase.add_child(building)
		building.global_position = definition.position as Vector2
		building.configure(String(definition.id))
	world.tidecatcher.global_position = Vector2(280, 115)
	world.tidecatcher.activate(world.player)
	world.rift_portal.global_position = Vector2(330, -105)
	world.rift_portal.unlock()
	world.player.global_position = Vector2.ZERO
	await _settle(4)
	if not _save("%s-structures-1280x800.png" % OUTPUT_PREFIX):
		return
	structure_showcase.queue_free()
	world.tidecatcher.visible = false
	world.rift_portal.visible = false

	for combatant: Node2D in [world.enemy, world.second_slime, world.ranged_enemy, world.elite_ranged_enemy]:
		combatant.visible = false
	for prop: Node2D in [world.tree, world.stone_node, world.workbench]:
		prop.visible = false
	world.boss.global_position = Vector2(150, 10)
	world.boss.activate(world.player)
	world.boss._telegraph_remaining = 0.45
	world.boss._update_visual(0.24)
	var kinds: Array[String] = ["normal_hit", "critical_hit", "gather_hit", "death", "pickup", "reward"]
	for index: int in kinds.size():
		var visual := world._spawn_gameplay_vfx(Vector2(-300 + index * 105, 95), kinds[index])
		visual.set_process(false)
		visual.lifetime = visual.duration * 0.48
	await _settle(3)
	if not _save("%s-boss-vfx-1280x800.png" % OUTPUT_PREFIX):
		return

	world.boss.visible = false
	world._on_pickup_collected("island_shard", IslandShardGenerator.generate_for_biome(314159, "forest", 12))
	world.install_selected_shard(0, "east")
	world.player.global_position = Vector2(250, 30)
	await _settle(3)
	if not _save("%s-island-1280x800.png" % OUTPUT_PREFIX):
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
		push_error("Could not save Emberwood v3 visual evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
