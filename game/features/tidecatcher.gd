class_name Tidecatcher
extends StaticBody2D

signal storage_changed(stored: int, capacity: int)
signal wood_collected(amount: int)

@export var collection_radius: float = 85.0
var active: bool = false
var target: Node2D
var production := WoodProduction.new()
var _visual_sprite: Sprite2D
var _collision: CollisionShape2D

func _ready() -> void:
	_collision = CollisionShape2D.new()
	_collision.name = "CollisionShape2D"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(64, 46)
	_collision.shape = shape
	_collision.disabled = true
	add_child(_collision)
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * 1.45
	_visual_sprite.position = Vector2(0, -14)
	_visual_sprite.z_index = 1
	add_child(_visual_sprite)
	_refresh_visual()
	set_process(false)
	visible = false

func activate(player_target: Node2D) -> bool:
	if active:
		return false
	active = true
	target = player_target
	visible = true
	_collision.disabled = false
	set_process(true)
	storage_changed.emit(production.stored_wood, WoodProduction.STORAGE_CAPACITY)
	_refresh_visual()
	queue_redraw()
	return true

func _process(delta: float) -> void:
	advance_production(delta)
	if is_instance_valid(target):
		collect_if_near(target.global_position)

func advance_production(delta_seconds: float) -> int:
	if not active:
		return 0
	var produced := production.advance(delta_seconds)
	if produced > 0:
		storage_changed.emit(production.stored_wood, WoodProduction.STORAGE_CAPACITY)
		_refresh_visual()
		queue_redraw()
	return produced

func collect_if_near(player_position: Vector2) -> int:
	if not active or global_position.distance_to(player_position) > collection_radius:
		return 0
	var amount := production.collect()
	if amount > 0:
		storage_changed.emit(0, WoodProduction.STORAGE_CAPACITY)
		wood_collected.emit(amount)
		_refresh_visual()
		queue_redraw()
	return amount

func stored_wood() -> int:
	return production.stored_wood

func set_production_interval_multiplier(value: float) -> void:
	production.set_interval_multiplier(value)

func production_interval_multiplier() -> float:
	return production.interval_multiplier()

func restore_state(is_active: bool, stored: int, player_target: Node2D) -> void:
	active = is_active
	target = player_target
	production.restore(stored if is_active else 0)
	visible = is_active
	_collision.disabled = not is_active
	set_process(is_active)
	storage_changed.emit(production.stored_wood, WoodProduction.STORAGE_CAPACITY)
	_refresh_visual()
	queue_redraw()

func _refresh_visual() -> void:
	if is_instance_valid(_visual_sprite):
		_visual_sprite.texture = VisualAssetLibrary.structure_texture("tidecatcher", production.stored_wood > 0)

func _draw() -> void:
	if not active:
		return
	draw_arc(Vector2.ZERO, collection_radius, 0.0, TAU, 36, Color(0.55, 0.9, 0.82, 0.18), 2.0)
