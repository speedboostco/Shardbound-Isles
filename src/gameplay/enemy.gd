class_name ChaserEnemy
extends CharacterBody2D

signal defeated(position_value: Vector2)

@export var hit_points: int = 3
@export var move_speed: float = 75.0
var target: Node2D
var remaining_health: int
var _contact_cooldown: float = 0.0

func _ready() -> void:
	remaining_health = hit_points
	add_to_group("attackable")
	queue_redraw()

func _physics_process(delta: float) -> void:
	_contact_cooldown = maxf(0.0, _contact_cooldown - delta)
	if is_instance_valid(target):
		var distance := global_position.distance_to(target.global_position)
		velocity = global_position.direction_to(target.global_position) * move_speed if distance > 42.0 else Vector2.ZERO
		move_and_slide()
		if distance <= 42.0 and _contact_cooldown <= 0.0 and target.has_method("take_damage"):
			target.take_damage(1)
			_contact_cooldown = 0.8

func receive_attack(damage: int) -> void:
	remaining_health -= damage
	queue_redraw()
	if remaining_health <= 0:
		defeated.emit(global_position)
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 19.0, Color("e34b4b") if remaining_health == hit_points else Color("ff9a62"))
	draw_circle(Vector2(-6.0, -3.0), 3.0, Color.WHITE)
	draw_circle(Vector2(6.0, -3.0), 3.0, Color.WHITE)
	draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 24, Color("501b24"), 3.0)

