class_name LivingArrowsBehavior
extends RefCounted

var _bus: LegendaryEventBus
var _active: Dictionary = {}
var _maximum_active: int = 3
var _proc_chance: float = 0.35
var _lifetime: float = 6.0

func configure(parameters: Dictionary) -> void:
	_maximum_active = maxi(1, int(parameters.get("maximum_active", 3)))
	_proc_chance = clampf(float(parameters.get("proc_chance", 0.35)), 0.0, 1.0)
	_lifetime = maxf(0.1, float(parameters.get("lifetime", 6.0)))

func activate(bus: LegendaryEventBus) -> void:
	_bus = bus
	_bus.hit.connect(_on_hit)
	_bus.temporary_expired.connect(_on_temporary_expired)

func deactivate() -> void:
	if _bus != null:
		if _bus.hit.is_connected(_on_hit):
			_bus.hit.disconnect(_on_hit)
		if _bus.temporary_expired.is_connected(_on_temporary_expired):
			_bus.temporary_expired.disconnect(_on_temporary_expired)
	_bus = null
	_active.clear()

func _on_hit(context: Dictionary) -> void:
	if String(context.get("weapon_type", "")) != "bow" or _active.size() >= _maximum_active:
		return
	var attack_index := int(context.get("attack_index", 0))
	var seed_value := int(context.get("seed", 0)) ^ (attack_index * 104729)
	var rng := SeededRngStreams.from_seed(seed_value)
	if rng.randf() > _proc_chance:
		return
	var plant_id := "living_plant_%d_%d" % [int(context.get("seed", 0)), attack_index]
	if _active.has(plant_id):
		return
	_active[plant_id] = true
	_bus.trigger("living_arrows", {"plant_id": plant_id, "position": context.get("position", Vector2.ZERO), "lifetime": _lifetime})

func _on_temporary_expired(instance_id: String) -> void:
	_active.erase(instance_id)
