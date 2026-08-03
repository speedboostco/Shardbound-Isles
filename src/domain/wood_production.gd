class_name WoodProduction
extends RefCounted

const INTERVAL_SECONDS: float = 2.0
const STORAGE_CAPACITY: int = 6

var stored_wood: int = 0
var _elapsed: float = 0.0
var _interval_multiplier: float = 1.0

func advance(delta_seconds: float) -> int:
	if delta_seconds <= 0.0 or stored_wood >= STORAGE_CAPACITY:
		return 0
	_elapsed += delta_seconds
	var produced := 0
	var effective_interval := INTERVAL_SECONDS * _interval_multiplier
	while _elapsed + 0.000001 >= effective_interval and stored_wood < STORAGE_CAPACITY:
		_elapsed -= effective_interval
		stored_wood += 1
		produced += 1
	if stored_wood >= STORAGE_CAPACITY:
		_elapsed = 0.0
	return produced

func collect() -> int:
	var amount := stored_wood
	stored_wood = 0
	return amount

func restore(stored: int) -> void:
	stored_wood = clampi(stored, 0, STORAGE_CAPACITY)
	_elapsed = 0.0

func set_interval_multiplier(value: float) -> void:
	_interval_multiplier = clampf(value, 0.1, 10.0)

func interval_multiplier() -> float:
	return _interval_multiplier
