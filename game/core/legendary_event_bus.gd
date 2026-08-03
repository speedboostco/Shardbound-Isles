class_name LegendaryEventBus
extends RefCounted

signal attack(context: Dictionary)
signal enemy_killed(context: Dictionary)
signal resource_hit(context: Dictionary)
signal resource_used(context: Dictionary)
signal temporary_expired(instance_id: String)
signal effect_triggered(effect_id: String, payload: Dictionary)

func emit_attack(context: Dictionary) -> void:
	attack.emit(context.duplicate(true))

func emit_enemy_killed(context: Dictionary) -> void:
	enemy_killed.emit(context.duplicate(true))

func emit_resource_hit(context: Dictionary) -> void:
	resource_hit.emit(context.duplicate(true))

func emit_resource_used(context: Dictionary) -> void:
	resource_used.emit(context.duplicate(true))

func emit_temporary_expired(instance_id: String) -> void:
	temporary_expired.emit(instance_id)

func trigger(effect_id: String, payload: Dictionary) -> void:
	effect_triggered.emit(effect_id, payload.duplicate(true))

