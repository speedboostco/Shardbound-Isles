class_name BurningSmelterBehavior
extends RefCounted

var _bus: LegendaryEventBus
var _resolved_deaths: Dictionary = {}

func activate(bus: LegendaryEventBus) -> void:
	_bus = bus
	_bus.enemy_killed.connect(_on_enemy_killed)

func deactivate() -> void:
	if _bus != null and _bus.enemy_killed.is_connected(_on_enemy_killed):
		_bus.enemy_killed.disconnect(_on_enemy_killed)
	_bus = null
	_resolved_deaths.clear()

func _on_enemy_killed(context: Dictionary) -> void:
	var enemy_id := String(context.get("enemy_id", ""))
	if enemy_id.is_empty() or _resolved_deaths.has(enemy_id) or not bool(context.get("burning", false)):
		return
	_resolved_deaths[enemy_id] = true
	var ores: Array[Dictionary] = []
	for value: Variant in context.get("nearby_ores", []):
		if value is Dictionary:
			ores.append((value as Dictionary).duplicate(true))
	ores.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var first_distance := float(first.get("distance", INF))
		var second_distance := float(second.get("distance", INF))
		return first_distance < second_distance if not is_equal_approx(first_distance, second_distance) else String(first.get("id", "")) < String(second.get("id", ""))
	)
	if ores.is_empty():
		_bus.trigger("burning_smelter", {"enemy_id": enemy_id, "smelting_charges": 1, "ore_id": ""})
	else:
		_bus.trigger("burning_smelter", {"enemy_id": enemy_id, "smelting_charges": 0, "ore_id": String(ores[0].get("id", ""))})

