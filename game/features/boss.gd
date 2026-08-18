class_name AbyssalWarden
extends CharacterBody2D

signal volley_requested(origin: Vector2, directions: Array[Vector2], damage: int)
signal phase_changed(new_phase: int, base_speed: float)
signal defeated(position_value: Vector2)

const MAXIMUM_HEALTH: int = 12
const PHASE_ONE_SPEED: float = 50.0
const PHASE_TWO_SPEED: float = 105.0

var active: bool = false
var target: Node2D
var health: int = MAXIMUM_HEALTH
var phase: int = 1
var move_speed: float = PHASE_ONE_SPEED
var _cooldown_remaining: float = 0.9
var _telegraph_remaining: float = 0.0
var _defeat_emitted: bool = false
var _hit_flash_remaining: float = 0.0
var _visual_sprite: Sprite2D
var _visual_state_name: String = AnimationStateRules.IDLE
var _visual_state_elapsed: float = 0.0
var _visual_frame_key: String = ""
var _visual_facing: String = "south"

func _ready() -> void:
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * 4.4
	_visual_sprite.position = Vector2(0, -26)
	_visual_sprite.z_index = 2
	add_child(_visual_sprite)
	_update_visual(0.0)
	visible = false
	set_physics_process(false)
	queue_redraw()

func activate(player_target: Node2D) -> bool:
	if active:
		return false
	active = true
	target = player_target
	visible = true
	add_to_group("attackable")
	set_physics_process(true)
	queue_redraw()
	return true

func _physics_process(delta: float) -> void:
	_hit_flash_remaining = maxf(0.0, _hit_flash_remaining - delta)
	advance_attack(delta)
	if not active or not is_instance_valid(target) or is_telegraphing():
		velocity = Vector2.ZERO
		_update_visual(delta)
		return
	var distance := global_position.distance_to(target.global_position)
	velocity = global_position.direction_to(target.global_position) * move_speed if distance > 115.0 else Vector2.ZERO
	move_and_slide()
	_update_visual(delta)

func advance_attack(delta: float) -> void:
	if not active or not is_instance_valid(target) or delta <= 0.0:
		return
	if _telegraph_remaining > 0.0:
		_telegraph_remaining = maxf(0.0, _telegraph_remaining - delta)
		if _telegraph_remaining <= 0.0:
			var aim := global_position.direction_to(target.global_position)
			volley_requested.emit(global_position, BossAttackPattern.directions(phase, aim), 2 if phase == 1 else 1)
			_cooldown_remaining = 1.8 if phase == 1 else 1.25
		queue_redraw()
		return
	_cooldown_remaining -= delta
	if _cooldown_remaining <= 0.0:
		_telegraph_remaining = BossAttackPattern.telegraph_seconds(phase)
		velocity = Vector2.ZERO
		queue_redraw()

func is_telegraphing() -> bool:
	return _telegraph_remaining > 0.0

func receive_attack(damage: int) -> void:
	if not active or _defeat_emitted:
		return
	health = maxi(0, health - damage)
	_hit_flash_remaining = 0.14
	if phase == 1 and health <= MAXIMUM_HEALTH / 2 and health > 0:
		phase = 2
		move_speed = PHASE_TWO_SPEED
		phase_changed.emit(phase, PHASE_TWO_SPEED)
	if health <= 0:
		_defeat_emitted = true
		active = false
		remove_from_group("attackable")
		defeated.emit(global_position)
		queue_free()
	queue_redraw()
	_update_visual(0.0)

func _update_visual(delta: float) -> void:
	if not is_instance_valid(_visual_sprite):
		return
	var state_name := AnimationStateRules.resolve(_defeat_emitted, _hit_flash_remaining > 0.0, is_telegraphing(), not velocity.is_zero_approx())
	if state_name != _visual_state_name:
		_visual_state_name = state_name
		_visual_state_elapsed = 0.0
	else:
		_visual_state_elapsed += maxf(0.0, delta)
	var look_direction := velocity
	if is_instance_valid(target) and (is_telegraphing() or look_direction.is_zero_approx()):
		look_direction = global_position.direction_to(target.global_position)
	_visual_facing = FacingRules.resolve(look_direction, _visual_facing)
	var frame_count := VisualAssetLibrary.animation_frame_count("boss", state_name, _visual_facing)
	var fps := 10.0 if state_name in [AnimationStateRules.MOVE, AnimationStateRules.ATTACK] else 8.0
	var frame := AnimationStateRules.frame_index(_visual_state_elapsed, fps, frame_count, state_name != AnimationStateRules.ATTACK)
	var frame_key := "%s:%s:%d" % [_visual_facing, state_name, frame]
	if frame_key != _visual_frame_key:
		_visual_sprite.texture = VisualAssetLibrary.animation_texture("boss", state_name, _visual_facing, frame)
		_visual_frame_key = frame_key
	_visual_sprite.flip_h = false
	_visual_sprite.modulate = Color("ffb4f4") if phase == 2 else (Color("fff2c4") if _hit_flash_remaining > 0.0 else Color.WHITE)

func _draw() -> void:
	if not active:
		return
	draw_rect(Rect2(-50, -82, 100, 9), Color("172331"))
	draw_rect(Rect2(-47, -79, 94.0 * float(health) / float(MAXIMUM_HEALTH), 4), Color("ff557f"))
	if is_telegraphing() and is_instance_valid(target):
		if phase == 1:
			draw_line(Vector2.ZERO, to_local(target.global_position).normalized() * 220.0, Color("71e4ff"), 6.0)
		else:
			for direction: Vector2 in BossAttackPattern.directions(2, Vector2.RIGHT):
				draw_line(direction * 48.0, direction * 105.0, Color("ff87ea"), 5.0)

func uses_circular_combat_overlay() -> bool:
	return false
