class_name PlayerWeaponProjectile
extends Node2D

signal impacted(target: Node2D, damage: int, critical: bool, weapon_seed: int, attack_index: int)

var target: Node2D
var damage: int = 1
var speed: float = 720.0
var lifetime: float = 0.75
var direction: Vector2 = Vector2.RIGHT
var _resolved: bool = false
var critical: bool = false
var weapon_seed: int = 0
var attack_index: int = 0
var maximum_distance: float = 310.0
var _origin: Vector2

func configure(target_value: Node2D, damage_value: int, direction_value: Vector2, critical_value: bool = false, weapon_seed_value: int = 0, attack_index_value: int = 0) -> void:
	target = target_value
	damage = maxi(1, damage_value)
	direction = direction_value.normalized() if not direction_value.is_zero_approx() else Vector2.RIGHT
	critical = critical_value
	weapon_seed = weapon_seed_value
	attack_index = attack_index_value

func _ready() -> void:
	add_to_group("player_weapon_projectile")
	_origin = global_position
	queue_redraw()

func _physics_process(delta: float) -> void:
	if _resolved:
		return
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	if not is_instance_valid(target):
		global_position += direction * speed * delta
		rotation = direction.angle()
		if global_position.distance_to(_origin) >= maximum_distance:
			queue_free()
		return
	var destination := target.global_position
	direction = global_position.direction_to(destination)
	global_position = global_position.move_toward(destination, speed * delta)
	rotation = direction.angle()
	if global_position.distance_to(destination) <= 8.0:
		resolve_immediately()

func resolve_immediately() -> bool:
	if _resolved or not is_instance_valid(target):
		return false
	_resolved = true
	impacted.emit(target, damage, critical, weapon_seed, attack_index)
	queue_free()
	return true

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(13, 0), Vector2(-7, -4), Vector2(-7, 4)]), Color("8fe7ff"))
	draw_line(Vector2(-16, 0), Vector2(-5, 0), Color("d8fbff"), 3.0)
