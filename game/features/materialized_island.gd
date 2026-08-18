class_name MaterializedIsland
extends Node2D

signal resource_depleted(slot_id: String, instance_id: String, position_value: Vector2, resource_id: String, amount: int)
signal encounter_completed(slot_id: String, event_id: String, position_value: Vector2)
signal modifier_triggered(slot_id: String, modifier_id: String, position_value: Vector2)
signal enemy_volley_requested(origin: Vector2, direction: Vector2, angles: Array[float], damage: int)
signal enemy_defeated(enemy_id: String, position_value: Vector2)

var slot_id: String
var definition: Dictionary = {}
var runtime: Dictionary = {}
var effects: Dictionary = {}
var indicators: Array[String] = []
var player_target: Node2D
var force_configuration_failure: bool = false
var resources_by_id: Dictionary = {}
var event_marker: IslandEventMarker
var story_climax_active: bool = false

func configure(slot_id_value: String, installed: Dictionary, effect_values: Dictionary, indicator_values: Array[String], player: Node2D) -> bool:
	if force_configuration_failure or slot_id_value.is_empty() or not installed.get("definition") is Dictionary or not installed.get("runtime") is Dictionary:
		return false
	if not IslandShardDefinition.validate_dictionary(installed.definition).is_empty() or not IslandRuntimeState.validate_dictionary(installed.runtime).is_empty():
		return false
	slot_id = slot_id_value
	definition = (installed.definition as Dictionary).duplicate(true)
	runtime = (installed.runtime as Dictionary).duplicate(true)
	effects = effect_values.duplicate(true)
	indicators = indicator_values.duplicate()
	player_target = player
	return true

func _ready() -> void:
	_build_resources()
	_build_enemies()
	_build_event()
	queue_redraw()

func resource_ids() -> Array[String]:
	var result: Array[String] = []
	for instance_id: String in resources_by_id:
		if is_instance_valid(resources_by_id[instance_id]):
			result.append(String((resources_by_id[instance_id] as ResourceNode).resource_id))
	result.sort()
	return result

func active_enemy_count() -> int:
	var count := 0
	for child: Node in get_children():
		if child is ChaserEnemy or child is RangedEnemy:
			count += 1
	return count

func set_story_climax_active(active: bool) -> void:
	story_climax_active = active
	for child: Node in get_children():
		if child is ChaserEnemy or child is RangedEnemy:
			(child as Node2D).visible = not active
			child.set_physics_process(not active)
			if active:
				child.remove_from_group("attackable")
			else:
				child.add_to_group("attackable")
	if is_instance_valid(event_marker):
		event_marker.visible = not active
		if active:
			event_marker.remove_from_group("interactable")
		elif not event_marker.claimed:
			event_marker.add_to_group("interactable")

func resource_node(instance_id: String) -> ResourceNode:
	return resources_by_id.get(instance_id) as ResourceNode

func _build_resources() -> void:
	var authored: Array[Dictionary] = [
		{"instance_id": "tree_0", "resource_id": "wood", "name": "Island Tree", "health": 2, "amount": 3, "kind": "tree", "position": Vector2(-48, -28)},
		{"instance_id": "stone_0", "resource_id": "stone", "name": "Island Stone", "health": 3, "amount": 2, "kind": "stone", "position": Vector2(43, -33)},
	]
	if "moonleaf" in (definition.resources as Array):
		authored.append({"instance_id": "moonleaf_0", "resource_id": "moonleaf", "name": "Moonleaf", "health": 1, "amount": 1, "kind": "herb", "position": Vector2(-12, 43)})
	if float(effects.get("resource_density_multiplier", 1.0)) > 1.0:
		authored.append({"instance_id": "tree_1", "resource_id": "wood", "name": "Dense Island Tree", "health": 2, "amount": 2, "kind": "tree", "position": Vector2(58, 45)})
	for authored_node: Dictionary in authored:
		var stable_id := String(authored_node.instance_id)
		if stable_id in (runtime.destroyed_resources as Array):
			continue
		var resource := ResourceNode.new()
		var resource_definition := ResourceNodeDefinition.new()
		resource_definition.resource_id = String(authored_node.resource_id)
		resource_definition.display_name = String(authored_node.name)
		resource_definition.maximum_health = int(authored_node.health)
		resource_definition.drop_amount = int(authored_node.amount)
		resource_definition.visual_kind = String(authored_node.kind)
		resource.definition = resource_definition
		resource.name = stable_id
		resource.position = authored_node.position as Vector2
		resource.depleted.connect(func(position_value: Vector2, resource_id: String, amount: int) -> void: _on_resource_depleted(stable_id, position_value, resource_id, amount))
		resources_by_id[stable_id] = resource
		add_child(resource)

