class_name Tidecatcher
extends Node2D

signal storage_changed(stored: int, capacity: int)
signal wood_collected(amount: int)

@export var collection_radius: float = 85.0
var active: bool = false
var target: Node2D
var production := WoodProduction.new()

func _ready() -> void:
	set_process(false)
	visible = false

func activate(player_target: Node2D) -> bool:
	if active:
		return false
	active = true
	target = player_target
	visible = true
	set_process(true)
	storage_changed.emit(production.stored_wood, WoodProduction.STORAGE_CAPACITY)
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
		queue_redraw()
	return produced

func collect_if_near(player_position: Vector2) -> int:
	if not active or global_position.distance_to(player_position) > collection_radius:
		return 0
	var amount := production.collect()
	if amount > 0:
		storage_changed.emit(0, WoodProduction.STORAGE_CAPACITY)
		wood_collected.emit(amount)
		queue_redraw()
	return amount

func stored_wood() -> int:
	return production.stored_wood

func restore_state(is_active: bool, stored: int, player_target: Node2D) -> void:
	active = is_active
	target = player_target
	production.restore(stored if is_active else 0)
	visible = is_active
	set_process(is_active)
	storage_changed.emit(production.stored_wood, WoodProduction.STORAGE_CAPACITY)
	queue_redraw()

func _draw() -> void:
	if not active:
		return
	draw_rect(Rect2(-26.0, -24.0, 52.0, 50.0), Color("315f68"))
	draw_polygon(PackedVector2Array([Vector2(-35, -24), Vector2(0, -52), Vector2(35, -24)]), PackedColorArray([Color("78c9c4")]))
	draw_rect(Rect2(-18.0, 26.0, 9.0, 25.0), Color("68452d"))
	draw_rect(Rect2(9.0, 26.0, 9.0, 25.0), Color("68452d"))
	for index: int in range(production.stored_wood):
		draw_circle(Vector2(-15.0 + float(index % 3) * 15.0, 3.0 + float(index / 3) * 14.0), 5.0, Color("e2b15e"))
	draw_arc(Vector2.ZERO, collection_radius, 0.0, TAU, 36, Color(0.55, 0.9, 0.82, 0.18), 2.0)
