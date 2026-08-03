class_name AttackProfileRules
extends RefCounted

static func select_targets(origin: Vector2, direction: Vector2, candidates: Array[Dictionary], profile: Dictionary) -> Array[String]:
	var attack_range := maxf(0.0, float(profile.get("range", 78.0)))
	var minimum_dot := clampf(float(profile.get("minimum_dot", 0.2)), -1.0, 1.0)
	var eligible: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		if not candidate.get("position") is Vector2:
			continue
		var offset := (candidate.position as Vector2) - origin
		var distance := offset.length()
		if distance <= attack_range and (distance < 1.0 or direction.normalized().dot(offset.normalized()) >= minimum_dot):
			var value := candidate.duplicate(true)
			value["distance"] = distance
			eligible.append(value)
	eligible.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		return float(first.distance) < float(second.distance) if not is_equal_approx(float(first.distance), float(second.distance)) else String(first.get("id", "")) < String(second.get("id", ""))
	)
	if eligible.is_empty():
		return []
	var result: Array[String] = [String(eligible[0].get("id", ""))]
	var splash_radius := maxf(0.0, float(profile.get("splash_radius", 0.0)))
	var maximum_targets := maxi(1, int(profile.get("maximum_targets", 1)))
	if splash_radius > 0.0 and maximum_targets > 1:
		var impact_position := eligible[0].position as Vector2
		var splash: Array[Dictionary] = []
		for candidate: Dictionary in candidates:
			var candidate_id := String(candidate.get("id", ""))
			if candidate_id == result[0] or not candidate.get("position") is Vector2:
				continue
			var distance := impact_position.distance_to(candidate.position as Vector2)
			if distance <= splash_radius:
				var value := candidate.duplicate(true)
				value["splash_distance"] = distance
				splash.append(value)
		splash.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
			return float(first.splash_distance) < float(second.splash_distance) if not is_equal_approx(float(first.splash_distance), float(second.splash_distance)) else String(first.get("id", "")) < String(second.get("id", ""))
		)
		for candidate: Dictionary in splash:
			if result.size() >= maximum_targets:
				break
			result.append(String(candidate.get("id", "")))
	return result

