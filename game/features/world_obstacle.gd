class_name WorldObstacle
extends StaticBody2D

const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")

@export var asset_id: String = "forest_tree"
@export var collision_radius: float = 20.0
@export var visual_scale: float = 4.0

var _visual_sprite: Sprite2D

func _ready() -> void:
	add_to_group("world_obstacle")
	_ensure_collision()
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "CohesiveWorldSprite"
	_visual_sprite.texture = VisualAssetLibrary.world_object_texture(asset_id)
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.scale = Vector2.ONE * visual_scale
	_visual_sprite.position = Vector2(0, -collision_radius * 0.72)
	_visual_sprite.z_index = 1
	add_child(_visual_sprite)
	queue_redraw()

func configure(id_value: String, radius_value: float = 20.0, scale_value: float = 4.0) -> void:
	asset_id = id_value
	collision_radius = maxf(8.0, radius_value)
	visual_scale = maxf(1.0, scale_value)

func blocks_movement() -> bool:
	return true

func deals_contact_damage() -> bool:
	return false

func _ensure_collision() -> void:
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = collision_radius
	collision.shape = shape
	add_child(collision)

func _draw() -> void:
	ContactShadowScript.paint(self, "obstacle", collision_radius * 0.68, clampf(collision_radius * 0.35, 5.0, 9.0))
