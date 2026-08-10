class_name ChainMiningBehavior
extends RefCounted

var _bus: LegendaryEventBus
var _last_tick: int = -1000000
var _maximum_targets: int = 4
var _cooldown_ticks: int = 20
var _radius: float = 150.0
var _power_multiplier: float = 0.5

func configure(parameters: Dictionary) -> void:
	_maximum_targets = maxi(1, int(parameters.get("maximum_targets", 4)))
	_cooldown_ticks = maxi(0, int(parameters.get("cooldown_ticks", 20)))
	_radius = maxf(0.0, float(parameters.get("radius", 150.0)))
	_power_multiplier = clampf(float(parameters.get("power_multiplier", 0.5)), 0.0, 1.0)

func activate(bus: LegendaryEventBus) -> void:
	_bus = bus
	_bus.resource_hit.connect(_on_resource_hit)

func deactivate() -> void:
	if _bus != null and _bus.resource_hit.is_connected(_on_resource_hit):
		_bus.resource_hit.disconnect(_on_resource_hit)
	_bus = null

func _on_resource_hit(context: Dictionary) -> void:
	var tick := int(context.get("tick", 0))
	if int(context.get("chain_depth", 0)) > 0 or tick - _last_tick < _cooldown_ticks:
		return
	var candidates: Array[Dictionary] = []
	for value: Variant in context.get("targets", []):
		if value is Dictionary:
			var candidate := (value as Dictionary).duplicate(true)
			if String(candidate.get("id", "")).is_empty() or float(candidate.get("distance", INF)) > _radius:
				continue
			if candidates.any(func(existing: Dictionary) -> bool: return String(existing.get("id", "")) == String(candidate.get("id", ""))):
				continue
			candidates.append(candidate)
	candidates.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var first_distance := float(first.get("distance", INF))
		var second_distance := float(second.get("distance", INF))
		return first_distance < second_distance if not is_equal_approx(first_distance, second_distance) else String(first.get("id", "")) < String(second.get("id", ""))
	)
	if candidates.is_empty():
		return
	_last_tick = tick
	_bus.trigger("chain_mining", {"targets": candidates.slice(0, mini(_maximum_targets, candidates.size())), "damage": maxi(1, roundi(float(context.get("source_damage", 1)) * _power_multiplier)), "chain_depth": 1, "origin": context.get("origin", Vector2.ZERO)})
