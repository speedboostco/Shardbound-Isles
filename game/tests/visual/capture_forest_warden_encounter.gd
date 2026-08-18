extends SceneTree

const WINDUP_OUTPUT := "res://evidence/forest-warden-windup-1280x800.png"
const ROOT_OUTPUT := "res://evidence/forest-warden-root-eruption-1280x800.png"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	var forest := IslandShardGenerator.generate_for_biome(314159, "forest", 4)
	world.island_shards.append(forest)
	world.player.global_position = Vector2.ZERO
	world.install_selected_shard(0, "east")
	world.island_story.accept()
	world.island_story.record("survey_site", 2, "visual_warden_survey")
	world.island_story.choose_branch("restoration")
	world.island_story.record("restoration_site", 2, "visual_warden_restore")
	world._sync_island_story()
	await process_frame
	var warden := world._island_story_warden as IslandStoryWarden
	warden.set_physics_process(false)
	for materialization: Node in get_nodes_in_group("island_materialization_vfx"):
		materialization.queue_free()
	await process_frame
	world.player.global_position = warden.global_position + Vector2(148, 8)
	world.player.facing = Vector2.LEFT
	warden.begin_attack(ForestWardenPattern.THORN_VOLLEY)
	warden._update_visual(0.28)
	await _settle()
	if not _save(WINDUP_OUTPUT):
		return

	warden._telegraph_remaining = 0.0
	warden._impact_remaining = 0.0
	warden.receive_attack(6)
	warden._hit_flash_remaining = 0.0
	world.player.global_position = warden.global_position + Vector2(142, 74)
	warden.begin_attack(ForestWardenPattern.ROOT_ERUPTION)
	warden._update_visual(0.30)
	await _settle()
	if not _save(ROOT_OUTPUT):
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
		push_error("Could not save Forest Warden evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
