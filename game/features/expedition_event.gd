class_name ExpeditionEvent
extends StaticBody2D

signal activated(event_id: String, event_type: String, reward_kind: String, amount: int)

const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")

var stable_id: String = "weather_event"
var event_type: String = "sun_marker"
var reward_kind: String = "moonleaf"
var reward_amount: int = 1
var available: bool = true
var _elapsed: float = 0.0
var _sprite: Sprite2D

func configure(id_value: String, type_value: String) -> void:
	stable_id = id_value
	event_type = type_value
	match event_type:
		"rainbloom":
			reward_kind = "fiber"
		"wisp_cache":
			reward_kind = "moonleaf"
		"windfall":
			reward_kind = "wood"
		_:
			reward_kind = "stone"

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("expedition_event")
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 17.0
	collision.shape = shape
	add_child(collision)
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.texture = _texture()
	var visual_scale := 1.35 if event_type == "wisp_cache" else (1.8 if event_type == "sun_marker" else (2.5 if event_type == "windfall" else 3.0))
	_sprite.scale = Vector2.ONE * visual_scale
	_sprite.position = Vector2(0, -18)
	_sprite.z_index = 2
	add_child(_sprite)
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += maxf(0.0, delta)
	if is_instance_valid(_sprite):
		_sprite.position.y = -18.0 + sin(_elapsed * 2.8 + float(stable_id.hash() % 7)) * 2.0
		_sprite.modulate.a = 0.82 + sin(_elapsed * 3.6) * 0.12
	queue_redraw()

func interaction_id() -> String:
	return "expedition_event:%s" % stable_id

func interaction_label() -> String:
	return {
		"sun_marker": "ATTUNE SUN MARKER",
		"rainbloom": "HARVEST RAINBLOOM",
		"wisp_cache": "OPEN WISP CACHE",
		"windfall": "SEARCH WINDFALL",
	}.get(event_type, "INVESTIGATE WEATHER SIGN") as String

func can_interact(player_position: Vector2) -> bool:
	return available and global_position.distance_to(player_position) <= 145.0

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position):
		return false
	available = false
	remove_from_group("interactable")
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", true)
	activated.emit(stable_id, event_type, reward_kind, reward_amount)
	queue_free()
	return true

func set_interaction_targeted(targeted: bool) -> void:
	if is_instance_valid(_sprite):
		_sprite.modulate = Color("fff2a8") if targeted else Color.WHITE

func deals_contact_damage() -> bool:
	return false

func _texture() -> Texture2D:
	match event_type:
		"rainbloom": return VisualAssetLibrary.resource_texture("herb", 0)
		"wisp_cache": return VisualAssetLibrary.structure_texture("reward_chest", true)
		"windfall": return VisualAssetLibrary.resource_pickup_texture("wood")
		_: return VisualAssetLibrary.structure_texture("island_pedestal", true)

func _draw() -> void:
	ContactShadowScript.paint(self, "resource", 14.0)
	var color := {
		"sun_marker": Color("ffd36a"), "rainbloom": Color("79dca8"),
		"wisp_cache": Color("9bc9ff"), "windfall": Color("e6b46c"),
	}.get(event_type, Color.WHITE) as Color
	var pulse := 1.0 + sin(_elapsed * 3.0) * 0.08
	var points := PackedVector2Array([Vector2(0, -28) * pulse, Vector2(12, -16) * pulse, Vector2(0, -4) * pulse, Vector2(-12, -16) * pulse, Vector2(0, -28) * pulse])
	draw_polyline(points, Color(color, 0.78), 2.0)
