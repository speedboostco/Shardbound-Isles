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

func _ready() -> void:
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
	advance_attack(delta)
	if not active or not is_instance_valid(target) or is_telegraphing():
		velocity = Vector2.ZERO
		return
	var distance := global_position.distance_to(target.global_position)
	velocity = global_position.direction_to(target.global_position) * move_speed if distance > 115.0 else Vector2.ZERO
	move_and_slide()

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

func _draw() -> void:
	if not active:
		return
	var body_color := Color("c24fbb") if phase == 2 else Color("3475a8")
	draw_circle(Vector2.ZERO, 37.0, body_color)
	draw_arc(Vector2.ZERO, 42.0, 0.0, TAU, 36, Color("ff9af3") if phase == 2 else Color("79d9ff"), 4.0)
	draw_line(Vector2(-27, -30), Vector2(-42, -48), Color("d5f5ff"), 6.0)
	draw_line(Vector2(27, -30), Vector2(42, -48), Color("d5f5ff"), 6.0)
	draw_circle(Vector2(-11, -5), 5.0, Color.WHITE)
	draw_circle(Vector2(11, -5), 5.0, Color.WHITE)
	draw_rect(Rect2(-42, -62, 84, 8), Color("271c35"))
	draw_rect(Rect2(-40, -60, 80.0 * float(health) / float(MAXIMUM_HEALTH), 4), Color("ff557f"))
	if is_telegraphing() and is_instance_valid(target):
		if phase == 1:
			draw_line(Vector2.ZERO, to_local(target.global_position).normalized() * 220.0, Color("71e4ff"), 6.0)
		else:
			for direction: Vector2 in BossAttackPattern.directions(2, Vector2.RIGHT):
				draw_line(direction * 48.0, direction * 105.0, Color("ff87ea"), 5.0)
		draw_arc(Vector2.ZERO, 49.0, 0.0, TAU, 36, Color.WHITE, 4.0)

