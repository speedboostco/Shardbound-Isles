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
var _telegraph_remaining: float = 0.0
var _hit_flash_remaining: float = 0.0
var _visual_sprite: Sprite2D
var _visual_asset_id: String = "slime_idle"

func _ready() -> void:
	health_component = HealthComponentScript.new(hit_points)
	health_component.died.connect(_on_died)
	_ensure_collision_shape()
	_ensure_visual_sprite()
	add_to_group("attackable")
	queue_redraw()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		velocity = Vector2.ZERO
		return
	_contact_cooldown = maxf(0.0, _contact_cooldown - delta)
	_hit_flash_remaining = maxf(0.0, _hit_flash_remaining - delta)
	_avoidance_remaining = maxf(0.0, _avoidance_remaining - delta)
	if not is_instance_valid(target) or global_position.distance_to(target.global_position) > detection_radius:
		state = State.IDLE
		_telegraph_remaining = 0.0
		velocity = Vector2.ZERO
		_update_visual()
		return
	var distance := global_position.distance_to(target.global_position)
	if distance <= 42.0:
		state = State.ATTACK
		velocity = Vector2.ZERO
		if _telegraph_remaining > 0.0:
			_telegraph_remaining = maxf(0.0, _telegraph_remaining - delta)
			if _telegraph_remaining <= 0.0 and target.has_method("take_damage"):
				target.take_damage(1)
				_contact_cooldown = 0.8
		elif _contact_cooldown <= 0.0:
			_telegraph_remaining = 0.22
		_update_visual()
		return
	_telegraph_remaining = 0.0
	state = State.CHASE
	var desired := global_position.direction_to(target.global_position)
	if _avoidance_remaining > 0.0:
		desired = desired.rotated(_avoidance_sign * PI * 0.5)
	velocity = desired * move_speed
	move_and_slide()
	if get_slide_collision_count() > 0 and _avoidance_remaining <= 0.0:
		_avoidance_remaining = 0.75
	_update_visual()

func is_telegraphing() -> bool:
	return _telegraph_remaining > 0.0

func receive_attack(damage: int) -> void:
	if state == State.DEAD:
		return
	if health_component.damage(damage):
		_hit_flash_remaining = 0.12
		_update_visual()
		queue_redraw()

func _on_died() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	set_physics_process(false)
	remove_from_group("attackable")
	defeated.emit(global_position)
	_update_visual()
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

func _ensure_visual_sprite() -> void:
	_visual_sprite = VisualAssetLibrary.sprite("slime_idle", 1.2)
	_visual_sprite.position = Vector2(0, -7)
	_visual_sprite.z_index = 2
	add_child(_visual_sprite)

func _update_visual() -> void:
	if not is_instance_valid(_visual_sprite):
		return
	var asset_id := "slime_attack" if state == State.ATTACK else "slime_idle"
	if asset_id != _visual_asset_id:
		_visual_sprite.texture = VisualAssetLibrary.texture(asset_id)
		_visual_asset_id = asset_id
	_visual_sprite.position.x = 3.0 if _hit_flash_remaining > 0.0 else 0.0
	_visual_sprite.modulate = Color("fff2c4") if _hit_flash_remaining > 0.0 else Color.WHITE
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(0, 14), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 22.0, Color(0.03, 0.08, 0.09, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if is_telegraphing():
		draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 24, Color("e9674c"), 4.0)
