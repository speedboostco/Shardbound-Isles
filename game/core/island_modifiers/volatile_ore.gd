extends RefCounted

func effects(context: Dictionary) -> Dictionary:
	return {"ore_explosion_damage": 2 + int(context.get("level", 1)) / 10, "ore_explosion_radius": 76.0}
