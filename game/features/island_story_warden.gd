class_name IslandStoryWarden
extends CharacterBody2D

signal volley_requested(origin: Vector2, direction: Vector2, angles: Array[float], damage: int)
signal defeated(position_value: Vector2, loot_seed: int)
signal phase_changed(new_phase: int)
signal cue_requested(cue_id: String, position_value: Vector2)

const HealthComponentScript := preload("res://game/core/health_component.gd")
const ForestWardenAudioScript := preload("res://game/features/forest_warden_audio.gd")
const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")
const MAXIMUM_HEALTH := 12

var quest_id: String = ""
var biome: String = "forest"
var display_name: String = "SHARD WARDEN"
var loot_seed: int = 0
var elite: bool = true
var target: Node2D
var move_speed := 54.0
var phase := 1
var health_component: Variant
var remaining_health: int:
	get: return health_component.current if health_component != null else MAXIMUM_HEALTH

var _visual_sprite: Sprite2D
var _audio: Variant
var _cooldown_remaining := 0.80
var _telegraph_remaining := 0.0
var _impact_remaining := 0.0
var _hit_flash_remaining := 0.0
var _attack_index := 0
var _current_attack := ""
var _attack_direction := Vector2.RIGHT
var _visual_state := AnimationStateRules.IDLE
var _visual_elapsed := 0.0
var _visual_frame_key := ""
var _dead := false

func configure(quest_id_value: String, biome_value: String, name_value: String, seed_value: int) -> void:
	quest_id = quest_id_value
	biome = biome_value
	display_name = name_value
	loot_seed = seed_value

func _ready() -> void:
	_ensure_collision()
	health_component = HealthComponentScript.new(MAXIMUM_HEALTH)
	health_component.died.connect(_on_died)
	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "ForestWardenSprite" if biome == "forest" else "ShardWardenSprite"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.z_index = 2
	add_child(_visual_sprite)
	_audio = ForestWardenAudioScript.new()
	_audio.name = "ForestWardenAudio"
	add_child(_audio)
	add_to_group("attackable")
	add_to_group("island_story_warden")
	_update_visual()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if _dead:
		return
	health_component.advance(delta)
	_hit_flash_remaining = maxf(0.0, _hit_flash_remaining - delta)
	_impact_remaining = maxf(0.0, _impact_remaining - delta)
	advance_attack(delta)
	if not is_instance_valid(target) or is_telegraphing() or _impact_remaining > 0.0:
		velocity = Vector2.ZERO
		_update_visual(delta)
		queue_redraw()
		return
	var distance := global_position.distance_to(target.global_position)
	if distance < 125.0:
		velocity = target.global_position.direction_to(global_position) * move_speed
	elif distance > 205.0:
		velocity = global_position.direction_to(target.global_position) * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	_update_visual(delta)
	queue_redraw()

func advance_attack(delta: float) -> void:
	if _dead or not is_instance_valid(target) or delta <= 0.0:
		return
	if _telegraph_remaining > 0.0:
		_telegraph_remaining = maxf(0.0, _telegraph_remaining - delta)
		if _telegraph_remaining <= 0.0:
			_resolve_current_attack()
		return
	if _impact_remaining > 0.0:
		return
	_cooldown_remaining -= delta
	if _cooldown_remaining <= 0.0:
		begin_attack()

func begin_attack(attack_override: String = "") -> bool:
	if _dead or not is_instance_valid(target) or is_telegraphing() or _impact_remaining > 0.0:
		return false
	_current_attack = attack_override if attack_override in [ForestWardenPattern.THORN_VOLLEY, ForestWardenPattern.ROOT_ERUPTION] else ForestWardenPattern.attack_kind(loot_seed, _attack_index, phase)
	_attack_index += 1
	_attack_direction = global_position.direction_to(target.global_position)
	if _attack_direction.is_zero_approx():
		_attack_direction = Vector2.RIGHT
	_telegraph_remaining = ForestWardenPattern.telegraph_seconds(_current_attack, phase)
	_visual_elapsed = 0.0
	_audio.play_cue("windup")
	cue_requested.emit("%s_windup" % _current_attack, global_position)
	_update_visual()
	queue_redraw()
	return true

