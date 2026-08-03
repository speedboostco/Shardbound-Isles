class_name Workbench
extends StaticBody2D

signal interacted

@export var interaction_radius: float = 105.0

func _ready() -> void:
	add_to_group("interactable")
	queue_redraw()

func is_player_in_range(player_position: Vector2) -> bool:
	return global_position.distance_to(player_position) <= interaction_radius

func interaction_id() -> String:
	return "workbench"

func interaction_label() -> String:
	return "USE WORKBENCH"

func can_interact(player_position: Vector2) -> bool:
	return is_player_in_range(player_position)

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position):
		return false
	interacted.emit()
	return true

func _draw() -> void:
	draw_rect(Rect2(-34.0, -18.0, 68.0, 36.0), Color("9a673c"))
	draw_rect(Rect2(-29.0, 18.0, 10.0, 25.0), Color("513522"))
	draw_rect(Rect2(19.0, 18.0, 10.0, 25.0), Color("513522"))
	draw_rect(Rect2(-40.0, -25.0, 80.0, 12.0), Color("d39a52"))
	draw_circle(Vector2(17.0, -31.0), 10.0, Color("73c7cf"))
	draw_arc(Vector2.ZERO, interaction_radius, 0.0, TAU, 40, Color(0.45, 0.78, 0.75, 0.22), 2.0)
