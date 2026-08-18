extends SceneTree

const FIELD_OUTPUT := "res://evidence/survival-foraging-camp-1280x800.png"
const JOURNEY_OUTPUT := "res://evidence/journey-journal-1280x800.png"
const EXPEDITION_OUTPUT := "res://evidence/expedition-night-shelter-1280x800.png"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.global_position = Vector2(-70, -220)
	world.player.facing = Vector2.UP
	world.survival.add_ration()
	world.resource_inventory.set_amount("fiber", 2)
	world.resource_inventory.set_amount("emberberry", 2)
	world._refresh_progression_ui()
	world._refresh_interaction_target()
	await _settle()
	if not _save(FIELD_OUTPUT):
		return
	world.expedition.elapsed_seconds = 190.0
	world.rest_at_field_camp()
	await _settle()
	if not _save(EXPEDITION_OUTPUT):
		return
	world.open_equipment_panel()
	world.hud.open_journey_page()
	await _settle()
	if not _save(JOURNEY_OUTPUT):
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
		push_error("Could not save survival journey evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
