class_name IslandStoryEvent
extends StaticBody2D

signal activated(event_id: String, objective_kind: String)

const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")

var stable_id: String = "island_story_event"
var event_type: String = "grove_echo"
var objective_kind: String = "survey_site"
var biome: String = "forest"
var available: bool = true
var _elapsed: float = 0.0
var _sprite: Sprite2D

func configure(id_value: String, event_type_value: String, objective_kind_value: String, biome_value: String) -> void:
	stable_id = id_value
	event_type = event_type_value
	objective_kind = objective_kind_value
	biome = biome_value

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("island_story_event")
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 15.0
	collision.shape = shape
	add_child(collision)
	_sprite = Sprite2D.new()
	_sprite.name = "StoryEventSprite"
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.texture = _texture()
	_sprite.scale = Vector2.ONE * (1.25 if objective_kind == "survey_site" else 2.15)
	_sprite.position = Vector2(0, -18)
	_sprite.z_index = 2
	add_child(_sprite)
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += maxf(0.0, delta)
	if is_instance_valid(_sprite):
		_sprite.position.y = -18.0 + sin(_elapsed * 2.4 + float(stable_id.hash() % 11)) * 1.5
	queue_redraw()

func interaction_id() -> String:
	return "island_story:%s" % stable_id

func interaction_label() -> String:
	if objective_kind == "survey_site":
		return "ATTUNE %s" % _display_name()
	if objective_kind == "restoration_site":
		return "RESTORE %s" % _display_name()
	return "SEVER %s" % _display_name()

func can_interact(player_position: Vector2) -> bool:
	return available and global_position.distance_to(player_position) <= 125.0

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position):
		return false
	available = false
	remove_from_group("interactable")
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", true)
	activated.emit(stable_id, objective_kind)
	queue_free()
	return true

func set_interaction_targeted(targeted: bool) -> void:
	if is_instance_valid(_sprite):
		_sprite.modulate = Color("fff0a4") if targeted else Color.WHITE

func deals_contact_damage() -> bool:
	return false

func _texture() -> Texture2D:
	if objective_kind == "survey_site":
		return VisualAssetLibrary.structure_texture("island_pedestal", true)
	if objective_kind == "restoration_site":
		return VisualAssetLibrary.resource_texture("herb", 0)
	return VisualAssetLibrary.structure_texture("reward_chest", true)

func _display_name() -> String:
	return event_type.replace("_", " ").to_upper()

func _draw() -> void:
	ContactShadowScript.paint(self, "resource", 13.0)
	var color := _biome_color()
	var height := 8.0 + sin(_elapsed * 3.1) * 2.0
	var diamond := PackedVector2Array([Vector2(0, -32 - height), Vector2(7, -25 - height), Vector2(0, -18 - height), Vector2(-7, -25 - height), Vector2(0, -32 - height)])
	draw_polyline(diamond, Color(color, 0.86), 2.0)

func _biome_color() -> Color:
	return {
		"forest": Color("75e6a5"), "swamp": Color("b7d66f"), "volcano": Color("ff8d66"),
		"frozen": Color("8bd8ff"), "graveyard": Color("c1a4ff"), "settlement": Color("ffd36a"),
	}.get(biome, Color.WHITE) as Color

