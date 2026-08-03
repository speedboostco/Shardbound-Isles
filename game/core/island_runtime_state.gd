class_name IslandRuntimeState
extends RefCounted

const RUNTIME_VERSION: int = 1

static func create(definition: Dictionary) -> Dictionary:
	return {
		"runtime_version": RUNTIME_VERSION,
		"definition": definition.duplicate(true),
		"destroyed_resources": [],
		"collected_rewards": [],
		"encounter_completed": false,
	}

static func progress_only(state: Dictionary) -> Dictionary:
	return {
		"runtime_version": int(state.get("runtime_version", RUNTIME_VERSION)),
		"destroyed_resources": (state.get("destroyed_resources", []) as Array).duplicate(),
		"collected_rewards": (state.get("collected_rewards", []) as Array).duplicate(),
		"encounter_completed": bool(state.get("encounter_completed", false)),
	}

static func validate_dictionary(state: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if int(state.get("runtime_version", -1)) != RUNTIME_VERSION:
		errors.append("unsupported island runtime version")
	if not state.get("destroyed_resources") is Array:
		errors.append("destroyed_resources must be an array")
	if not state.get("collected_rewards") is Array:
		errors.append("collected_rewards must be an array")
	if not state.get("encounter_completed") is bool:
		errors.append("encounter_completed must be boolean")
	for key: String in ["destroyed_resources", "collected_rewards"]:
		if state.get(key) is Array:
			for value: Variant in state[key]:
				if not value is String:
					errors.append("%s entries must be stable string IDs" % key)
	return errors