func _resolve_current_attack() -> void:
	if _current_attack == ForestWardenPattern.THORN_VOLLEY:
		volley_requested.emit(global_position, _attack_direction, ForestWardenPattern.thorn_angles(phase), 1)
		_impact_remaining = 0.14
	else:
		if is_instance_valid(target) and ForestWardenPattern.root_lane_contains(global_position, _attack_direction, target.global_position) and target.has_method("take_damage"):
			target.take_damage(2)
		_impact_remaining = 0.24
	_audio.play_cue("impact")
	cue_requested.emit("%s_impact" % _current_attack, global_position)
	_cooldown_remaining = ForestWardenPattern.cooldown_seconds(phase)
	queue_redraw()

func receive_attack(damage: int) -> void:
	if _dead or damage <= 0:
		return
	if not health_component.damage(damage):
		return
	if _dead:
		return
	_hit_flash_remaining = 0.13
	_audio.play_cue("hit")
	if remaining_health > 0:
		var next_phase := ForestWardenPattern.phase_for_health(remaining_health, MAXIMUM_HEALTH)
		if next_phase != phase:
			phase = next_phase
			move_speed = 72.0
			_cooldown_remaining = minf(_cooldown_remaining, 0.32)
			_audio.play_cue("phase")
			phase_changed.emit(phase)
			cue_requested.emit("phase_two", global_position)
	_update_visual()
	queue_redraw()

func _on_died() -> void:
	if _dead:
		return
	_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	remove_from_group("attackable")
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", true)
	_audio.play_cue("defeat")
	cue_requested.emit("defeat", global_position)
	_update_visual()
	defeated.emit(global_position, loot_seed)
	var tween := create_tween()
	tween.tween_interval(0.20)
	tween.tween_callback(func() -> void:
		_visual_elapsed = 0.22
		_update_visual()
	)
	tween.tween_interval(0.36)
	tween.tween_callback(queue_free)

func is_telegraphing() -> bool:
	return _telegraph_remaining > 0.0

func current_attack_kind() -> String:
	return _current_attack

func telegraph_seconds_remaining() -> float:
	return _telegraph_remaining

func current_root_lane() -> PackedVector2Array:
	return ForestWardenPattern.root_lane_polygon(global_position, _attack_direction)

func animation_state() -> String:
	return _visual_state

func presentation_asset_path() -> String:
	return VisualAssetLibrary.FOREST_WARDEN_V1_ATLAS.resource_path if biome == "forest" else VisualAssetLibrary.PUNY_MAGE_ATLAS.resource_path

func audio_profile() -> String:
	return _audio.audio_profile() if is_instance_valid(_audio) else ""

func has_audio_layer() -> bool:
	return is_instance_valid(_audio) and _audio.has_audio_layer()

func audio_cue_is_ready(cue_id: String) -> bool:
	var stream: AudioStreamWAV = _audio.stream_for(cue_id) if is_instance_valid(_audio) else null
	return stream != null and stream.data.size() > 0 and stream.mix_rate == ForestWardenAudioScript.SAMPLE_RATE

func audio_cue_count() -> int:
	return _audio.played_cues.size() if is_instance_valid(_audio) else 0

func last_audio_cue() -> String:
	return _audio.last_cue if is_instance_valid(_audio) else ""

func deals_contact_damage() -> bool:
	return false

func uses_circular_combat_overlay() -> bool:
	return false

func _ensure_collision() -> void:
	if get_node_or_null("CollisionShape2D") != null:
		return
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 22.0 if biome == "forest" else 17.0
	collision.shape = shape
	add_child(collision)

