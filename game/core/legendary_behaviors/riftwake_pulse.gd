class_name RiftwakePulseBehavior
extends RefCounted

var _bus: LegendaryEventBus

func activate(bus: LegendaryEventBus) -> void:
	_bus = bus
	_bus.attack.connect(_on_attack)

func deactivate() -> void:
	if _bus != null and _bus.attack.is_connected(_on_attack):
		_bus.attack.disconnect(_on_attack)
	_bus = null

func _on_attack(context: Dictionary) -> void:
	_bus.trigger("riftwake_pulse", {"origin": context.get("origin", Vector2.ZERO), "primary_target_id": String(context.get("primary_target_id", ""))})

