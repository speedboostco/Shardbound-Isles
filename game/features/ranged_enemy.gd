class_name RangedEnemy
extends CharacterBody2D

const HealthComponentScript := preload("res://game/core/health_component.gd")

signal volley_requested(origin: Vector2, direction: Vector2, angles: Array[float], damage: int)
signal defeated(position_value: Vector2, loot_seed: int)

@export var elite: bool = false
@export var move_speed: float = 65.0
@export var loot_seed: int = 424243
var target: Node2D
var health_component: Variant
var remaining_health: int:
	get: return health_component.current if health_component != null else (5 if elite else 3)
var _cooldown_remaining: float = 0.8
var _telegraph_remaining: float = 0.0

func _ready() -> void:
	health_component = HealthComponentScript.new(5 if elite else 3)
	health_component.died.connect(_on_died)
	add_to_group("attackable")
	queue_redraw()

func _physics_process(delta: float) -> void:
	advance_attack(delta)
	if not is_instance_valid(target) or is_telegraphing():
		velocity = Vector2.ZERO
		return
	var distance := global_position.distance_to(target.global_position)
	if distance < 185.0:
		velocity = target.global_position.direction_to(global_position) * move_speed
	elif distance > 280.0:
		velocity = global_position.direction_to(target.global_position) * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func advance_attack(delta: float) -> void:
	if not is_instance_valid(target) or delta <= 0.0:
		return
	if _telegraph_remaining > 0.0:
		_telegraph_remaining = maxf(0.0, _telegraph_remaining - delta)
		if _telegraph_remaining <= 0.0:
			volley_requested.emit(global_position, global_position.direction_to(target.global_position), RangedAttackPattern.angles(elite), 2 if elite else 1)
			_cooldown_remaining = RangedAttackPattern.COOLDOWN_SECONDS
		queue_redraw()
		return
	_cooldown_remaining -= delta
	if _cooldown_remaining <= 0.0:
		_telegraph_remaining = RangedAttackPattern.TELEGRAPH_SECONDS
		velocity = Vector2.ZERO
		queue_redraw()

func is_telegraphing() -> bool:
	return _telegraph_remaining > 0.0

func receive_attack(damage: int) -> void:
	if health_component.damage(damage):
		queue_redraw()

func _on_died() -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)
	remove_from_group("attackable")
	defeated.emit(global_position, loot_seed)
	queue_free()

func _draw() -> void:
	var body_color := Color("9c65e8") if elite else Color("e19b4a")
	draw_circle(Vector2.ZERO, 22.0 if elite else 18.0, body_color)
	draw_circle(Vector2(-6, -3), 3.0, Color.WHITE)
	draw_circle(Vector2(6, -3), 3.0, Color.WHITE)
	if elite:
		draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 28, Color("e3c2ff"), 3.0)
		draw_line(Vector2(-18, -25), Vector2(0, -38), Color("e3c2ff"), 4.0)
		draw_line(Vector2(0, -38), Vector2(18, -25), Color("e3c2ff"), 4.0)
	if is_telegraphing() and is_instance_valid(target):
		var local_target := to_local(target.global_position)
		draw_line(Vector2.ZERO, local_target.normalized() * minf(local_target.length(), 210.0), Color("ffce55"), 4.0)
		draw_arc(Vector2.ZERO, 31.0, -PI * 0.75, PI * 0.75, 24, Color("fff1a6"), 5.0)
