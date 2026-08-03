class_name IslandSlot
extends Node2D

var slot_id: String = "east"
var axial_coordinate: Vector2i = Vector2i(1, 0)
var installed: bool = false
var shard_name: String = ""
var shard_biome: String = ""
var materialized: MaterializedIsland
var reject_next_materialization: bool = false

func configure_slot(id_value: String, coordinate_value: Vector2i) -> void:
	slot_id = id_value
	axial_coordinate = coordinate_value

func set_installed(value: bool, display_name: String = "", biome: String = "") -> void:
	installed = value
	shard_name = display_name
	shard_biome = biome
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

func _draw() -> void:
	if installed:
		return
	draw_circle(Vector2.ZERO, 67.0, Color(0.2, 0.45, 0.5, 0.16))
	draw_arc(Vector2.ZERO, 69.0, 0.0, TAU, 40, Color("5d999c"), 4.0)
	draw_line(Vector2(-24, 0), Vector2(24, 0), Color("70aeb0"), 3.0)
	draw_line(Vector2(0, -24), Vector2(0, 24), Color("70aeb0"), 3.0)
