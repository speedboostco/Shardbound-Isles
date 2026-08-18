class_name StartingIslandTerrain
extends StaticBody2D

const GROUND_TEXTURE: Texture2D = preload("res://assets/original/emberwood/emberwood_starting_island_v4.png")
const SHORELINE: Array[Vector2] = [
	Vector2(-650, -492), Vector2(-340, -548), Vector2(20, -540), Vector2(390, -526),
	Vector2(705, -468), Vector2(838, -286), Vector2(850, 10), Vector2(805, 290),
	Vector2(690, 472), Vector2(410, 530), Vector2(40, 518), Vector2(-390, 530),
	Vector2(-710, 462), Vector2(-844, 270), Vector2(-852, -65), Vector2(-782, -362),
]

func _ready() -> void:
	z_index = -100
	collision_layer = 1
	collision_mask = 0
	var ground := Sprite2D.new()
	ground.name = "GroundPlate"
	ground.texture = GROUND_TEXTURE
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground.centered = true
	add_child(ground)
	var shore := CollisionPolygon2D.new()
	shore.name = "ShoreCollision"
	shore.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	shore.polygon = PackedVector2Array(SHORELINE)
	add_child(shore)

func micro_biome_count() -> int:
	return 4

func detail_cluster_count() -> int:
	return 128

func has_shore_collision() -> bool:
	var shore := get_node_or_null("ShoreCollision") as CollisionPolygon2D
	return shore != null and shore.polygon.size() == SHORELINE.size()

func uses_plus_terrain_markers() -> bool:
	return false
