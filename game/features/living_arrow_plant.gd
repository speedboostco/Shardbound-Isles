class_name LivingArrowPlant
extends Node2D

signal expired(plant_id: String)

var plant_id: String = ""
var lifetime: float = 6.0
var attack_interval: float = 0.8
var attack_radius: float = 130.0
var _attack_remaining: float = 0.2

func _ready() -> void:
	add_to_group("temporary_legendary")
	queue_redraw()

func _process(delta: float) -> void:
	lifetime -= delta
	_attack_remaining -= delta
	if _attack_remaining <= 0.0:
		_attack_remaining = attack_interval
		_attack_nearest()
	if lifetime <= 0.0:
		expired.emit(plant_id)
		queue_free()

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
		queue_redraw()

func _draw() -> void:
	draw_line(Vector2(0, 12), Vector2(0, -14), Color("4d9d58"), 5.0)
	draw_circle(Vector2(-8, -12), 8.0, Color("75e58d"))
	draw_circle(Vector2(8, -12), 8.0, Color("75e58d"))
	draw_line(Vector2(0, -10), Vector2(18, -23), Color("d8ffb0"), 3.0)
