class_name ChainMiningBehavior
extends RefCounted

const MAX_TARGETS: int = 4
const COOLDOWN_TICKS: int = 20
var _bus: LegendaryEventBus
var _last_tick: int = -1000000

func activate(bus: LegendaryEventBus) -> void:
	_bus = bus
	_bus.resource_hit.connect(_on_resource_hit)

func deactivate() -> void:
	if _bus != null and _bus.resource_hit.is_connected(_on_resource_hit):
		_bus.resource_hit.disconnect(_on_resource_hit)
	_bus = null

func _on_resource_hit(context: Dictionary) -> void:
	var tick := int(context.get("tick", 0))
	if int(context.get("chain_depth", 0)) > 0 or tick - _last_tick < COOLDOWN_TICKS:
		return
	var candidates: Array[Dictionary] = []
	for value: Variant in context.get("targets", []):
		if value is Dictionary:
			candidates.append((value as Dictionary).duplicate(true))
	candidates.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var first_distance := float(first.get("distance", INF))
		var second_distance := float(second.get("distance", INF))
		return first_distance < second_distance if not is_equal_approx(first_distance, second_distance) else String(first.get("id", "")) < String(second.get("id", ""))
	)
	if candidates.is_empty():
		return
	_last_tick = tick
	_bus.trigger("chain_mining", {"targets": candidates.slice(0, mini(MAX_TARGETS, candidates.size())), "damage": maxi(1, int(context.get("source_damage", 1)) / 2), "chain_depth": 1})

