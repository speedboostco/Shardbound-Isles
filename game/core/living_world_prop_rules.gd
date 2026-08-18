class_name LivingWorldPropRules
extends RefCounted

const DEFINITIONS: Dictionary = {
	"moonleaf_thicket": {
		"name": "Moonleaf Thicket", "interaction": "FORAGE MOONLEAF",
		"effect": "resource_reward", "resource_id": "moonleaf", "amount": 1, "cooldown": 14.0,
	},
	"tidewell": {
		"name": "Tidewell", "interaction": "DRINK FROM TIDEWELL",
		"effect": "heal", "amount": 3, "cooldown": 22.0,
	},
	"whispering_shrine": {
		"name": "Whispering Shrine", "interaction": "AWAKEN WHISPERING SHRINE",
		"effect": "guardian_challenge", "amount": 2, "cooldown": 36.0,
	},
	"firefly_hollow": {
		"name": "Firefly Hollow", "interaction": "RELEASE FIREFLIES",
		"effect": "resource_cache", "amount": 1, "cooldown": 24.0,
	},
}

const SUPPORTED_EFFECTS: Array[String] = ["resource_reward", "heal", "guardian_challenge", "resource_cache"]

static func definition(prop_id: String) -> Dictionary:
	return (DEFINITIONS.get(prop_id, {}) as Dictionary).duplicate(true)

static func prop_ids() -> Array[String]:
	var result: Array[String] = []
	for prop_id: String in DEFINITIONS:
		result.append(prop_id)
	result.sort()
	return result

static func validate_contract() -> Array[String]:
	var errors: Array[String] = []
	for prop_id: String in DEFINITIONS:
		var value := DEFINITIONS[prop_id] as Dictionary
		for required: String in ["name", "interaction", "effect", "amount", "cooldown"]:
			if not value.has(required):
				errors.append("%s missing %s" % [prop_id, required])
		if String(value.get("effect", "")) not in SUPPORTED_EFFECTS:
			errors.append("%s has unsupported effect" % prop_id)
		if int(value.get("amount", 0)) <= 0:
			errors.append("%s amount must be positive" % prop_id)
		if float(value.get("cooldown", 0.0)) <= 0.0:
			errors.append("%s cooldown must be positive" % prop_id)
	return errors
