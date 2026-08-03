class_name LegendaryPulseTargeting
extends RefCounted

static func select_ids(origin: Vector2, candidates: Array[Dictionary], radius: float, excluded_id: String) -> Array[String]:
	var eligible: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		var candidate_id := String(candidate.get("id", ""))
		if candidate_id.is_empty() or candidate_id == excluded_id or not candidate.get("position") is Vector2:
			continue
		var distance := origin.distance_to(candidate.position as Vector2)
		if distance <= radius:
			eligible.append({"id": candidate_id, "distance": distance})
	eligible.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_distance := float(left.distance)
		var right_distance := float(right.distance)
		return String(left.id) < String(right.id) if is_equal_approx(left_distance, right_distance) else left_distance < right_distance
	)
	var result: Array[String] = []
	for entry: Dictionary in eligible:
		result.append(String(entry.id))
	return result

