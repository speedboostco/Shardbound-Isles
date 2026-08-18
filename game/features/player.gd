class_name PlayerCharacter
extends CharacterBody2D

signal attack_requested(origin: Vector2, direction: Vector2)
signal interaction_requested
signal moved(position_value: Vector2)
signal health_changed(current: int, maximum: int)
signal mana_changed(current: float, maximum: float)
signal mana_spend_failed(required: float, current: float)
signal defeated

const MovementRulesScript := preload("res://game/core/movement_rules.gd")
const HealthComponentScript := preload("res://game/core/health_component.gd")
const ManaPoolScript := preload("res://game/core/mana_pool.gd")
const WeaponAimIndicatorScript := preload("res://game/features/weapon_aim_indicator.gd")
const ContactShadowScript := preload("res://game/ui/contact_shadow.gd")
const BASE_ATTACK_INTERVAL: float = 0.28
const MAGIC_ATTACK_MANA_COST: float = 14.0
const VISUAL_SCALE: float = 3.4
const VISUAL_OFFSET_Y: float = -20.0
const VISUAL_ATTACK_DURATION: float = 0.52
const VISUAL_HIT_DURATION: float = 0.34
const VISUAL_DEATH_DURATION: float = 0.9

@export var move_speed: float = 240.0
var health_component: Variant = HealthComponentScript.new(10, 0.45)
var mana_pool: Variant = ManaPoolScript.new(60.0, 6.0)
var maximum_health: int:
	get: return health_component.maximum
	set(value): health_component.set_maximum(value)
var health: int:
	get: return health_component.current
	set(value): health_component.set_current(clampi(value, 0, health_component.maximum))
var attack_damage: int = 1
var attack_speed: float = 1.0
var weapon_base_type: String = "unarmed"
var legendary_affix_id: String = ""
var legendary_effect_ids: Array[String] = []
var attack_profile: Dictionary = {"style": "slash", "range": 78.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0}
var pickup_radius: float = 135.0
var gathering_power: float = 1.0
var critical_chance: float = 0.05
var critical_damage: float = 1.5
var facing: Vector2 = Vector2.RIGHT
var input_enabled: bool = true
var _attack_cooldown: float = 0.0
var _attack_flash_remaining: float = 0.0
var _hit_flash_remaining: float = 0.0
var _death_flash_remaining: float = 0.0
var _visual_sprite: Sprite2D
var _aim_indicator: Variant
var _visual_facing: String = "east"
var _visual_asset_id: String = ""
var _visual_time: float = 0.0
var _visual_state_name: String = AnimationStateRules.IDLE
var _visual_state_elapsed: float = 0.0
var _animation_attack_triggers: int = 0

func _ready() -> void:
	health_component.changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	mana_pool.changed.connect(_on_mana_changed)
	mana_pool.spend_failed.connect(func(required: float, current: float) -> void: mana_spend_failed.emit(required, current))
	_ensure_collision_shape()
	_ensure_visual_sprite()
	_ensure_aim_indicator()
	queue_redraw()
	health_changed.emit(health, maximum_health)
	mana_changed.emit(mana_pool.current, mana_pool.maximum)

func _physics_process(delta: float) -> void:
	health_component.advance(delta)
	mana_pool.regenerate(delta)
	var attack_was_visible: bool = _attack_flash_remaining > 0.0
	var hit_was_visible: bool = _hit_flash_remaining > 0.0 or bool(health_component.is_invulnerable())
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_attack_flash_remaining = maxf(0.0, _attack_flash_remaining - delta)
	_hit_flash_remaining = maxf(0.0, _hit_flash_remaining - delta)
	_death_flash_remaining = maxf(0.0, _death_flash_remaining - delta)
	if attack_was_visible != (_attack_flash_remaining > 0.0) or hit_was_visible != (_hit_flash_remaining > 0.0 or health_component.is_invulnerable()):
		queue_redraw()
	if not input_enabled:
		velocity = Vector2.ZERO
		_update_visual(delta)
		return
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not input_vector.is_zero_approx():
		facing = input_vector.normalized()
	var previous_position := global_position
	velocity = MovementRulesScript.velocity(input_vector, move_speed)
	move_and_slide()
	global_position.x = clampf(global_position.x, -850.0, 850.0)
	global_position.y = clampf(global_position.y, -550.0, 550.0)
	if not global_position.is_equal_approx(previous_position):
		moved.emit(global_position)
	if Input.is_action_just_pressed("attack"):
		request_attack()
	if Input.is_action_just_pressed("interact"):
		interaction_requested.emit()
	_update_visual(delta)

