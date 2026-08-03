class_name IslandEventMarker
extends Node2D

signal completed(event_id: String)

var event_id: String = "grove_shrine"
var display_name: String = "Grove Shrine"
var claimed: bool = false
var interaction_radius: float = 95.0

func configure(id_value: String, name_value: String, already_claimed: bool) -> void:
	event_id = id_value
	display_name = name_value
	claimed = already_claimed

func _ready() -> void:
	add_to_group("interactable")
	queue_redraw()

func interaction_id() -> String:
	return "island_event_%s" % event_id

func interaction_label() -> String:
	return "CLAIM %s" % display_name.to_upper()

func can_interact(player_position: Vector2) -> bool:
	return not claimed and global_position.distance_to(player_position) <= interaction_radius

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position):
		return false
	claimed = true
	completed.emit(event_id)
	remove_from_group("interactable")
	queue_redraw()
	return true

func _draw() -> void:
	var color := Color("586276") if claimed else Color("d4a8ff")
	draw_circle(Vector2.ZERO, 18.0, Color(0.18, 0.12, 0.28, 0.95))
	draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 24, color, 5.0)
	draw_line(Vector2(0, -18), Vector2(0, 18), color, 4.0)
	draw_line(Vector2(-13, 0), Vector2(13, 0), color, 4.0)
