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
var _visual_sprite: Sprite2D

func rarity_cue() -> String:
	match rarity.to_lower():
		"magic":
			return "cyan_triangle"
		"rare":
			return "blue_diamond"
		"epic":
			return "violet_star"
		"legendary":
			return "gold_hex_beam"
		_:
			return "gray_circle"

func _ready() -> void:
	add_to_group("world_pickups")
	_ensure_visual_sprite()
	if is_instance_valid(_visual_sprite):
		var target_scale := _visual_sprite.scale
		_visual_sprite.scale = target_scale * 0.55
		create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(_visual_sprite, "scale", target_scale, 0.2)

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

func _ensure_visual_sprite() -> void:
	var asset_id := "resource_drop"
	var scale_value := 0.56
	if kind == "stone":
		asset_id = "stone"
		scale_value = 0.48
	elif kind in ["equipment", "island_shard"]:
		asset_id = "legendary_plant" if important or kind == "island_shard" else "hit_burst"
		scale_value = 0.5 if important or kind == "island_shard" else 0.3
	_visual_sprite = VisualAssetLibrary.sprite(asset_id, scale_value)
	_visual_sprite.position = Vector2(0, -7)
	_visual_sprite.z_index = 2
	add_child(_visual_sprite)

func _draw() -> void:
	if kind == "island_shard":
		draw_polyline(PackedVector2Array([Vector2(0, -18), Vector2(16, 0), Vector2(0, 18), Vector2(-16, 0), Vector2(0, -18)]), Color("72e1a5"), 3.0)
	elif kind == "equipment":
		_draw_rarity_cue()

func _draw_rarity_cue() -> void:
	match rarity_cue():
		"cyan_triangle":
			draw_polyline(PackedVector2Array([Vector2(0, -18), Vector2(17, 14), Vector2(-17, 14), Vector2(0, -18)]), Color("72d9ff"), 4.0)
		"blue_diamond":
			draw_polyline(PackedVector2Array([Vector2(0, -20), Vector2(18, 0), Vector2(0, 20), Vector2(-18, 0), Vector2(0, -20)]), Color("6ca8ff"), 4.0)
		"violet_star":
			draw_line(Vector2(0, -48), Vector2(0, 22), Color(0.65, 0.35, 1.0, 0.55), 4.0)
			draw_polyline(_star_points(19.0, 9.0, 5), Color("b96cff"), 4.0)
		"gold_hex_beam":
			draw_line(Vector2(0, -58), Vector2(0, 24), Color(1.0, 0.65, 0.25, 0.72), 7.0)
			draw_polyline(_regular_polygon(20.0, 6), Color("fff0a8"), 5.0)
		_:
			draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 20, Color("a9b1b8"), 3.0)

func _regular_polygon(radius: float, sides: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index: int in sides + 1:
		points.append(Vector2.UP.rotated(TAU * float(index) / float(sides)) * radius)
	return points

func _star_points(outer_radius: float, inner_radius: float, arms: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index: int in arms * 2 + 1:
		var radius_value := outer_radius if index % 2 == 0 else inner_radius
		points.append(Vector2.UP.rotated(PI * float(index) / float(arms)) * radius_value)
	return points
