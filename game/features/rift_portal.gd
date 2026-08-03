class_name RiftPortal
extends Node2D

@export var interaction_radius: float = 95.0
var unlocked: bool = false

func unlock() -> bool:
	if unlocked:
		return false
	unlocked = true
	queue_redraw()
	return true

func is_player_in_range(player_position: Vector2) -> bool:
	return unlocked and global_position.distance_to(player_position) <= interaction_radius

func _draw() -> void:
	var outer := Color("b57bff") if unlocked else Color(0.35, 0.4, 0.48, 0.35)
	draw_arc(Vector2.ZERO, 48.0, 0.0, TAU, 40, outer, 7.0)
	draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 32, outer.darkened(0.2), 6.0)
	if unlocked:
		draw_circle(Vector2.ZERO, 20.0, Color(0.45, 0.2, 0.7, 0.72))
		draw_arc(Vector2.ZERO, interaction_radius, 0.0, TAU, 40, Color(0.7, 0.48, 1.0, 0.2), 2.0)
	else:
		draw_line(Vector2(-18, -18), Vector2(18, 18), outer, 5.0)

