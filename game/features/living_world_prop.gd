class_name LivingWorldProp
extends Node2D

signal effect_requested(source: LivingWorldProp, effect_id: String, amount: int)
signal availability_changed

@export var prop_id: String = "moonleaf_thicket"
@export var stable_id: String = "living_prop"
@export var interaction_radius: float = 105.0

var target_player: Node2D
var cooldown_remaining: float = 0.0
var external_locked: bool = false
var activation_count: int = 0
var _visual_sprite: Sprite2D
var _visual_time: float = 0.0
var _active_flash_remaining: float = 0.0
var _interaction_targeted: bool = false
var _visual_frame: int = -1
var _base_scale: float = 1.18

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("living_world_prop")
	_ensure_visual()
	set_process(true)
	queue_redraw()

func configure(prop_id_value: String, stable_id_value: String, player_value: Node2D) -> void:
	prop_id = prop_id_value
	stable_id = stable_id_value
	target_player = player_value
	if is_inside_tree():
		_visual_frame = -1
		_update_visual(0.0)

func _process(delta: float) -> void:
	_visual_time += maxf(0.0, delta)
	var was_available := cooldown_remaining <= 0.0 and not external_locked
	cooldown_remaining = maxf(0.0, cooldown_remaining - maxf(0.0, delta))
	_active_flash_remaining = maxf(0.0, _active_flash_remaining - maxf(0.0, delta))
	_update_visual(delta)
	if _interaction_targeted:
		queue_redraw()
	var is_available := cooldown_remaining <= 0.0 and not external_locked
	if was_available != is_available:
		availability_changed.emit()
		queue_redraw()

func interaction_id() -> String:
	return stable_id

func interaction_label() -> String:
	var definition := LivingWorldPropRules.definition(prop_id)
	if cooldown_remaining > 0.0:
		return "%s — READY IN %ds" % [String(definition.get("name", "WORLD PROP")).to_upper(), ceili(cooldown_remaining)]
	if external_locked:
		return "%s — GUARDIAN ACTIVE" % String(definition.get("name", "WORLD PROP")).to_upper()
	if prop_id == "tidewell" and is_instance_valid(target_player) and int(target_player.get("health")) >= int(target_player.get("maximum_health")):
		return "TIDEWELL — HEALTH FULL"
	return String(definition.get("interaction", "INTERACT"))

func can_interact(player_position: Vector2) -> bool:
	if global_position.distance_to(player_position) > interaction_radius or cooldown_remaining > 0.0 or external_locked:
		return false
	if prop_id == "tidewell" and is_instance_valid(target_player):
		return int(target_player.get("health")) < int(target_player.get("maximum_health"))
	return true

func interact(player: Node2D) -> bool:
	if not can_interact(player.global_position):
		return false
	var definition := LivingWorldPropRules.definition(prop_id)
	if definition.is_empty():
		return false
	cooldown_remaining = float(definition.cooldown)
	external_locked = String(definition.effect) == "guardian_challenge"
	_active_flash_remaining = 0.65
	activation_count += 1
	_update_visual(0.0)
	availability_changed.emit()
	effect_requested.emit(self, String(definition.effect), int(definition.amount))
	queue_redraw()
	return true

func complete_challenge() -> void:
	external_locked = false
	availability_changed.emit()
	queue_redraw()

func set_interaction_targeted(value: bool) -> void:
	if _interaction_targeted == value:
		return
	_interaction_targeted = value
	queue_redraw()

func state_frame() -> int:
	if _active_flash_remaining > 0.0:
		return 2
	if cooldown_remaining > 0.0 or external_locked:
		return 3
	return AnimationStateRules.frame_index(_visual_time, 1.4, 2)

func _ensure_visual() -> void:
	if is_instance_valid(_visual_sprite):
		return
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.z_index = 1
	add_child(_visual_sprite)
	_update_visual(0.0)

func _update_visual(delta: float) -> void:
	if not is_instance_valid(_visual_sprite):
		return
	var frame := state_frame()
	if frame != _visual_frame:
		_visual_sprite.texture = VisualAssetLibrary.living_world_texture(prop_id, frame)
		_visual_frame = frame
	var phase := float(abs(stable_id.hash()) % 100) / 100.0
	var wave := PresentationMotion.wave(_visual_time, 0.55, phase)
	var target_position := Vector2(0.0, -14.0 + wave * (1.3 if cooldown_remaining <= 0.0 else 0.35))
	var pulse := 0.035 * wave if cooldown_remaining <= 0.0 else 0.0
	var target_scale := Vector2(_base_scale * (1.0 + pulse), _base_scale * (1.0 - pulse * 0.5))
	var alpha := PresentationMotion.response_alpha(delta, 13.0)
	_visual_sprite.position = _visual_sprite.position.lerp(target_position, alpha)
	_visual_sprite.scale = _visual_sprite.scale.lerp(target_scale, alpha)
	_visual_sprite.modulate = Color("fff1a6") if _active_flash_remaining > 0.0 else (Color("a7b7ad") if cooldown_remaining > 0.0 else Color.WHITE)

func _draw() -> void:
	draw_set_transform(Vector2(0, 20), 0.0, Vector2(1.0, 0.28))
	draw_circle(Vector2.ZERO, 30.0, Color(0.03, 0.08, 0.09, 0.24))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _interaction_targeted:
		var pulse := 2.0 + PresentationMotion.wave(_visual_time, 1.5) * 2.0
		draw_arc(Vector2.ZERO, 39.0 + pulse, 0.0, TAU, 32, Color("8fe7ff"), 3.0)
