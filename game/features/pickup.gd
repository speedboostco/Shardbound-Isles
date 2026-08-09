class_name WorldPickup
extends Area2D

signal collected(kind: String, payload: Variant)

const MERGE_RADIUS: float = 48.0

var kind: String = "wood"
var payload: Variant = 1
var target: Node2D
var attraction_radius: float = 135.0
var spawn_order: int = 0
var important: bool = false
var owner_id: String = "world"
var rarity: String = "ordinary"
var encounter_reward: bool = false
var collector: Callable
var _retry_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("world_pickups")

func _physics_process(delta: float) -> void:
	_retry_cooldown = maxf(0.0, _retry_cooldown - delta)
	if not is_instance_valid(target):
		return
	attraction_radius = maxf(attraction_radius, float(target.get("pickup_radius")) if target.get("pickup_radius") != null else attraction_radius)
	var distance := global_position.distance_to(target.global_position)
	if distance <= attraction_radius:
		global_position = global_position.move_toward(target.global_position, 420.0 * delta)
	if distance <= 24.0 and _retry_cooldown <= 0.0:
		collect_immediately()

func collect_immediately() -> bool:
	if collector.is_valid() and not bool(collector.call(kind, payload)):
		_retry_cooldown = 0.25
		return false
	collected.emit(kind, payload)
	queue_free()
	return true

func merge_amount(amount: int) -> bool:
	if kind not in ["wood", "stone"] or not payload is int or amount <= 0:
		return false
	payload = int(payload) + amount
	queue_redraw()
	return true

func _draw() -> void:
	if important:
		draw_line(Vector2(0, -52), Vector2(0, 24), Color(1.0, 0.65, 0.25, 0.65), 6.0)
		draw_arc(Vector2.ZERO, 17.0, 0.0, TAU, 20, Color("fff0a8"), 3.0)
	if kind == "island_shard":
		draw_colored_polygon(PackedVector2Array([Vector2(0, -13), Vector2(11, 0), Vector2(0, 13), Vector2(-11, 0)]), Color("72e1a5"))
		draw_polyline(PackedVector2Array([Vector2(0, -13), Vector2(11, 0), Vector2(0, 13), Vector2(-11, 0), Vector2(0, -13)]), Color.WHITE, 2.0)
	elif kind == "stone":
		var shape := PackedVector2Array([Vector2(-10, 7), Vector2(-7, -7), Vector2(3, -11), Vector2(11, -2), Vector2(7, 10), Vector2(-10, 7)])
		draw_colored_polygon(shape, Color("91a7b5"))
		draw_polyline(shape, Color.WHITE, 2.0)
	else:
		var color := Color("f0c55b") if kind == "wood" else (Color("ff914d") if important else Color("b779ff"))
		draw_circle(Vector2.ZERO, 12.0 if important else 9.0, color)
		draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 16, Color.WHITE, 2.0)
