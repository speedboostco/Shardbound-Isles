extends SceneTree

const WORLD_OUTPUT := "res://evidence/grounded-contact-shadows-1280x800.png"
const TREE_OUTPUT := "res://evidence/visual-technology-tree-1280x800.png"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.global_position = Vector2(-90.0, 45.0)
	world.player.facing = Vector2.DOWN
	world.player._update_visual(0.0)
	await _settle()
	if not _save(WORLD_OUTPUT):
		return

	world.technology_tree.restore(["fieldcraft", "combat_training"])
	world.wood = 5
	world.stone = 4
	world.moonleaf = 2
	world.plank = 0
	world._refresh_progression_ui()
	world.open_equipment_panel()
	world.hud.open_technology_page()
	await _settle()
	if not _save(TREE_OUTPUT):
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
		push_error("Could not save grounded technology evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