func request_attack() -> bool:
	if _attack_cooldown > 0.0:
		return false
	if weapon_base_type == "magic" and not mana_pool.spend(MAGIC_ATTACK_MANA_COST):
		return false
	_attack_cooldown = BASE_ATTACK_INTERVAL / maxf(0.1, attack_speed)
	_attack_flash_remaining = VISUAL_ATTACK_DURATION
	_visual_state_elapsed = 0.0
	_animation_attack_triggers += 1
	_update_visual(0.0)
	queue_redraw()
	attack_requested.emit(global_position, facing)
	return true

func confirm_hit() -> void:
	_hit_flash_remaining = VISUAL_HIT_DURATION
	queue_redraw()

func visual_state() -> Dictionary:
	return {
		"facing": _visual_facing,
		"state": _visual_state_name,
		"moving": not velocity.is_zero_approx(),
		"attacking": _attack_flash_remaining > 0.0,
		"hit_reaction": _hit_flash_remaining > 0.0,
	}

func animation_attack_trigger_count() -> int:
	return _animation_attack_triggers

func has_persistent_selection_circle() -> bool:
	return false

func has_persistent_weapon_line() -> bool:
	return false

func uses_circular_combat_overlay() -> bool:
	return false

func attack_cooldown_remaining() -> float:
	return _attack_cooldown

func is_hit_feedback_active() -> bool:
	return _hit_flash_remaining > 0.0

func set_weapon_stats(damage_value: int, speed_value: float, base_type_value: String, affix_id: String = "", profile: Dictionary = {}, effect_ids: Array[String] = []) -> void:
	attack_damage = maxi(1, damage_value)
	attack_speed = maxf(0.1, speed_value)
	weapon_base_type = base_type_value if not base_type_value.is_empty() else "unarmed"
	legendary_affix_id = affix_id
	legendary_effect_ids = effect_ids.duplicate()
	if not affix_id.is_empty() and affix_id not in legendary_effect_ids:
		legendary_effect_ids.append(affix_id)
	attack_profile = profile.duplicate(true) if not profile.is_empty() else _default_attack_profile(weapon_base_type)
	_visual_asset_id = ""
	_update_aim_indicator()
	_update_visual(0.0)
	queue_redraw()

func set_derived_stats(stats: Dictionary) -> void:
	move_speed = maxf(1.0, float(stats.get("movement_speed", move_speed)))
	pickup_radius = maxf(0.0, float(stats.get("pickup_radius", pickup_radius)))
	gathering_power = maxf(0.1, float(stats.get("gathering_power", gathering_power)))
	critical_chance = clampf(float(stats.get("critical_chance", critical_chance)), 0.0, 1.0)
	critical_damage = maxf(1.0, float(stats.get("critical_damage", critical_damage)))

func _default_attack_profile(base_type: String) -> Dictionary:
	if base_type == "magic":
		return {"style": "arcane_strike", "range": 78.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0}
	var canonical := "bow" if base_type == "ranged" else ("sword" if base_type == "melee" else base_type)
	var definition := ItemBaseRegistry.get_definition(canonical)
	return (definition.get("attack_profile", {"style": "slash", "range": 78.0, "minimum_dot": 0.2, "maximum_targets": 1, "splash_radius": 0.0}) as Dictionary).duplicate(true)

func take_damage(amount: int) -> bool:
	var applied: bool = health_component.damage(amount)
	if applied:
		_hit_flash_remaining = VISUAL_HIT_DURATION
		queue_redraw()
	return applied

func add_maximum_health(amount: int) -> void:
	if amount <= 0:
		return
	health_component.set_maximum(maximum_health + amount, true)

func _on_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)
	queue_redraw()

func _on_mana_changed(current: float, maximum: float) -> void:
	mana_changed.emit(current, maximum)

