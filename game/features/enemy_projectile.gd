class_name EnemyProjectile
extends Node2D

var target: PlayerCharacter
var direction: Vector2 = Vector2.RIGHT
var damage: int = 1
var speed: float = 320.0
var consumed: bool = false

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if consumed:
		return
	global_position += direction.normalized() * speed * delta
	if is_instance_valid(target) and global_position.distance_to(target.global_position) <= 20.0:
		consumed = true
		target.take_damage(damage)
		queue_free()
	elif absf(global_position.x) > 700.0 or absf(global_position.y) > 460.0:
		consumed = true
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color("ffcf62"))
	draw_circle(Vector2.ZERO, 3.0, Color.WHITE)

