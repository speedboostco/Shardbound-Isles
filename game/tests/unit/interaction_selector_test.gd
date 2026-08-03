extends RefCounted

const SCRIPT_PATH: String = "res://game/core/interaction_selector.gd"

func run(support: TestSupport) -> void:
	var selector: Variant = load(SCRIPT_PATH)
	support.expect(selector != null, "interaction selector must load")
	if selector == null:
		return
	var candidates: Array[Dictionary] = [
		{"id": "far", "position": Vector2(80, 0), "available": true, "label": "Far"},
		{"id": "near", "position": Vector2(20, 0), "available": true, "label": "Near"},
	]
	var selected: Dictionary = selector.select(Vector2.ZERO, candidates, 100.0)
	support.expect(selected.get("id") == "near", "nearest available interaction must be selected")
	candidates[1]["available"] = false
	support.expect(selector.select(Vector2.ZERO, candidates, 100.0).get("id") == "far", "unavailable interactions must be skipped")
	support.expect(selector.select(Vector2.ZERO, candidates, 50.0).is_empty(), "targets outside interaction range must be rejected")
	var tied: Array[Dictionary] = [
		{"id": "b", "position": Vector2(10, 0), "available": true},
		{"id": "a", "position": Vector2(-10, 0), "available": true},
	]
	support.expect(selector.select(Vector2.ZERO, tied, 20.0).get("id") == "a", "equal-distance interactions must use stable ID tie-breaking")
	candidates[1]["available"] = true
	support.expect(selector.select(Vector2.ZERO, candidates, 100.0).get("label") == "Near", "selection must preserve target presentation data")
