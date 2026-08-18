class_name IslandSlot
extends Node2D

var slot_id: String = "east"
var axial_coordinate: Vector2i = Vector2i(1, 0)
var installed: bool = false
var shard_name: String = ""
var shard_biome: String = ""
var materialized: MaterializedIsland
var reject_next_materialization: bool = false
var _visual_sprite: Sprite2D
var _visual_time: float = 0.0
var _visual_installed: bool = false

func _ready() -> void:
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * 1.22
	_visual_sprite.position = Vector2(0, -5)
	_visual_sprite.z_index = 1
	add_child(_visual_sprite)
	_refresh_pedestal()
	set_process(true)

func _process(delta: float) -> void:
	_visual_time += maxf(0.0, delta)
	if installed != _visual_installed:
		_refresh_pedestal()
	if is_instance_valid(_visual_sprite):
		var pulse := PresentationMotion.wave(_visual_time, 0.45, float(abs(slot_id.hash()) % 100) / 100.0)
		_visual_sprite.position.y = -5.0 + pulse * (0.45 if installed else 1.0)
		_visual_sprite.modulate = Color("d8fff2") if installed else Color.WHITE
	queue_redraw()

func configure_slot(id_value: String, coordinate_value: Vector2i) -> void:
	slot_id = id_value
	axial_coordinate = coordinate_value

func set_installed(value: bool, display_name: String = "", biome: String = "") -> void:
	installed = value
	shard_name = display_name
	shard_biome = biome
	_refresh_pedestal()
	queue_redraw()

func materialize(installed_data: Dictionary, effects: Dictionary, indicators: Array[String], player: Node2D) -> bool:
	if reject_next_materialization:
		reject_next_materialization = false
		return false
	var candidate := MaterializedIsland.new()
	if not candidate.configure(slot_id, installed_data, effects, indicators, player):
		return false
	clear_materialized()
	materialized = candidate
	add_child(materialized)
	var definition := installed_data.definition as Dictionary
	set_installed(true, String(definition.name), String(definition.biome))
	return true

func clear_materialized() -> void:
	if is_instance_valid(materialized):
		remove_child(materialized)
		materialized.queue_free()
	materialized = null
	set_installed(false)

func contains_world_position(world_position: Vector2) -> bool:
	return installed and global_position.distance_to(world_position) <= 112.0

func uses_plus_marker() -> bool:
	return false

func _refresh_pedestal() -> void:
	if not is_instance_valid(_visual_sprite):
		return
	_visual_sprite.texture = VisualAssetLibrary.structure_texture("island_pedestal", installed)
	_visual_installed = installed

func _draw() -> void:
	var pulse := PresentationMotion.wave(_visual_time, 0.45, float(abs(slot_id.hash()) % 100) / 100.0) * 2.0
	var shadow := PackedVector2Array([Vector2(-31, 15), Vector2(-18, 8), Vector2(19, 8), Vector2(33, 15), Vector2(18, 22), Vector2(-19, 22)])
	draw_colored_polygon(shadow, Color(0.04, 0.12, 0.12, 0.26))
	if installed:
		return
	var color := Color("5d999c")
	var extent := 39.0 + pulse
	for direction: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var corner := Vector2(direction.x * extent, direction.y * 19.0 + 16.0)
		draw_polyline(PackedVector2Array([corner - Vector2(direction.x * 11.0, 0), corner, corner - Vector2(0, direction.y * 7.0)]), color, 2.0)

func uses_circular_zone_overlay() -> bool:
	return false