func _update_visual(delta: float = 0.0) -> void:
	if not is_instance_valid(_visual_sprite):
		return
	var state_name := AnimationStateRules.resolve(_dead, _hit_flash_remaining > 0.0, is_telegraphing() or _impact_remaining > 0.0, not velocity.is_zero_approx())
	if state_name != _visual_state:
		_visual_state = state_name
		_visual_elapsed = 0.0
	else:
		_visual_elapsed += maxf(0.0, delta)
	var frame_count := VisualAssetLibrary.forest_warden_frame_count(state_name) if biome == "forest" else VisualAssetLibrary.animation_frame_count("ranger", state_name, "south", true)
	var frames_per_second := 8.0 if state_name in [AnimationStateRules.MOVE, AnimationStateRules.ATTACK] else 6.0
	var frame := AnimationStateRules.frame_index(_visual_elapsed, frames_per_second, frame_count, state_name not in [AnimationStateRules.ATTACK, AnimationStateRules.DEATH])
	var frame_key := "%s:%s:%d" % [biome, state_name, frame]
	if frame_key != _visual_frame_key:
		_visual_sprite.texture = VisualAssetLibrary.forest_warden_texture(state_name, frame) if biome == "forest" else VisualAssetLibrary.animation_texture("ranger", state_name, "south", frame, true)
		_visual_frame_key = frame_key
	if biome == "forest":
		_visual_sprite.position = Vector2(0, -31)
		_visual_sprite.scale = Vector2.ONE * 1.62
	else:
		_visual_sprite.position = Vector2(0, -18)
		_visual_sprite.scale = Vector2.ONE * 3.55
	if is_instance_valid(target):
		_visual_sprite.flip_h = target.global_position.x < global_position.x
	_visual_sprite.modulate = Color("fff0b8") if _hit_flash_remaining > 0.0 else (Color("b9fff1") if phase == 2 and biome == "forest" else Color.WHITE)

func _draw() -> void:
	ContactShadowScript.paint(self, "ranged_enemy", 22.0 if biome == "forest" else 17.0)
	if _dead:
		return
	var health_ratio := float(remaining_health) / float(MAXIMUM_HEALTH)
	draw_rect(Rect2(-46, -89, 92, 8), Color("172331"))
	draw_rect(Rect2(-43, -86, 86.0 * health_ratio, 3), Color("75e6a5") if phase == 1 else Color("8fe7ff"))
	if is_telegraphing():
		if _current_attack == ForestWardenPattern.ROOT_ERUPTION:
			var global_polygon := ForestWardenPattern.root_lane_polygon(global_position, _attack_direction)
			var local_polygon := PackedVector2Array()
			for point: Vector2 in global_polygon:
				local_polygon.append(to_local(point))
			draw_colored_polygon(local_polygon, Color(0.35, 0.82, 0.48, 0.22 if phase == 1 else 0.30))
			for distance: float in [62.0, 112.0, 162.0, 212.0]:
				var center := _attack_direction * distance
				var side := _attack_direction.orthogonal() * 13.0
				draw_polyline(PackedVector2Array([center - side, center + _attack_direction * 13.0, center + side]), Color("8ff0a9"), 3.0)
		else:
			for angle: float in ForestWardenPattern.thorn_angles(phase):
				var direction := _attack_direction.rotated(angle)
				draw_line(direction * 28.0, direction * 210.0, Color(0.72, 1.0, 0.78, 0.72), 3.0)
	if _impact_remaining > 0.0 and _current_attack == ForestWardenPattern.ROOT_ERUPTION:
		for distance: float in [48.0, 88.0, 128.0, 168.0, 208.0]:
			var center := _attack_direction * distance
			var side := _attack_direction.orthogonal() * (10.0 + fmod(distance, 21.0))
			draw_polyline(PackedVector2Array([center - side, center, center + side]), Color("e5a84b"), 5.0)
