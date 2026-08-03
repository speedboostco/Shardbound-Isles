class_name PlayerCharacter
extends CharacterBody2D

signal attack_requested(origin: Vector2, direction: Vector2)
signal interaction_requested
signal moved(position_value: Vector2)
signal health_changed(current: int, maximum: int)
signal defeated

const MovementRulesScript := preload("res://game/core/movement_rules.gd")
const HealthComponentScript := preload("res://game/core/health_component.gd")
const BASE_ATTACK_INTERVAL: float = 0.28

@export var move_speed: float = 240.0
var health_component: Variant = HealthComponentScript.new(10, 0.45)
var maximum_health: int:
	get: return health_component.maximum
	set(value): health_component.set_maximum(value)
var health: int:
	get: return health_component.current
	set(value): health_component.set_current(clampi(value, 0, health_component.maximum))
var attack_damage: int = 1
var attack_speed: float = 1.0
var weapon_base_type: String = "unarmed"
var legendary_affix_id: String = ""
var legendary_effect_ids: Array[String] = []
var attack_profile: Dictionary = {"style": "slash", "range": 78.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0}
var pickup_radius: float = 135.0
var gathering_power: float = 1.0
var critical_chance: float = 0.05
var critical_damage: float = 1.5
var facing: Vector2 = Vector2.RIGHT
var input_enabled: bool = true
var _attack_cooldown: float = 0.0
var _attack_flash_remaining: float = 0.0
var _hit_flash_remaining: float = 0.0

func _ready() -> void:
	health_component.changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	_ensure_collision_shape()
	queue_redraw()
	health_changed.emit(health, maximum_health)

func _physics_process(delta: float) -> void:
	health_component.advance(delta)
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_attack_flash_remaining = maxf(0.0, _attack_flash_remaining - delta)
	_hit_flash_remaining = maxf(0.0, _hit_flash_remaining - delta)
	if _attack_flash_remaining > 0.0 or _hit_flash_remaining > 0.0:
		queue_redraw()
	if not input_enabled:
		velocity = Vector2.ZERO
		return
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not input_vector.is_zero_approx():
		facing = input_vector.normalized()
	var previous_position := global_position
	velocity = MovementRulesScript.velocity(input_vector, move_speed)
	move_and_slide()
	global_position.x = clampf(global_position.x, -850.0, 850.0)
	global_position.y = clampf(global_position.y, -550.0, 550.0)
	if not global_position.is_equal_approx(previous_position):
		moved.emit(global_position)
	if Input.is_action_just_pressed("attack"):
		request_attack()
	if Input.is_action_just_pressed("interact"):
		interaction_requested.emit()

func request_attack() -> bool:
	if _attack_cooldown > 0.0:
		return false
	_attack_cooldown = BASE_ATTACK_INTERVAL / maxf(0.1, attack_speed)
	_attack_flash_remaining = 0.12
	queue_redraw()
	attack_requested.emit(global_position, facing)
	return true

func confirm_hit() -> void:
	_hit_flash_remaining = 0.16
	queue_redraw()

func attack_cooldown_remaining() -> float:
	return _attack_cooldown

func is_hit_feedback_active() -> bool:
	return _hit_flash_remaining > 0.0

func set_weapon_stats(damage_value: int, speed_value: float, base_type_value: String, affix_id: String = "", profile: Dictionary = {}, effect_ids: Array[String] = []) -> void:
	attack_damage = maxi(1, damage_value)
	attack_speed = maxf(0.1, speed_value)
	weapon_base_type = base_type_value if not base_type_value.is_empty() else "unarmed"
	legendary_affix_id = affix_id
	legendary_effect_ids = effect_ids.duplicate()
	if not affix_id.is_empty() and affix_id not in legendary_effect_ids:
		legendary_effect_ids.append(affix_id)
	attack_profile = profile.duplicate(true) if not profile.is_empty() else _default_attack_profile(weapon_base_type)
	queue_redraw()

func set_derived_stats(stats: Dictionary) -> void:
	move_speed = maxf(1.0, float(stats.get("movement_speed", move_speed)))
	pickup_radius = maxf(0.0, float(stats.get("pickup_radius", pickup_radius)))
	gathering_power = maxf(0.1, float(stats.get("gathering_power", gathering_power)))
	critical_chance = clampf(float(stats.get("critical_chance", critical_chance)), 0.0, 1.0)
	critical_damage = maxf(1.0, float(stats.get("critical_damage", critical_damage)))

func _default_attack_profile(base_type: String) -> Dictionary:
	if base_type == "magic":
		return {"style": "arcane_strike", "range": 78.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0}
	var canonical := "bow" if base_type == "ranged" else ("sword" if base_type == "melee" else base_type)
	var definition := ItemBaseRegistry.get_definition(canonical)
	return (definition.get("attack_profile", {"style": "slash", "range": 78.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0}) as Dictionary).duplicate(true)

func take_damage(amount: int) -> bool:
	var applied: bool = health_component.damage(amount)
	if applied:
		queue_redraw()
	return applied

func add_maximum_health(amount: int) -> void:
	if amount <= 0:
		return
	health_component.set_maximum(maximum_health + amount, true)

func _on_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)
	queue_redraw()

func _on_died() -> void:
	defeated.emit()
	global_position = Vector2.ZERO
	health_component.revive()
	moved.emit(global_position)

func _ensure_collision_shape() -> void:
	if get_node_or_null("CollisionShape2D") != null:
		return
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	collision.shape = shape
	collision.name = "CollisionShape2D"
	add_child(collision)

func _draw() -> void:
	var body_color := Color("8de7ff") if health_component.is_invulnerable() else Color("4cc9f0")
	draw_circle(Vector2.ZERO, 18.0, body_color)
	var canonical := "bow" if weapon_base_type == "ranged" else ("wand" if weapon_base_type == "magic" else ("sword" if weapon_base_type == "melee" else weapon_base_type))
	var weapon_color := Color("f0c55b") if canonical == "sword" else (Color("9ce7ff") if canonical == "bow" else Color("d09cff"))
	draw_line(Vector2.ZERO, facing * (31.0 if weapon_base_type != "unarmed" else 27.0), weapon_color, 6.0 if weapon_base_type != "unarmed" else 5.0)
	if _attack_flash_remaining > 0.0:
		if canonical == "bow":
			draw_line(facing * 24.0, facing * 95.0, Color("baf3ff"), 4.0)
		elif canonical == "wand":
			draw_circle(facing * 42.0, 15.0, Color(0.72, 0.38, 1.0, 0.35))
			draw_arc(facing * 42.0, 18.0, 0.0, TAU, 18, Color("e7c4ff"), 4.0)
		else:
			draw_arc(Vector2.ZERO, 34.0, facing.angle() - 0.7, facing.angle() + 0.7, 16, Color("fff1a6"), 5.0)
	if _hit_flash_remaining > 0.0:
		draw_arc(Vector2.ZERO, 39.0, 0.0, TAU, 28, Color("ffffff"), 4.0)
	draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 24, Color("132a3a"), 3.0)
