class_name RangedEnemy
extends CharacterBody2D

const HealthComponentScript := preload("res://game/core/health_component.gd")
const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")

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
var _hit_flash_remaining: float = 0.0
var _visual_sprite: Sprite2D
var _visual_asset_id: String = ""
var _visual_frame_key: String = ""
var _visual_state_name: String = AnimationStateRules.IDLE
var _visual_state_elapsed: float = 0.0
var _dead: bool = false
var _visual_time: float = 0.0
var _visual_facing: String = "south"

func _ready() -> void:
	health_component = HealthComponentScript.new(5 if elite else 3)
	health_component.died.connect(_on_died)
	add_to_group("attackable")
	_ensure_visual_sprite()
	queue_redraw()

func _physics_process(delta: float) -> void:
	_hit_flash_remaining = maxf(0.0, _hit_flash_remaining - delta)
	advance_attack(delta)
	if not is_instance_valid(target) or is_telegraphing():
		velocity = Vector2.ZERO
		_update_visual(delta)
		return
	var distance := global_position.distance_to(target.global_position)
	if distance < 185.0:
		velocity = target.global_position.direction_to(global_position) * move_speed
	elif distance > 280.0:
		velocity = global_position.direction_to(target.global_position) * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	_update_visual(delta)

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
		_hit_flash_remaining = 0.12
		_update_visual()
		queue_redraw()

func _on_died() -> void:
	_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	remove_from_group("attackable")
	defeated.emit(global_position, loot_seed)
	_update_visual()
	_spawn_death_pose()
	queue_free()

func _ensure_visual_sprite() -> void:
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * (3.55 if elite else 3.2)
	_visual_sprite.position = Vector2(0, -18)
	_visual_sprite.z_index = 2
	add_child(_visual_sprite)
	_update_visual()

func _update_visual(delta: float = 0.0) -> void:
	if not is_instance_valid(_visual_sprite):
		return
	_visual_time += maxf(0.0, delta)
	var state_name := AnimationStateRules.resolve(_dead, _hit_flash_remaining > 0.0, is_telegraphing(), not velocity.is_zero_approx())
	if state_name != _visual_state_name:
		_visual_state_name = state_name
		_visual_state_elapsed = 0.0
	else:
		_visual_state_elapsed += maxf(0.0, delta)
	var look_direction := velocity
	if is_instance_valid(target) and (is_telegraphing() or look_direction.is_zero_approx()):
		look_direction = global_position.direction_to(target.global_position)
	_visual_facing = FacingRules.resolve(look_direction, _visual_facing)
	var frame_count := VisualAssetLibrary.animation_frame_count("ranger", state_name, _visual_facing, elite)
	var frames_per_second := 10.0 if state_name in [AnimationStateRules.MOVE, AnimationStateRules.ATTACK] else 8.0
	var frame := AnimationStateRules.frame_index(_visual_state_elapsed, frames_per_second, frame_count, state_name != AnimationStateRules.ATTACK)
	var frame_key := "%s_ranger:%s:%s:%d" % ["elite" if elite else "forest", _visual_facing, state_name, frame]
	if frame_key != _visual_frame_key:
		_visual_sprite.texture = VisualAssetLibrary.animation_texture("ranger", state_name, _visual_facing, frame, elite)
		_visual_frame_key = frame_key
	_visual_sprite.flip_h = false
	_visual_asset_id = "ranger_attack" if state_name == AnimationStateRules.ATTACK else "ranger_%s" % state_name
	var base_scale := 3.55 if elite else 3.2
	var moving := not velocity.is_zero_approx()
	var stride := PresentationMotion.wave(_visual_time, 2.0 if moving else 0.6, 0.2 if elite else 0.0)
	var recoil := -4.0 if is_telegraphing() else 0.0
	var target_position := Vector2(recoil, -18.0 + stride * (1.0 if moving else 0.35))
	var target_scale := Vector2(base_scale * (1.0 + stride * 0.018), base_scale * (1.0 - stride * 0.018))
	var response := PresentationMotion.response_alpha(delta, 16.0)
	_visual_sprite.position = _visual_sprite.position.lerp(target_position, response)
	_visual_sprite.scale = _visual_sprite.scale.lerp(target_scale, response)
	_visual_sprite.modulate = Color("fff0b8") if _hit_flash_remaining > 0.0 else (Color("e4d7ff") if elite else Color.WHITE)
	queue_redraw()

func animation_state() -> String:
	return _visual_state_name

func _spawn_death_pose() -> void:
	var parent_node := get_parent()
	if parent_node == null:
		return
	var pose := Sprite2D.new()
	pose.texture = VisualAssetLibrary.animation_texture("ranger", AnimationStateRules.DEATH, _visual_facing, 4, elite)
	pose.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pose.scale = Vector2.ONE * (3.55 if elite else 3.2)
	pose.global_position = global_position + Vector2(0, -18)
	pose.z_index = 2
	parent_node.add_child(pose)
	var tween := pose.create_tween().set_parallel(true)
	tween.tween_property(pose, "modulate:a", 0.0, 0.38)
	tween.tween_property(pose, "position:y", pose.position.y + 7.0, 0.38)
	tween.chain().tween_callback(pose.queue_free)

func _draw() -> void:
	ContactShadowScript.paint(self, "ranged_enemy", 17.0 if elite else 15.0)
	if elite:
		draw_line(Vector2(-12, -35), Vector2(0, -45), Color("e3c2ff"), 3.0)
		draw_line(Vector2(0, -45), Vector2(12, -35), Color("e3c2ff"), 3.0)
	if is_telegraphing() and is_instance_valid(target):
		var local_target := to_local(target.global_position)
		draw_line(Vector2.ZERO, local_target.normalized() * minf(local_target.length(), 210.0), Color("ffce55"), 4.0)
		var aim_angle := local_target.angle()
		draw_arc(Vector2.ZERO, 31.0, aim_angle - 0.48, aim_angle + 0.48, 12, Color("fff1a6"), 5.0)

func uses_circular_combat_overlay() -> bool:
	return false
