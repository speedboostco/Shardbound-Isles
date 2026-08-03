class_name LivingArrowsBehavior
extends RefCounted

const MAX_ACTIVE_PLANTS: int = 3
const PROC_CHANCE: float = 0.35
var _bus: LegendaryEventBus
var _active: Dictionary = {}

func activate(bus: LegendaryEventBus) -> void:
	_bus = bus
	_bus.attack.connect(_on_attack)
	_bus.temporary_expired.connect(_on_temporary_expired)

func deactivate() -> void:
	if _bus != null:
		if _bus.attack.is_connected(_on_attack):
			_bus.attack.disconnect(_on_attack)
		if _bus.temporary_expired.is_connected(_on_temporary_expired):
			_bus.temporary_expired.disconnect(_on_temporary_expired)
	_bus = null
	_active.clear()

func _on_attack(context: Dictionary) -> void:
	if String(context.get("weapon_type", "")) != "bow" or _active.size() >= MAX_ACTIVE_PLANTS:
		return
	var attack_index := int(context.get("attack_index", 0))
	var seed_value := int(context.get("seed", 0)) ^ (attack_index * 104729)
	var rng := SeededRngStreams.from_seed(seed_value)
	if rng.randf() > PROC_CHANCE:
		return
	var plant_id := "living_plant_%d_%d" % [int(context.get("seed", 0)), attack_index]
	if _active.has(plant_id):
		return
	_active[plant_id] = true
	_bus.trigger("living_arrows", {"plant_id": plant_id, "position": context.get("impact_position", context.get("origin", Vector2.ZERO)), "lifetime": 6.0})

func _on_temporary_expired(instance_id: String) -> void:
	_active.erase(instance_id)

