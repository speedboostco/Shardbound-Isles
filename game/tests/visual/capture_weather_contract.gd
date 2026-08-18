extends SceneTree

const OFFER_OUTPUT := "res://evidence/wayfinder-contract-offer-1280x800.png"
const EVENT_OUTPUT := "res://evidence/fog-wisp-contract-1280x800.png"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	root.add_child(world)
	await process_frame
	for day: int in 64:
		world.expedition.elapsed_seconds = day * ExpeditionCycle.DAY_LENGTH_SECONDS + 72.0
		if world.expedition.weather(world.current_biome()) == "fog":
			break
	world._apply_expedition_effects()
	world._set_combat_processing(false)
	world.player.global_position = Vector2(-120, -85)
	world._on_resident_spoken("mira", "MIRA", "The fog has revealed a route.")
	await _settle()
	if not _save(OFFER_OUTPUT):
		return
	world.accept_expedition_contract()
	var event: Variant = world._expedition_events.values()[0]
	world.player.global_position = event.global_position + Vector2(0, 72)
	world._refresh_interaction_target()
	await _settle()
	if not _save(EVENT_OUTPUT):
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
		push_error("Could not save weather contract evidence %s: %s" % [path, error_string(error)])
		quit(1)
		return false
	print("VISUAL_EVIDENCE %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true
