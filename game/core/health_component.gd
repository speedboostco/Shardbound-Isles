class_name HealthComponent
extends RefCounted

signal changed(current: int, maximum: int)
signal damaged(amount: int, current: int)
signal healed(amount: int, current: int)
signal died

var maximum: int
var current: int
var invulnerability_seconds: float
var _invulnerability_remaining: float = 0.0
var _dead: bool = false

func _init(maximum_value: int = 1, invulnerability_value: float = 0.0) -> void:
	maximum = maxi(1, maximum_value)
	current = maximum
	invulnerability_seconds = maxf(0.0, invulnerability_value)

func advance(delta: float) -> void:
	_invulnerability_remaining = maxf(0.0, _invulnerability_remaining - maxf(0.0, delta))

func damage(amount: int) -> bool:
	if amount <= 0 or _dead or is_invulnerable():
		return false
	var applied := mini(amount, current)
	current -= applied
	_invulnerability_remaining = invulnerability_seconds
	damaged.emit(applied, current)
	changed.emit(current, maximum)
	if current == 0:
		_dead = true
		died.emit()
	return true

func heal(amount: int) -> bool:
	if amount <= 0 or _dead or current >= maximum:
		return false
	var previous := current
	current = mini(maximum, current + amount)
	healed.emit(current - previous, current)
	changed.emit(current, maximum)
	return true

func set_maximum(value: int, preserve_missing_health: bool = false) -> bool:
	if value <= 0:
		return false
	var missing := maximum - current
	maximum = value
	current = clampi(maximum - missing if preserve_missing_health else current, 0, maximum)
	_dead = current == 0
	changed.emit(current, maximum)
	return true

func set_current(value: int) -> bool:
	if value < 0 or value > maximum:
		return false
	current = value
	_dead = current == 0
	_invulnerability_remaining = 0.0
	changed.emit(current, maximum)
	return true

func revive(health_value: int = -1) -> void:
	_dead = false
	_invulnerability_remaining = 0.0
	current = maximum if health_value < 0 else clampi(health_value, 1, maximum)
	changed.emit(current, maximum)

func is_invulnerable() -> bool:
	return _invulnerability_remaining > 0.0

func is_dead() -> bool:
	return _dead
