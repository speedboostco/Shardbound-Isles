class_name LegendaryBehaviorManager
extends RefCounted

var _bus: LegendaryEventBus
var _instances: Array[Variant] = []
var _ids: Array[String] = []

func _init(bus: LegendaryEventBus) -> void:
	_bus = bus

func sync(effect_ids: Array) -> bool:
	clear()
	for effect_value: Variant in effect_ids:
		var effect_id := String(effect_value)
		var instance: Variant = LegendaryBehaviorRegistry.create(effect_id)
		if instance == null:
			clear()
			return false
		instance.activate(_bus)
		_instances.append(instance)
		_ids.append(effect_id)
	return true

func clear() -> void:
	for instance: Variant in _instances:
		instance.deactivate()
	_instances.clear()
	_ids.clear()

func active_ids() -> Array[String]:
	return _ids.duplicate()
