class_name BaseBuildingVisual
extends StaticBody2D

var building_id: String = "shared_storage"
var preview: bool = false
var placement_valid: bool = true
var facing_degrees: int = 0
var _animation_sprite: Sprite2D
var _visual_time: float = 0.0
var _visual_frame: int = -1

func _ready() -> void:
	set_process(true)
	_ensure_collision()
	_refresh_animation_sprite()

func _process(delta: float) -> void:
	_visual_time += maxf(0.0, delta)
	if is_instance_valid(_animation_sprite):
		var frame := AnimationStateRules.frame_index(_visual_time, 1.8, 2)
		if frame != _visual_frame:
			var active_frame := frame == 1 and building_id in ["lumber_mill", "collector"]
			_animation_sprite.texture = VisualAssetLibrary.structure_texture(building_id, active_frame)
			_visual_frame = frame
		var active_motion := building_id in ["lumber_mill", "collector"] and not preview
		var wave := PresentationMotion.wave(_visual_time, 0.7, float(abs(building_id.hash()) % 100) / 100.0)
		_animation_sprite.position.y = -15.0 + (wave * 0.75 if active_motion else 0.0)
		var pulse := wave * 0.012 if active_motion else 0.0
		_animation_sprite.scale = Vector2(1.42 * (1.0 + pulse), 1.42 * (1.0 - pulse))
	queue_redraw()

func configure(id_value: String, preview_value: bool = false, valid_value: bool = true, rotation_value: int = 0) -> void:
	building_id = id_value
	preview = preview_value
	placement_valid = valid_value
	facing_degrees = posmod(rotation_value, 360)
	rotation_degrees = float(facing_degrees)
	if is_inside_tree():
		_ensure_collision()
	_refresh_animation_sprite()
	queue_redraw()

func _ensure_collision() -> void:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null:
		collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(58, 42)
		collision.shape = shape
		add_child(collision)
	collision.disabled = preview

func _refresh_animation_sprite() -> void:
	if not is_inside_tree():
		return
	if not is_instance_valid(_animation_sprite):
		_animation_sprite = Sprite2D.new()
		_animation_sprite.name = "EmberwoodSprite"
		_animation_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_animation_sprite.scale = Vector2.ONE * 1.42
		_animation_sprite.position = Vector2(0, -15)
		_animation_sprite.z_index = 1
		add_child(_animation_sprite)
	_animation_sprite.modulate = Color(1, 1, 1, 0.58 if preview else 1.0)
	_visual_frame = -1

func _draw() -> void:
	var tint := Color("59d98e") if placement_valid else Color("ef5c68")
	var outline := Color(tint.r, tint.g, tint.b, 0.95 if preview else 0.55)
	if preview:
		draw_arc(Vector2.ZERO, 51.0, 0.0, TAU, 32, outline, 4.0)
		draw_colored_polygon(PackedVector2Array([Vector2(50, 0), Vector2(35, -8), Vector2(35, 8)]), outline)
