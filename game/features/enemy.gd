class_name ChaserEnemy
extends CharacterBody2D

signal defeated(position_value: Vector2)

const HealthComponentScript := preload("res://game/core/health_component.gd")

enum State { IDLE, CHASE, ATTACK, DEAD }

@export var hit_points: int = 3
@export var move_speed: float = 75.0
@export var detection_radius: float = 700.0
var target: Node2D
var health_component: Variant
var remaining_health: int:
	get: return health_component.current if health_component != null else hit_points
var state: State = State.IDLE
var _contact_cooldown: float = 0.0
var _avoidance_remaining: float = 0.0
var _avoidance_sign: float = 1.0

func _ready() -> void:
	health_component = HealthComponentScript.new(hit_points)
	health_component.died.connect(_on_died)
	_ensure_collision_shape()
	add_to_group("attackable")
	queue_redraw()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		velocity = Vector2.ZERO
		return
	_contact_cooldown = maxf(0.0, _contact_cooldown - delta)
	_avoidance_remaining = maxf(0.0, _avoidance_remaining - delta)
	if not is_instance_valid(target) or global_position.distance_to(target.global_position) > detection_radius:
		state = State.IDLE
		velocity = Vector2.ZERO
		return
	var distance := global_position.distance_to(target.global_position)
	if distance <= 42.0:
		state = State.ATTACK
		velocity = Vector2.ZERO
		if _contact_cooldown <= 0.0 and target.has_method("take_damage"):
			target.take_damage(1)
			_contact_cooldown = 0.8
		return
	state = State.CHASE
	var desired := global_position.direction_to(target.global_position)
	if _avoidance_remaining > 0.0:
		desired = desired.rotated(_avoidance_sign * PI * 0.5)
	velocity = desired * move_speed
	move_and_slide()
	if get_slide_collision_count() > 0 and _avoidance_remaining <= 0.0:
		_avoidance_remaining = 0.75

func receive_attack(damage: int) -> void:
	if state == State.DEAD:
		return
	if health_component.damage(damage):
		queue_redraw()

func _on_died() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	set_physics_process(false)
	remove_from_group("attackable")
	defeated.emit(global_position)
	queue_free()

func _ensure_collision_shape() -> void:
	if get_node_or_null("CollisionShape2D") != null:
		return
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 18.0
	collision.shape = shape
	collision.name = "CollisionShape2D"
	add_child(collision)

func _draw() -> void:
	var hurt := remaining_health < hit_points
	var body_color := Color("91d94f") if not hurt else Color("d8ef73")
	draw_circle(Vector2(0, 4), 20.0, body_color)
	draw_circle(Vector2(-11, 9), 9.0, body_color)
	draw_circle(Vector2(11, 9), 9.0, body_color)
	draw_circle(Vector2(-6.0, 0.0), 3.0, Color("132a3a"))
	draw_circle(Vector2(6.0, 0.0), 3.0, Color("132a3a"))
	draw_arc(Vector2(0, 4), 22.0, 0.0, TAU, 24, Color("284d2d"), 3.0)
