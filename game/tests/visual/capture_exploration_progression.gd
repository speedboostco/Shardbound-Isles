extends SceneTree

const OPENING_OUTPUT := "res://evidence/exploration-opening-1280x800.png"
const INVENTORY_OUTPUT := "res://evidence/inventory-technology-1280x800.png"
const BOW_OUTPUT := "res://evidence/bow-targeting-1280x800.png"
const MAGIC_OUTPUT := "res://evidence/magic-targeting-1280x800.png"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.global_position = Vector2(0, 30)
	await _settle()
	if not _save(OPENING_OUTPUT):
		return

	world.wood = 3
	world.stone = 2
	world.moonleaf = 3
	world._on_pickup_collected("equipment", EquipmentGenerator.generate(424242))
	world.open_equipment_panel()
	await _settle()
	if not _save(INVENTORY_OUTPUT):
		return

	world.close_equipment_panel()
	world.player.global_position = Vector2(-210, 80)
	world.player.facing = Vector2.RIGHT
	world.player.set_weapon_stats(5, 1.2, "ranged", "", {"style": "projectile", "range": 280.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0})
	world._on_attack_requested(world.player.global_position, Vector2.RIGHT)
	await create_timer(0.08).timeout
	await _settle()
	if not _save(BOW_OUTPUT):
		return

	world._clear_player_weapon_effects()
	world.player.set_weapon_stats(5, 1.0, "magic", "", {"style": "arcane_strike", "range": 230.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0})
	world.player._attack_cooldown = 0.0
	world.player.request_attack()
	await create_timer(0.11).timeout
	await _settle()
	if not _save(MAGIC_OUTPUT):
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
		push_error("Could not save progression evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
