class_name WorldResident
extends StaticBody2D

signal spoken(resident_name: String, message: String)

const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")

var stable_id: String = "resident"
var display_name: String = "ISLANDER"
var role: String = "EXPLORER"
var messages: Array[String] = []
var actor_id: String = "hero_unarmed"
var _message_index: int = 0
var _elapsed: float = 0.0
var _sprite: Sprite2D

func configure(id_value: String, name_value: String, role_value: String, message_values: Array, actor_value: String = "hero_unarmed") -> void:
	stable_id = id_value
	display_name = name_value
	role = role_value
	messages.clear()
	for value: Variant in message_values:
		messages.append(String(value))
	actor_id = actor_value

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("world_resident")
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 15.0
	collision.shape = shape
	add_child(collision)
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2.ONE * 3.2
	_sprite.position = Vector2(0, -20)
	_sprite.z_index = 2
	add_child(_sprite)
	_update_frame()
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	_update_frame()

func _update_frame() -> void:
	if not is_instance_valid(_sprite):
		return
	var count := VisualAssetLibrary.animation_frame_count(actor_id, "idle", "south")
	var frame := int(floor(_elapsed * 5.0)) % maxi(1, count)
	_sprite.texture = VisualAssetLibrary.animation_texture(actor_id, "idle", "south", frame, actor_id == "boss")

func interaction_id() -> String:
	return "resident:%s" % stable_id

func interaction_label() -> String:
	return "TALK — %s, %s" % [display_name, role]

func can_interact(player_position: Vector2) -> bool:
	return global_position.distance_to(player_position) <= 145.0

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position) or messages.is_empty():
		return false
	spoken.emit(display_name, messages[_message_index])
	_message_index = posmod(_message_index + 1, messages.size())
	return true

func set_interaction_targeted(_targeted: bool) -> void:
	pass

func deals_contact_damage() -> bool:
	return false

func _draw() -> void:
	ContactShadowScript.paint(self, "resident")
