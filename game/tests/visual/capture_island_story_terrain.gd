extends SceneTree

const TERRAIN_OUTPUT := "res://evidence/starting-island-v4-1280x800.png"
const STORY_OUTPUT := "res://evidence/island-story-choice-1280x800.png"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	world._set_combat_processing(false)
	world.player.global_position = Vector2(-72, 40)
	world.player.facing = Vector2.DOWN
	world._refresh_interaction_target()
	await _settle()
	if not _save(TERRAIN_OUTPUT):
		return

	var shard := IslandShardGenerator.generate_for_biome(314159, "forest", 4)
	world.island_shards.append(shard)
	world._refresh_island_ui()
	world.player.global_position = Vector2.ZERO
	if not world.install_selected_shard(0, "east"):
		push_error("Could not install visual story shard")
		quit(1)
		return
	world.island_story.accept()
	world.island_story.record("survey_site", 2, "visual_survey")
	world._sync_island_story()
	world.player.global_position = world.island_slot.global_position + Vector2(-52, 36)
	world.open_island_story()
	await _settle()
	if not _save(STORY_OUTPUT):
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
		push_error("Could not save island-story evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
