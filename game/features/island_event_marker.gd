class_name IslandEventMarker
extends Node2D

signal completed(event_id: String)

var event_id: String = "grove_shrine"
var display_name: String = "Grove Shrine"
var claimed: bool = false
var interaction_radius: float = 95.0
var _visual_sprite: Sprite2D

func configure(id_value: String, name_value: String, already_claimed: bool) -> void:
	event_id = id_value
	display_name = name_value
	claimed = already_claimed

func _ready() -> void:
	add_to_group("interactable")
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture = VisualAssetLibrary.structure_texture("island_event")
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * 1.25
	_visual_sprite.position = Vector2(0, -9)
	_visual_sprite.z_index = 1
	_visual_sprite.modulate = Color(0.48, 0.52, 0.56, 0.75) if claimed else Color.WHITE
	add_child(_visual_sprite)
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
	_visual_sprite.modulate = Color(0.48, 0.52, 0.56, 0.75)
	completed.emit(event_id)
	remove_from_group("interactable")
	queue_redraw()
	return true

func _draw() -> void:
	if not claimed:
		draw_arc(Vector2(0, 5), 38.0, 0.0, TAU, 28, Color(0.62, 0.9, 0.75, 0.22), 2.0)
