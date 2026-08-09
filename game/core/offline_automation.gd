class_name OfflineAutomation
extends RefCounted

const MillScript := preload("res://game/core/lumber_mill_simulation.gd")

const MAX_CATCH_UP_SECONDS: float = 14400.0

static func safe_elapsed(saved_unix: int, current_unix: int) -> float:
	return clampf(float(current_unix - saved_unix), 0.0, MAX_CATCH_UP_SECONDS)

static func simulate_mill(mill: RefCounted, storage: RefCounted, elapsed_seconds: float) -> Dictionary:
	var elapsed := clampf(elapsed_seconds, 0.0, MAX_CATCH_UP_SECONDS)
	var moved_input: int = storage.remove("wood", MillScript.INPUT_CAPACITY - mill.input_wood)
	mill.add_input(moved_input)
	var production: Dictionary = mill.advance(elapsed)
	var output: int = mill.take_output(storage.free_space())
	var accepted: Dictionary = storage.add("plank", output)
	if int(accepted.remainder) > 0:
		mill.output_planks += int(accepted.remainder)
		mill.blocked_output = true
	return {"elapsed": elapsed, "wood_routed": moved_input, "cycles": int(production.cycles), "planks_routed": int(accepted.accepted), "blocked": mill.blocked_output}
