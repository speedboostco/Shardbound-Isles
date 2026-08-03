class_name PlayerCharacter
extends CharacterBody2D

signal attack_requested(origin: Vector2, direction: Vector2)
signal health_changed(current: int, maximum: int)
signal defeated

@export var move_speed: float = 240.0
var maximum_health: int = 10
var health: int = 10
var attack_damage: int = 1
var legendary_affix_id: String = ""
var facing: Vector2 = Vector2.RIGHT
var _attack_cooldown: float = 0.0
var input_enabled: bool = true

func _ready() -> void:
	queue_redraw()
	health_changed.emit(health, maximum_health)

func _physics_process(delta: float) -> void:
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	if not input_enabled:
		velocity = Vector2.ZERO
		return
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not input_vector.is_zero_approx():
		facing = input_vector.normalized()
	velocity = input_vector * move_speed
	move_and_slide()
	global_position.x = clampf(global_position.x, -590.0, 590.0)
	global_position.y = clampf(global_position.y, -350.0, 350.0)
	if Input.is_action_just_pressed("attack"):
		request_attack()

func request_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = 0.28
	attack_requested.emit(global_position, facing)

func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
	if health == 0:
		defeated.emit()
		health = maximum_health
		global_position = Vector2.ZERO
	health_changed.emit(health, maximum_health)
	queue_redraw()

func add_maximum_health(amount: int) -> void:
	maximum_health += amount
	health += amount
	health_changed.emit(health, maximum_health)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color("4cc9f0"))
	draw_line(Vector2.ZERO, facing * 27.0, Color.WHITE, 5.0)
	draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 24, Color("132a3a"), 3.0)