func _on_died() -> void:
	_death_flash_remaining = VISUAL_DEATH_DURATION
	_update_visual(0.0)
	defeated.emit()
	global_position = Vector2.ZERO
	health_component.revive()
	moved.emit(global_position)

func _ensure_collision_shape() -> void:
	if get_node_or_null("CollisionShape2D") != null:
		return
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	collision.shape = shape
	collision.name = "CollisionShape2D"
	add_child(collision)

func _ensure_visual_sprite() -> void:
	if is_instance_valid(_visual_sprite):
		return
	_visual_sprite = Sprite2D.new()
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual_sprite.name = "EmberwoodSprite"
	_visual_sprite.scale = Vector2.ONE * VISUAL_SCALE
	_visual_sprite.position = Vector2(0, VISUAL_OFFSET_Y)
	_visual_sprite.z_index = 2
	add_child(_visual_sprite)

func _ensure_aim_indicator() -> void:
	if is_instance_valid(_aim_indicator):
		return
	_aim_indicator = WeaponAimIndicatorScript.new() as Node2D
	_aim_indicator.name = "WeaponAimIndicator"
	_aim_indicator.z_index = 1
	add_child(_aim_indicator)
	_update_aim_indicator()

func _update_aim_indicator() -> void:
	if not is_instance_valid(_aim_indicator):
		return
	_aim_indicator.configure(weapon_base_type, facing, float(attack_profile.get("range", 78.0)), input_enabled)

func has_weapon_aim_indicator() -> bool:
	return is_instance_valid(_aim_indicator) and _aim_indicator.visible

func _update_visual(delta: float) -> void:
	if not is_instance_valid(_visual_sprite):
		return
	_visual_time += maxf(0.0, delta)
	_visual_facing = FacingRules.resolve(facing, _visual_facing)
	_update_aim_indicator()
	var state_name := AnimationStateRules.resolve(_death_flash_remaining > 0.0, _hit_flash_remaining > 0.0, _attack_flash_remaining > 0.0, not velocity.is_zero_approx())
	if state_name != _visual_state_name:
		_visual_state_name = state_name
		_visual_state_elapsed = 0.0
	else:
		_visual_state_elapsed += maxf(0.0, delta)
	var hero_actor_id := VisualAssetLibrary.hero_actor_id_for_weapon(weapon_base_type)
	var frame_count := VisualAssetLibrary.animation_frame_count(hero_actor_id, state_name, _visual_facing)
	var frames_per_second := _visual_frames_per_second(state_name, frame_count)
	var frame := AnimationStateRules.frame_index(_visual_state_elapsed, frames_per_second, frame_count, AnimationStateRules.loops(state_name))
	var asset_id := "%s:%s:%s:%d" % [hero_actor_id, _visual_facing, state_name, frame]
	if asset_id != _visual_asset_id:
		_visual_sprite.texture = VisualAssetLibrary.animation_texture(hero_actor_id, state_name, _visual_facing, frame)
		_visual_asset_id = asset_id
	_visual_sprite.flip_h = false
	var moving := not velocity.is_zero_approx()
	var stride := PresentationMotion.wave(_visual_time, 2.1 if moving else 0.55)
	var target_position := Vector2(0, VISUAL_OFFSET_Y + stride * (0.3 if moving else 0.12))
	var target_scale := Vector2.ONE * VISUAL_SCALE
	var response := PresentationMotion.response_alpha(delta, 18.0)
	_visual_sprite.position = _visual_sprite.position.lerp(target_position, response)
	_visual_sprite.scale = _visual_sprite.scale.lerp(target_scale, response)
	_visual_sprite.modulate = Color("fff2c4") if _hit_flash_remaining > 0.0 else Color.WHITE

func _visual_frames_per_second(state_name: String, frame_count: int) -> float:
	match state_name:
		AnimationStateRules.IDLE: return 7.0
		AnimationStateRules.MOVE: return 12.0
		AnimationStateRules.ATTACK: return float(frame_count) / VISUAL_ATTACK_DURATION
		AnimationStateRules.HIT: return float(frame_count) / VISUAL_HIT_DURATION
		AnimationStateRules.DEATH: return float(frame_count) / VISUAL_DEATH_DURATION
		_: return 8.0

func _draw() -> void:
	ContactShadowScript.paint(self, "player")
