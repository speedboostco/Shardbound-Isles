class_name CameraRig
extends Camera2D

@export var follow_smoothing_enabled: bool = true
@export var follow_smoothing_speed: float = 7.0
@export var shake_enabled: bool = false
var _shake_strength: float = 0.0
var _shake_remaining: float = 0.0
var _shake_duration: float = 0.0
var _shake_phase: float = 0.0

func _ready() -> void:
	position_smoothing_enabled = follow_smoothing_enabled
	position_smoothing_speed = follow_smoothing_speed
	limit_smoothed = true

func request_shake(strength: float = 5.0, duration: float = 0.16) -> bool:
	if not shake_enabled or strength <= 0.0 or duration <= 0.0:
		return false
	_shake_strength = strength
	_shake_remaining = duration
	_shake_duration = duration
	_shake_phase = 0.0
	return true

func _process(delta: float) -> void:
	if not shake_enabled or _shake_remaining <= 0.0:
		offset = Vector2.ZERO
		return
	_shake_remaining = maxf(0.0, _shake_remaining - delta)
	_shake_phase += delta * 52.0
	var weight := _shake_remaining / _shake_duration
	offset = Vector2(sin(_shake_phase), cos(_shake_phase * 1.37)) * _shake_strength * weight
	if _shake_remaining <= 0.0:
		offset = Vector2.ZERO
