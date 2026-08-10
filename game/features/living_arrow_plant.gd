class_name LivingArrowPlant
extends Node2D

signal expired(plant_id: String)

var plant_id: String = ""
var lifetime: float = 6.0
var attack_interval: float = 0.8
var attack_radius: float = 130.0
var _attack_remaining: float = 0.2
var _attack_flash_remaining: float = 0.0
var _visual_sprite: Sprite2D
var _active: bool = true

func _ready() -> void:
	add_to_group("temporary_legendary")
	_visual_sprite = VisualAssetLibrary.sprite("legendary_plant", 0.72)
	_visual_sprite.position = Vector2(0, -14)
	add_child(_visual_sprite)
	queue_redraw()

func _process(delta: float) -> void:
	if not _active:
		return
	lifetime -= delta
	_attack_remaining -= delta
	_attack_flash_remaining = maxf(0.0, _attack_flash_remaining - delta)
	if is_instance_valid(_visual_sprite):
		_visual_sprite.scale = Vector2.ONE * (0.78 if _attack_flash_remaining > 0.0 else 0.72)
	if _attack_remaining <= 0.0:
		_attack_remaining = attack_interval
		_attack_nearest()
	if lifetime <= 0.0:
		cleanup()

func _attack_nearest() -> void:
	var selected: Node2D
	var selected_distance := attack_radius
	for candidate: Node in get_tree().get_nodes_in_group("attackable"):
		if not (candidate is ChaserEnemy or candidate is RangedEnemy or candidate is AbyssalWarden):
			continue
		var node := candidate as Node2D
		var distance := global_position.distance_to(node.global_position)
		if distance < selected_distance:
			selected = node
			selected_distance = distance
	if is_instance_valid(selected) and selected.has_method("receive_attack"):
		selected.receive_attack(1)
		_attack_flash_remaining = 0.15
		queue_redraw()

func cleanup() -> void:
	if not _active:
		return
	_active = false
	set_process(false)
	remove_from_group("temporary_legendary")
	expired.emit(plant_id)
	queue_free()

func is_active() -> bool:
	return _active

func _draw() -> void:
	draw_set_transform(Vector2(0, 12), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 22.0, Color(0.03, 0.08, 0.09, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _attack_flash_remaining > 0.0:
		draw_line(Vector2(0, -18), Vector2(34, -34), Color("d8ffb0"), 4.0)