func _build_enemies() -> void:
	var slime := ChaserEnemy.new()
	slime.name = "ForestSlime"
	slime.position = Vector2(-72, 58)
	slime.target = player_target
	slime.move_speed *= float(effects.get("night_enemy_multiplier", 1.0))
	slime.defeated.connect(func(position_value: Vector2) -> void: _on_enemy_defeated(slime, position_value))
	add_child(slime)
	var ranger := RangedEnemy.new()
	ranger.name = "ForestRanger"
	ranger.position = Vector2(74, 10)
	ranger.target = player_target
	ranger.move_speed *= float(effects.get("night_enemy_multiplier", 1.0))
	ranger.volley_requested.connect(func(origin: Vector2, direction: Vector2, angles: Array[float], damage: int) -> void: enemy_volley_requested.emit(origin, direction, angles, damage))
	ranger.defeated.connect(func(position_value: Vector2, _loot_seed: int) -> void: _on_enemy_defeated(ranger, position_value))
	add_child(ranger)
	for elite_index: int in int(effects.get("elite_count_bonus", 0)):
		var elite := RangedEnemy.new()
		elite.name = "PredatoryElite%d" % elite_index
		elite.elite = true
		elite.position = Vector2(0, -72)
		elite.target = player_target
		elite.volley_requested.connect(func(origin: Vector2, direction: Vector2, angles: Array[float], damage: int) -> void: enemy_volley_requested.emit(origin, direction, angles, damage))
		elite.defeated.connect(func(position_value: Vector2, _loot_seed: int) -> void: _on_enemy_defeated(elite, position_value))
		add_child(elite)

func _on_enemy_defeated(combatant: Node2D, position_value: Vector2) -> void:
	enemy_defeated.emit(str(combatant.get_instance_id()), position_value)
	_spawn_enemy_death_vfx(position_value)

func _spawn_enemy_death_vfx(position_value: Vector2) -> void:
	var visual := GameplayVfx.new()
	visual.configure("death", VfxSettings.from_project_settings())
	visual.global_position = position_value
	add_child(visual)

func _build_event() -> void:
	var event_id := String(definition.encounter).to_snake_case()
	event_marker = IslandEventMarker.new()
	event_marker.position = Vector2(6, 2)
	event_marker.configure(event_id, String(definition.encounter), event_id in (runtime.collected_rewards as Array))
	event_marker.completed.connect(func(completed_id: String) -> void: encounter_completed.emit(slot_id, completed_id, event_marker.global_position))
	add_child(event_marker)

func _on_resource_depleted(instance_id: String, position_value: Vector2, resource_id: String, amount: int) -> void:
	resources_by_id.erase(instance_id)
	resource_depleted.emit(slot_id, instance_id, position_value, resource_id, amount)
	if resource_id == "stone" and int(effects.get("ore_explosion_damage", 0)) > 0:
		var radius := float(effects.get("ore_explosion_radius", 76.0))
		for candidate: Node in get_tree().get_nodes_in_group("attackable"):
			if candidate is Node2D and candidate.has_method("receive_attack") and (candidate as Node2D).global_position.distance_to(position_value) <= radius:
				candidate.receive_attack(int(effects.ore_explosion_damage))
		modifier_triggered.emit(slot_id, "volatile_ore", position_value)

func _draw() -> void:
	# Installed islands are communicated by their materialized objects and pedestal,
	# never by a giant circular selection zone. Modifier state uses compact glyphs.
	var marker_origin := Vector2(-float(maxi(0, indicators.size() - 1)) * 8.0, -76)
	for index: int in indicators.size():
		var marker := marker_origin + Vector2(index * 16.0, 0)
		var diamond := PackedVector2Array([marker + Vector2(0, -5), marker + Vector2(4, 0), marker + Vector2(0, 5), marker + Vector2(-4, 0)])
		draw_colored_polygon(diamond, Color("ffd166"))

func uses_circular_zone_overlay() -> bool:
	return false
