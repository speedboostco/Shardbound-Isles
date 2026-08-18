class_name ChaserEnemy
extends CharacterBody2D

signal defeated(position_value: Vector2)

const HealthComponentScript := preload("res://game/core/health_component.gd")
const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")

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
var _visual_asset_id: String = ""
var _visual_state_name: String = AnimationStateRules.IDLE
var _visual_state_elapsed: float = 0.0
var _visual_time: float = 0.0
var _visual_facing: String = "south"

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
		_update_visual(delta)
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
		_update_visual(delta)
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
	_update_visual(delta)

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
	_spawn_death_pose()
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
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * 3.15
	_visual_sprite.position = Vector2(0, -17)
	_visual_sprite.z_index = 2
	add_child(_visual_sprite)

func _update_visual(delta: float = 0.0) -> void:
	if not is_instance_valid(_visual_sprite):
		return
	_visual_time += maxf(0.0, delta)
	var state_name := AnimationStateRules.resolve(state == State.DEAD, _hit_flash_remaining > 0.0, state == State.ATTACK, state == State.CHASE and not velocity.is_zero_approx())
	if state_name != _visual_state_name:
		_visual_state_name = state_name
		_visual_state_elapsed = 0.0
	else:
		_visual_state_elapsed += maxf(0.0, delta)
	var look_direction := velocity
	if state == State.ATTACK and is_instance_valid(target):
		look_direction = global_position.direction_to(target.global_position)
	_visual_facing = FacingRules.resolve(look_direction, _visual_facing)
	var frame_count := VisualAssetLibrary.animation_frame_count("slime", state_name, _visual_facing)
	var frames_per_second := 10.0 if state_name in [AnimationStateRules.MOVE, AnimationStateRules.ATTACK] else 8.0
	var frame := AnimationStateRules.frame_index(_visual_state_elapsed, frames_per_second, frame_count, state_name != AnimationStateRules.ATTACK)
	var asset_id := "slime:%s:%s:%d" % [_visual_facing, state_name, frame]
	if asset_id != _visual_asset_id:
		_visual_sprite.texture = VisualAssetLibrary.animation_texture("slime", state_name, _visual_facing, frame)
		_visual_asset_id = asset_id
	_visual_sprite.flip_h = false
	var moving := state == State.CHASE and not velocity.is_zero_approx()
	var bounce := PresentationMotion.wave(_visual_time, 2.4 if moving else 0.8)
	var target_position := Vector2(3.0 if _hit_flash_remaining > 0.0 else 0.0, -17.0 + bounce * (1.5 if moving else 0.55))
	var stretch := bounce * (0.07 if moving else 0.025)
	var target_scale := Vector2(3.15 * (1.0 + stretch), 3.15 * (1.0 - stretch))
	var response := PresentationMotion.response_alpha(delta, 20.0)
	_visual_sprite.position = _visual_sprite.position.lerp(target_position, response)
	_visual_sprite.scale = _visual_sprite.scale.lerp(target_scale, response)
	_visual_sprite.modulate = Color("fff2c4") if _hit_flash_remaining > 0.0 else Color.WHITE
	queue_redraw()

func animation_state() -> String:
	return _visual_state_name

func _spawn_death_pose() -> void:
	var parent_node := get_parent()
	if parent_node == null:
		return
	var pose := Sprite2D.new()
	pose.texture = VisualAssetLibrary.animation_texture("slime", AnimationStateRules.DEATH, _visual_facing, 4)
	pose.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pose.scale = Vector2.ONE * 3.15
	pose.global_position = global_position + Vector2(0, -17)
	pose.z_index = 2
	parent_node.add_child(pose)
	var tween := pose.create_tween().set_parallel(true)
	tween.tween_property(pose, "modulate:a", 0.0, 0.34)
	tween.tween_property(pose, "position:y", pose.position.y + 6.0, 0.34)
	tween.chain().tween_callback(pose.queue_free)

func _draw() -> void:
	ContactShadowScript.paint(self, "enemy")
	if is_telegraphing() and is_instance_valid(target):
		var direction := global_position.direction_to(target.global_position)
		draw_arc(Vector2.ZERO, 33.0, direction.angle() - 0.58, direction.angle() + 0.58, 12, Color("e9674c"), 4.0)
		draw_line(direction * 19.0, direction * 43.0, Color("fff1a6"), 3.0)

func uses_circular_combat_overlay() -> bool:
	return false
