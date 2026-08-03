class_name InteractionSelector
extends RefCounted

static func select(origin: Vector2, candidates: Array[Dictionary], maximum_distance: float) -> Dictionary:
	var selected: Dictionary = {}
	var selected_distance := INF
	var selected_id := ""
	for candidate: Dictionary in candidates:
		if not bool(candidate.get("available", false)) or not candidate.get("position") is Vector2:
			continue
		var distance := origin.distance_to(candidate.get("position") as Vector2)
		if distance > maximum_distance:
			continue
		var candidate_id := String(candidate.get("id", ""))
		if distance < selected_distance - 0.001 or (is_equal_approx(distance, selected_distance) and candidate_id < selected_id):
			selected = candidate
			selected_distance = distance
			selected_id = candidate_id
	return selected
