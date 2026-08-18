class_name ManaPool
extends RefCounted

signal changed(current: float, maximum: float)
signal spend_failed(required: float, current: float)

var maximum: float
var current: float
var regeneration_per_second: float

func _init(maximum_value: float = 60.0, regeneration_value: float = 6.0) -> void:
	maximum = maxf(1.0, maximum_value)
	current = maximum
	regeneration_per_second = maxf(0.0, regeneration_value)

func spend(amount: float) -> bool:
	if amount <= 0.0:
		return true
	if current + 0.001 < amount:
		spend_failed.emit(amount, current)
		return false
	current = maxf(0.0, current - amount)
	changed.emit(current, maximum)
	return true

func regenerate(delta: float) -> bool:
	if delta <= 0.0 or current >= maximum or regeneration_per_second <= 0.0:
		return false
	current = minf(maximum, current + regeneration_per_second * delta)
	changed.emit(current, maximum)
	return true

func set_maximum(value: float, refill_bonus: bool = true) -> bool:
	if value <= 0.0:
		return false
	var increase := value - maximum
	maximum = value
	current = clampf(current + maxf(0.0, increase) if refill_bonus else current, 0.0, maximum)
	changed.emit(current, maximum)
	return true

func restore(current_value: float, maximum_value: float, regeneration_value: float) -> bool:
	if maximum_value <= 0.0 or current_value < 0.0 or current_value > maximum_value or regeneration_value < 0.0:
		return false
	maximum = maximum_value
	current = current_value
	regeneration_per_second = regeneration_value
	changed.emit(current, maximum)
	return true
