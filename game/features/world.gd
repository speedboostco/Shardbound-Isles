class_name FirstPlayableWorld
extends Node2D

const GameLoggerScript := preload("res://game/core/game_logger.gd")
const InteractionSelectorScript := preload("res://game/core/interaction_selector.gd")
const MovementRulesScript := preload("res://game/core/movement_rules.gd")
const ResourceInventoryScript := preload("res://game/core/resource_inventory.gd")
const EQUIPMENT_SEED: int = 424242
const DEFAULT_SAVE_PATH: String = "user://shardbound-save.json"
const ISLAND_SHARD_SEED: int = 9001
const RANGED_ISLAND_SHARD_SEED: int = 9002
const ELITE_ISLAND_SHARD_SEED: int = 9003
const BASE_TREE_YIELD: int = 3
const BASE_ENEMY_SPEED: float = 75.0
const BASE_RANGED_SPEED: float = 65.0
const BASE_ELITE_SPEED: float = 85.0
const RANGED_LOOT_SEED: int = 424243
const ELITE_LOOT_SEED: int = 424244
const BASE_BOSS_PHASE_ONE_SPEED: float = 50.0
const BASE_BOSS_PHASE_TWO_SPEED: float = 105.0

@onready var player: PlayerCharacter = $Player
@onready var tree: ResourceNode = $Tree
@onready var stone_node: ResourceNode = $StoneNode
@onready var enemy: ChaserEnemy = $Enemy
@onready var second_slime: ChaserEnemy = $SecondSlime
@onready var camera: CameraRig = $Player/Camera2D
@onready var workbench: Workbench = $Workbench
@onready var tidecatcher: Tidecatcher = $Tidecatcher
@onready var island_slot: IslandSlot = $IslandSlot
@onready var ranged_enemy: RangedEnemy = $RangedEnemy
@onready var elite_ranged_enemy: RangedEnemy = $EliteRangedEnemy
@onready var boss: AbyssalWarden = $Boss
@onready var rift_portal: RiftPortal = $RiftPortal
@onready var hud: GameHud = $HUD

var resource_inventory: Variant = ResourceInventoryScript.new()
var wood: int:
	get: return resource_inventory.amount("wood")
	set(value): resource_inventory.set_amount("wood", maxi(0, value))
var stone: int:
	get: return resource_inventory.amount("stone")
	set(value): resource_inventory.set_amount("stone", maxi(0, value))
var equipment_inventory := EquipmentInventory.new()
var equipment: Array[Dictionary] = equipment_inventory.items
var enemies_defeated: int = 0
var crafting_service := CraftingService.new()
var reinforced_heart_crafted: bool = false
var runed_whetstone_crafted: bool = false
var tidecatcher_built: bool = false
var save_service := SaveService.new()
var island_shards: Array[Dictionary] = []
var installed_shard: Dictionary = {}
var rift_controller := RiftRunController.new()
var rift_enemies: Array[Node2D] = []
var logger: Variant = GameLoggerScript.new(bool(ProjectSettings.get_setting("shardbound/logging/debug_enabled", false)))
var current_interaction_target: Node

func _ready() -> void:
	player.attack_requested.connect(_on_attack_requested)
	player.interaction_requested.connect(_on_interaction_requested)
	player.moved.connect(_on_player_moved)
	player.health_changed.connect(hud.set_health)
	player.defeated.connect(_on_player_defeated)
	resource_inventory.changed.connect(_on_resource_inventory_changed)
	tree.depleted.connect(_on_resource_depleted)
	stone_node.depleted.connect(_on_resource_depleted)
	enemy.target = player
	enemy.defeated.connect(_on_enemy_defeated)
	second_slime.target = player
	second_slime.defeated.connect(_on_second_slime_defeated)
	ranged_enemy.target = player
	elite_ranged_enemy.target = player
	ranged_enemy.volley_requested.connect(_on_enemy_volley_requested)
	elite_ranged_enemy.volley_requested.connect(_on_enemy_volley_requested)
	ranged_enemy.defeated.connect(_on_ranged_enemy_defeated)
	elite_ranged_enemy.defeated.connect(_on_ranged_enemy_defeated)
	boss.target = player
	boss.volley_requested.connect(_on_boss_volley_requested)
	boss.phase_changed.connect(_on_boss_phase_changed)
	boss.defeated.connect(_on_boss_defeated)
	hud.set_health(player.health, player.maximum_health)
	hud.set_wood(wood)
	hud.set_stone(stone)
	hud.equipment_panel_requested.connect(open_equipment_panel)
	hud.equipment_panel_closed.connect(_on_equipment_panel_closed)
	hud.equip_requested.connect(equip_selected_item)
	hud.salvage_requested.connect(salvage_selected_item)
	hud.unequip_requested.connect(unequip_item)
	hud.workbench_panel_requested.connect(try_open_workbench)
	hud.workbench_panel_closed.connect(_on_workbench_panel_closed)
	hud.craft_requested.connect(_on_craft_requested)
	hud.tidecatcher_build_requested.connect(build_tidecatcher)
	hud.system_menu_requested.connect(open_system_menu)
	hud.system_menu_closed.connect(_on_system_menu_closed)
	hud.save_requested.connect(save_game)
	hud.load_requested.connect(load_game)
	hud.island_panel_requested.connect(open_island_panel)
	hud.island_panel_closed.connect(_on_island_panel_closed)
	hud.island_install_requested.connect(install_selected_shard)
	hud.island_remove_requested.connect(remove_installed_shard)
	hud.rift_requested.connect(handle_rift_action)
	workbench.interacted.connect(try_open_workbench)
	rift_portal.interacted.connect(handle_rift_action)
	rift_portal.availability_changed.connect(_refresh_interaction_target)
	tidecatcher.wood_collected.connect(_on_tidecatcher_wood_collected)
	tidecatcher.storage_changed.connect(_on_tidecatcher_storage_changed)
	_refresh_equipment_ui()
	_refresh_workbench_ui()
	_refresh_island_ui()
	_refresh_interaction_target()

func _on_attack_requested(origin: Vector2, direction: Vector2) -> void:
	var best_target: Node2D
	var best_distance := 78.0
	for candidate: Node in get_tree().get_nodes_in_group("attackable"):
		if not candidate is Node2D:
			continue
		var target_node := candidate as Node2D
		var offset := target_node.global_position - origin
		var distance := offset.length()
		if distance <= best_distance and (distance < 1.0 or direction.dot(offset.normalized()) > 0.2):
			best_target = target_node
			best_distance = distance
	if is_instance_valid(best_target) and best_target.has_method("receive_attack"):
		best_target.receive_attack(player.attack_damage)
		player.confirm_hit()
		camera.request_shake(4.0, 0.1)
	if player.legendary_affix_id == "riftwake_pulse":
		_trigger_legendary_pulse(origin, best_target)

func _trigger_legendary_pulse(origin: Vector2, primary_target: Node2D) -> void:
	var candidates: Array[Dictionary] = []
	var targets_by_id: Dictionary = {}
	for candidate: Node in get_tree().get_nodes_in_group("attackable"):
		if not (candidate is ChaserEnemy or candidate is RangedEnemy or candidate is AbyssalWarden):
			continue
		var enemy_node := candidate as Node2D
		var candidate_id := str(enemy_node.get_instance_id())
		candidates.append({"id": candidate_id, "position": enemy_node.global_position})
		targets_by_id[candidate_id] = enemy_node
	var excluded_id := str(primary_target.get_instance_id()) if is_instance_valid(primary_target) else ""
	for target_id: String in LegendaryPulseTargeting.select_ids(origin, candidates, LegendaryPulseVisual.MAXIMUM_RADIUS, excluded_id):
		var target_node: Node = targets_by_id.get(target_id)
		if is_instance_valid(target_node) and target_node.has_method("receive_attack"):
			target_node.receive_attack(2)
	var pulse := LegendaryPulseVisual.new()
	pulse.global_position = origin
	add_child(pulse)

func _on_resource_depleted(drop_position: Vector2, resource_id: String, amount: int) -> void:
	_spawn_pickup(drop_position, resource_id, amount)

func _on_enemy_defeated(drop_position: Vector2) -> void:
	enemies_defeated += 1
	logger.debug(GameLoggerScript.LOOT, "enemy loot generated", {"equipment_seed": EQUIPMENT_SEED, "island_seed": ISLAND_SHARD_SEED})
	_spawn_pickup(drop_position, "equipment", EquipmentGenerator.generate(EQUIPMENT_SEED))
	_spawn_pickup(drop_position + Vector2(25.0, 0.0), "island_shard", IslandShardGenerator.generate(ISLAND_SHARD_SEED))
	_check_boss_unlock()

func _on_second_slime_defeated(_drop_position: Vector2) -> void:
	enemies_defeated += 1
	logger.debug(GameLoggerScript.LOOT, "slime defeated without loot roll", {"enemy_id": "second_slime"})
	_check_boss_unlock()

func _on_ranged_enemy_defeated(drop_position: Vector2, loot_seed: int) -> void:
	enemies_defeated += 1
	_spawn_pickup(drop_position, "equipment", EquipmentGenerator.generate(loot_seed))
	var shard_seed := RANGED_ISLAND_SHARD_SEED if loot_seed == RANGED_LOOT_SEED else ELITE_ISLAND_SHARD_SEED
	logger.debug(GameLoggerScript.LOOT, "ranged enemy loot generated", {"equipment_seed": loot_seed, "island_seed": shard_seed})
	_spawn_pickup(drop_position + Vector2(25.0, 0.0), "island_shard", IslandShardGenerator.generate(shard_seed))
	_check_boss_unlock()

func _on_enemy_volley_requested(origin: Vector2, base_direction: Vector2, angles: Array[float], damage: int) -> void:
	var modified_damage := damage + int(installed_shard.get("enemy_projectile_damage_bonus", 0))
	for angle: float in angles:
		spawn_enemy_projectile(origin, base_direction.rotated(angle), modified_damage)

func _on_boss_volley_requested(origin: Vector2, directions: Array[Vector2], damage: int) -> void:
	var modified_damage := damage + int(installed_shard.get("enemy_projectile_damage_bonus", 0))
	for direction: Vector2 in directions:
		spawn_enemy_projectile(origin, direction, modified_damage)

func _on_boss_phase_changed(_phase: int, base_speed: float) -> void:
	var multiplier := float(installed_shard.get("enemy_speed_multiplier", 1.0))
	boss.move_speed = base_speed * multiplier
	hud.set_encounter_feedback("MAELSTROM PHASE — RADIAL VOLLEYS")

func _on_boss_defeated(drop_position: Vector2) -> void:
	_spawn_pickup(drop_position, "equipment", BossReward.generate())
	hud.set_encounter_feedback("WARDEN DEFEATED — RIFTWAKE CORE DROPPED")
	rift_portal.unlock()
	hud.set_rift_feedback("RIFT UNLOCKED — APPROACH PORTAL AND PRESS LB / K")

func _check_boss_unlock() -> void:
	if enemies_defeated >= 3 and not boss.active:
		boss.activate(player)
		_apply_island_modifiers()
		hud.set_encounter_feedback("BOSS AWAKENS — ABYSSAL WARDEN")

func spawn_enemy_projectile(origin: Vector2, projectile_direction: Vector2, projectile_damage: int) -> EnemyProjectile:
	var projectile := EnemyProjectile.new()
	projectile.target = player
	projectile.global_position = origin
	projectile.direction = projectile_direction
	projectile.damage = projectile_damage
	add_child(projectile)
	return projectile

func _spawn_pickup(drop_position: Vector2, kind: String, payload: Variant) -> WorldPickup:
	if kind in ["wood", "stone"] and payload is int:
		for child: Node in get_children():
			if child is WorldPickup:
				var existing := child as WorldPickup
				if not existing.is_queued_for_deletion() and existing.kind == kind and existing.global_position.distance_to(drop_position) <= WorldPickup.MERGE_RADIUS:
					existing.merge_amount(int(payload))
					return existing
	var pickup := WorldPickup.new()
	pickup.kind = kind
	pickup.payload = payload
	pickup.target = player
	pickup.position = drop_position
	pickup.collected.connect(_on_pickup_collected)
	add_child(pickup)
	return pickup

func _on_pickup_collected(kind: String, payload: Variant) -> void:
	if kind in ["wood", "stone"]:
		resource_inventory.add(kind, int(payload))
	elif kind == "equipment":
		var item := payload as Dictionary
		equipment_inventory.collect(item)
		hud.set_loot(item)
		_refresh_equipment_ui()
	elif kind == "island_shard":
		var shard := payload as Dictionary
		if not _has_shard(String(shard.get("id", ""))):
			island_shards.append(shard.duplicate(true))
		_refresh_island_ui()

func _on_resource_inventory_changed(resource_id: String, amount: int, _delta: int) -> void:
	if resource_id == "wood":
		hud.set_wood(amount)
	elif resource_id == "stone":
		hud.set_stone(amount)

func _on_player_moved(_position_value: Vector2) -> void:
	_refresh_interaction_target()

func _refresh_interaction_target() -> void:
	var candidates: Array[Dictionary] = []
	var nodes_by_id: Dictionary = {}
	for candidate: Node in get_tree().get_nodes_in_group("interactable"):
		if not candidate is Node2D or not candidate.has_method("interaction_id") or not candidate.has_method("can_interact"):
			continue
		var target := candidate as Node2D
		var target_id := String(candidate.interaction_id())
		candidates.append({
			"id": target_id,
			"position": target.global_position,
			"available": bool(candidate.can_interact(player.global_position)),
			"label": String(candidate.interaction_label()),
		})
		nodes_by_id[target_id] = candidate
	var selected: Dictionary = InteractionSelectorScript.select(player.global_position, candidates, 180.0)
	current_interaction_target = nodes_by_id.get(String(selected.get("id", ""))) as Node
	hud.set_interaction_prompt(String(selected.get("label", "")))

func _on_interaction_requested() -> void:
	_refresh_interaction_target()
	if is_instance_valid(current_interaction_target) and current_interaction_target.has_method("interact"):
		current_interaction_target.interact(player)

func open_equipment_panel() -> void:
	if hud.is_workbench_panel_open():
		hud.close_workbench_panel()
	_refresh_equipment_ui()
	hud.open_equipment_panel()
	player.input_enabled = false
	_set_combat_processing(false)

func close_equipment_panel() -> void:
	hud.close_equipment_panel()

func _on_equipment_panel_closed() -> void:
	_restore_gameplay_if_no_modal()

func equip_selected_item(index: int) -> bool:
	var equipped := equipment_inventory.equip(index)
	_sync_player_equipment()
	_refresh_equipment_ui()
	return equipped

func unequip_item() -> bool:
	var unequipped := equipment_inventory.unequip()
	_sync_player_equipment()
	_refresh_equipment_ui()
	return unequipped

func salvage_selected_item(index: int) -> int:
	var reward := equipment_inventory.salvage(index)
	_refresh_equipment_ui()
	return reward

func _refresh_equipment_ui() -> void:
	hud.refresh_equipment(equipment_inventory.items, equipment_inventory.equipped_item(), equipment_inventory.scrap, player.attack_damage, player.attack_speed)
	_refresh_workbench_ui()

func _sync_player_equipment() -> void:
	var equipped := equipment_inventory.equipped_item()
	var upgrade_bonus := CraftingService.WHETSTONE_ATTACK_BONUS if runed_whetstone_crafted else 0
	var damage := equipment_inventory.attack_damage() + upgrade_bonus + int(installed_shard.get("player_attack_bonus", 0))
	player.set_weapon_stats(damage, equipment_inventory.attack_speed(), String(equipped.get("base_type", equipped.get("archetype", "unarmed"))), String(equipped.get("legendary_affix_id", "")))

func try_open_workbench() -> bool:
	if not workbench.is_player_in_range(player.global_position):
		return false
	if hud.is_equipment_panel_open():
		hud.close_equipment_panel()
	_refresh_workbench_ui()
	hud.open_workbench_panel()
	player.input_enabled = false
	_set_combat_processing(false)
	return true

func close_workbench_panel() -> void:
	hud.close_workbench_panel()

func _on_workbench_panel_closed() -> void:
	_restore_gameplay_if_no_modal()

func _on_craft_requested(recipe_id: String) -> void:
	if recipe_id == CraftingService.WHETSTONE_RECIPE_ID:
		craft_runed_whetstone()
	else:
		craft_reinforced_heart()

func craft_reinforced_heart() -> bool:
	var result := crafting_service.craft(wood, equipment_inventory.scrap, reinforced_heart_crafted)
	if not bool(result.get("success", false)):
		var reason := String(result.get("reason", ""))
		_refresh_workbench_ui("ALREADY CRAFTED" if reason == "already_crafted" else "NEED MORE RESOURCES")
		return false
	resource_inventory.remove("wood", int(result.get("wood_spent", 0)))
	equipment_inventory.scrap -= int(result.get("scrap_spent", 0))
	reinforced_heart_crafted = true
	player.add_maximum_health(int(result.get("maximum_health_bonus", 0)))
	refresh_all_ui("CRAFTED — MAX HEALTH +2")
	hud.focus_tidecatcher_build()
	return true

func craft_runed_whetstone() -> bool:
	var result := crafting_service.craft_whetstone(stone, runed_whetstone_crafted)
	if not bool(result.get("success", false)):
		var reason := String(result.get("reason", ""))
		_refresh_workbench_ui("ALREADY CRAFTED" if reason == "already_crafted" else "NEED MORE STONE")
		return false
	resource_inventory.remove("stone", int(result.get("stone_spent", 0)))
	runed_whetstone_crafted = true
	_sync_player_equipment()
	refresh_all_ui("CRAFTED — BASE ATTACK +1")
	return true

func build_tidecatcher() -> bool:
	if not reinforced_heart_crafted or tidecatcher_built:
		_refresh_workbench_ui("REQUIRES REINFORCED HEART" if not reinforced_heart_crafted else "TIDECATCHER ALREADY BUILT")
		return false
	tidecatcher_built = true
	tidecatcher.activate(player)
	_refresh_workbench_ui("TIDECATCHER CONSTRUCTED")
	hud.set_automation_status(true, 0, WoodProduction.STORAGE_CAPACITY, "TIDECATCHER ONLINE — PRODUCING WOOD")
	return true

func _on_tidecatcher_wood_collected(amount: int) -> void:
	resource_inventory.add("wood", amount)
	hud.set_automation_status(true, 0, WoodProduction.STORAGE_CAPACITY, "TIDECATCHER COLLECTED +%d WOOD" % amount)

func _on_tidecatcher_storage_changed(stored: int, capacity: int) -> void:
	hud.set_automation_status(true, stored, capacity)

func refresh_all_ui(crafting_feedback: String = "") -> void:
	hud.set_health(player.health, player.maximum_health)
	hud.set_wood(wood)
	hud.set_stone(stone)
	_refresh_equipment_ui()
	_refresh_workbench_ui(crafting_feedback)
	_refresh_island_ui()

func _refresh_workbench_ui(feedback: String = "") -> void:
	hud.refresh_workbench(wood, stone, equipment_inventory.scrap, reinforced_heart_crafted, runed_whetstone_crafted, tidecatcher_built, feedback)

func _restore_gameplay_if_no_modal() -> void:
	if hud.is_equipment_panel_open() or hud.is_workbench_panel_open() or hud.is_system_menu_open() or hud.is_island_panel_open():
		return
	player.input_enabled = true
	_set_combat_processing(true)
	if tidecatcher_built:
		tidecatcher.set_process(true)

func open_system_menu() -> void:
	hud.open_system_menu()
	player.input_enabled = false
	_set_combat_processing(false)
	if tidecatcher_built:
		tidecatcher.set_process(false)

func close_system_menu() -> void:
	hud.close_system_menu()

func _on_system_menu_closed() -> void:
	_restore_gameplay_if_no_modal()

func save_game(path: String = DEFAULT_SAVE_PATH) -> bool:
	var result := save_service.save_to_path(path, snapshot_state())
	var succeeded := bool(result.get("ok", false))
	if succeeded:
		logger.debug(GameLoggerScript.SAVE, "game saved", {"path": path, "schema_version": SaveService.SCHEMA_VERSION})
	else:
		logger.error(GameLoggerScript.SAVE, "save failed", {"path": path, "reason": String(result.get("error", "unknown"))})
	hud.set_system_feedback("GAME SAVED" if succeeded else "SAVE FAILED — %s" % String(result.get("error", "unknown")).to_upper())
	return succeeded

func load_game(path: String = DEFAULT_SAVE_PATH) -> bool:
	var result := save_service.load_from_path(path)
	if not bool(result.get("ok", false)):
		logger.error(GameLoggerScript.SAVE, "load failed", {"path": path, "reason": String(result.get("error", "unknown"))})
		hud.set_system_feedback("LOAD FAILED — %s" % String(result.get("error", "unknown")).to_upper())
		return false
	_apply_state(result.get("state") as Dictionary)
	logger.debug(GameLoggerScript.SAVE, "game loaded", {"path": path, "schema_version": int(result.get("schema_version", SaveService.SCHEMA_VERSION))})
	hud.set_system_feedback("GAME LOADED")
	return true

func apply_save_payload(payload: String) -> bool:
	var result := save_service.decode(payload)
	if not bool(result.get("ok", false)):
		hud.set_system_feedback("LOAD REJECTED — %s" % String(result.get("error", "unknown")).to_upper())
		return false
	_apply_state(result.get("state") as Dictionary)
	hud.set_system_feedback("GAME LOADED")
	return true

func snapshot_state() -> Dictionary:
	var saved_items: Array[Dictionary] = []
	for item: Dictionary in equipment_inventory.items:
		saved_items.append(item.duplicate(true))
	var saved_shards: Array[Dictionary] = []
	for shard: Dictionary in island_shards:
		saved_shards.append(shard.duplicate(true))
	return {
		"player": {
			"health": player.health,
			"maximum_health": player.maximum_health,
			"position": {"x": player.global_position.x, "y": player.global_position.y},
		},
		"wood": wood,
		"stone": stone,
		"equipment": {
			"scrap": equipment_inventory.scrap,
			"equipped_id": equipment_inventory.equipped_id,
			"items": saved_items,
		},
		"reinforced_heart_crafted": reinforced_heart_crafted,
		"runed_whetstone_crafted": runed_whetstone_crafted,
		"tidecatcher": {"built": tidecatcher_built, "stored_wood": tidecatcher.stored_wood()},
		"islands": {"inventory": saved_shards, "installed": installed_shard.duplicate(true)},
	}

func _apply_state(state: Dictionary) -> void:
	var player_state := state.player as Dictionary
	var position_state := player_state.position as Dictionary
	var equipment_state := state.equipment as Dictionary
	var tidecatcher_state := state.tidecatcher as Dictionary
	var islands_state := state.islands as Dictionary
	player.maximum_health = int(player_state.maximum_health)
	player.health = clampi(int(player_state.health), 0, player.maximum_health)
	player.global_position = Vector2(float(position_state.x), float(position_state.y))
	wood = maxi(0, int(state.wood))
	stone = maxi(0, int(state.stone))
	equipment_inventory.items.clear()
	for item_value: Variant in equipment_state.items:
		equipment_inventory.items.append((item_value as Dictionary).duplicate(true))
	equipment_inventory.scrap = maxi(0, int(equipment_state.scrap))
	equipment_inventory.equipped_id = String(equipment_state.equipped_id)
	if equipment_inventory.equipped_item().is_empty():
		equipment_inventory.equipped_id = ""
	reinforced_heart_crafted = bool(state.reinforced_heart_crafted)
	runed_whetstone_crafted = bool(state.runed_whetstone_crafted)
	_sync_player_equipment()
	tidecatcher_built = bool(tidecatcher_state.built)
	tidecatcher.restore_state(tidecatcher_built, int(tidecatcher_state.stored_wood), player)
	island_shards.clear()
	for shard_value: Variant in islands_state.inventory:
		island_shards.append((shard_value as Dictionary).duplicate(true))
	installed_shard = (islands_state.installed as Dictionary).duplicate(true)
	_apply_island_modifiers()
	player.health_changed.emit(player.health, player.maximum_health)
	refresh_all_ui()
	hud.set_automation_status(tidecatcher_built, tidecatcher.stored_wood(), WoodProduction.STORAGE_CAPACITY)

func open_island_panel() -> void:
	_refresh_island_ui()
	hud.open_island_panel()
	player.input_enabled = false
	_set_combat_processing(false)

func close_island_panel() -> void:
	hud.close_island_panel()

func _on_island_panel_closed() -> void:
	_restore_gameplay_if_no_modal()

func install_selected_shard(index: int) -> bool:
	if index < 0 or index >= island_shards.size():
		return false
	installed_shard = island_shards[index].duplicate(true)
	logger.debug(GameLoggerScript.WORLD, "island shard installed", {"id": String(installed_shard.get("id", "")), "seed": int(installed_shard.get("seed", 0))})
	_apply_island_modifiers()
	_refresh_equipment_ui()
	_refresh_island_ui()
	return true

func remove_installed_shard() -> bool:
	if installed_shard.is_empty():
		return false
	installed_shard = {}
	_apply_island_modifiers()
	_refresh_equipment_ui()
	_refresh_island_ui()
	return true

func _apply_island_modifiers() -> void:
	var yield_bonus := int(installed_shard.get("tree_yield_bonus", 0))
	var speed_multiplier := float(installed_shard.get("enemy_speed_multiplier", 1.0))
	_sync_player_equipment()
	if is_instance_valid(tree):
		tree.wood_yield = BASE_TREE_YIELD + yield_bonus
	if is_instance_valid(tidecatcher):
		tidecatcher.set_production_interval_multiplier(float(installed_shard.get("production_interval_multiplier", 1.0)))
	if is_instance_valid(enemy):
		enemy.move_speed = BASE_ENEMY_SPEED * speed_multiplier
	if is_instance_valid(ranged_enemy):
		ranged_enemy.move_speed = BASE_RANGED_SPEED * speed_multiplier
	if is_instance_valid(elite_ranged_enemy):
		elite_ranged_enemy.move_speed = BASE_ELITE_SPEED * speed_multiplier
	if is_instance_valid(boss):
		var boss_base := BASE_BOSS_PHASE_TWO_SPEED if boss.phase == 2 else BASE_BOSS_PHASE_ONE_SPEED
		boss.move_speed = boss_base * speed_multiplier
	for combatant: Node2D in rift_enemies:
		if not is_instance_valid(combatant):
			continue
		if combatant is ChaserEnemy:
			(combatant as ChaserEnemy).move_speed = BASE_ENEMY_SPEED * speed_multiplier
		elif combatant is RangedEnemy:
			var ranged := combatant as RangedEnemy
			ranged.move_speed = (BASE_ELITE_SPEED if ranged.elite else BASE_RANGED_SPEED) * speed_multiplier
	island_slot.set_installed(not installed_shard.is_empty(), String(installed_shard.get("name", "")), String(installed_shard.get("biome", "")))

func _refresh_island_ui() -> void:
	hud.refresh_islands(island_shards, installed_shard)

func _has_shard(shard_id: String) -> bool:
	for shard: Dictionary in island_shards:
		if String(shard.get("id", "")) == shard_id:
			return true
	return false

func _set_combat_processing(enabled: bool) -> void:
	var combatants: Array[Node] = [enemy, second_slime, ranged_enemy, elite_ranged_enemy, boss]
	combatants.append_array(rift_enemies)
	for combatant: Node in combatants:
		if is_instance_valid(combatant):
			combatant.set_physics_process(enabled)
	for child: Node in get_children():
		if child is EnemyProjectile:
			child.set_process(enabled)

func handle_rift_action() -> void:
	if rift_controller.status == RiftRunController.Status.ACTIVE:
		_fail_rift("RIFT FAILED — RETREATED")
	elif rift_controller.status in [RiftRunController.Status.COMPLETE, RiftRunController.Status.FAILED]:
		rift_controller.exit()
		hud.set_rift_feedback("RIFT READY — APPROACH PORTAL FOR RUN %d" % (rift_controller.run_index + 1))
	else:
		try_enter_rift()

func try_enter_rift() -> bool:
	if not rift_portal.is_player_in_range(player.global_position):
		return false
	if not rift_controller.start():
		return false
	hud.set_encounter_feedback("")
	_prepare_rift_arena()
	_spawn_rift_wave()
	return true

func _prepare_rift_arena() -> void:
	for combatant: Node2D in [enemy, second_slime, ranged_enemy, elite_ranged_enemy, boss]:
		if is_instance_valid(combatant):
			combatant.visible = false
			combatant.set_physics_process(false)
			combatant.remove_from_group("attackable")
	_clear_enemy_projectiles()

func _spawn_rift_wave() -> void:
	rift_enemies.clear()
	for definition: Dictionary in RiftRules.wave(rift_controller.wave_index):
		var kind := String(definition.kind)
		var spawn_position := definition.position as Vector2
		if kind == "chaser":
			var chaser := ChaserEnemy.new()
			chaser.position = spawn_position
			chaser.target = player
			chaser.move_speed = BASE_ENEMY_SPEED * float(installed_shard.get("enemy_speed_multiplier", 1.0))
			add_child(chaser)
			chaser.defeated.connect(_on_rift_chaser_defeated.bind(chaser))
			rift_enemies.append(chaser)
		else:
			var ranged := RangedEnemy.new()
			ranged.position = spawn_position
			ranged.target = player
			ranged.elite = kind == "elite"
			ranged.move_speed = (BASE_ELITE_SPEED if ranged.elite else BASE_RANGED_SPEED) * float(installed_shard.get("enemy_speed_multiplier", 1.0))
			add_child(ranged)
			ranged.volley_requested.connect(_on_enemy_volley_requested)
			ranged.defeated.connect(_on_rift_ranged_defeated.bind(ranged))
			rift_enemies.append(ranged)
	hud.set_rift_feedback("RIFT RUN %d — WAVE %d / %d — %d ENEMIES" % [rift_controller.run_index, rift_controller.wave_index, RiftRules.TOTAL_WAVES, rift_enemies.size()])

func _on_rift_chaser_defeated(_position: Vector2, combatant: ChaserEnemy) -> void:
	_resolve_rift_enemy(combatant)

func _on_rift_ranged_defeated(_position: Vector2, _loot_seed: int, combatant: RangedEnemy) -> void:
	_resolve_rift_enemy(combatant)

func _resolve_rift_enemy(combatant: Node2D) -> void:
	rift_enemies.erase(combatant)
	if not rift_enemies.is_empty() or rift_controller.status != RiftRunController.Status.ACTIVE:
		return
	if rift_controller.next_wave():
		_spawn_rift_wave()
	else:
		rift_controller.complete()
		_spawn_pickup(rift_portal.global_position, "equipment", RiftRules.reward(rift_controller.run_index))
		hud.set_rift_feedback("RIFT COMPLETE — CACHE DROPPED — PRESS LB / K TO EXIT")

func _on_player_defeated() -> void:
	if rift_controller.status == RiftRunController.Status.ACTIVE:
		_fail_rift("RIFT FAILED — SAFE RECOVERY")

func _fail_rift(message: String) -> void:
	rift_controller.fail()
	_clear_rift_enemies()
	_clear_enemy_projectiles()
	hud.set_rift_feedback(message)

func _clear_rift_enemies() -> void:
	for combatant: Node2D in rift_enemies:
		if is_instance_valid(combatant):
			combatant.remove_from_group("attackable")
			combatant.queue_free()
	rift_enemies.clear()

func _clear_enemy_projectiles() -> void:
	for child: Node in get_children():
		if child is EnemyProjectile:
			child.queue_free()

func run_scripted_smoke() -> Dictionary:
	_set_combat_processing(false)
	player.global_position = Vector2.ZERO
	enemy.global_position = Vector2(-270, 80)
	second_slime.global_position = Vector2(-70, 300)
	var movement_steps := 0
	movement_steps += _scripted_move_to(tree.global_position + Vector2(-48, 0))
	tree.receive_attack(1)
	tree.receive_attack(1)
	var wood_pickup := _find_pickup("wood")
	wood_pickup.collect_immediately()
	movement_steps += _scripted_move_to(stone_node.global_position + Vector2(-52, 0))
	stone_node.receive_attack(1)
	stone_node.receive_attack(1)
	stone_node.receive_attack(1)
	var stone_pickup := _find_pickup("stone")
	stone_pickup.collect_immediately()
	movement_steps += _scripted_move_to(enemy.global_position + Vector2(50, 0))
	var unarmed_damage := player.attack_damage
	var unarmed_hits := 0
	while is_instance_valid(enemy) and enemy.remaining_health > 0:
		_on_attack_requested(enemy.global_position + Vector2(50, 0), Vector2.LEFT)
		unarmed_hits += 1
	var equipment_pickup := _find_pickup("equipment")
	equipment_pickup.collect_immediately()
	equip_selected_item(0)
	var equipped_damage := player.attack_damage
	var equipped_speed := player.attack_speed
	movement_steps += _scripted_move_to(second_slime.global_position + Vector2(50, 0))
	var equipped_hits := 0
	while is_instance_valid(second_slime) and second_slime.remaining_health > 0:
		_on_attack_requested(second_slime.global_position + Vector2(50, 0), Vector2.LEFT)
		equipped_hits += 1
	return {
		"seed": EQUIPMENT_SEED,
		"wood": wood,
		"stone": stone,
		"movement_steps": movement_steps,
		"enemies_defeated": enemies_defeated,
		"items_collected": equipment.size(),
		"item": equipment[0] if not equipment.is_empty() else {},
		"equipped_id": equipment_inventory.equipped_id,
		"unarmed_damage": unarmed_damage,
		"equipped_damage": equipped_damage,
		"equipped_attack_speed": equipped_speed,
		"unarmed_hits": unarmed_hits,
		"equipped_hits": equipped_hits,
	}

func _scripted_move_to(destination: Vector2) -> int:
	var steps := 0
	const DELTA: float = 1.0 / 60.0
	while player.global_position.distance_to(destination) > 3.0 and steps < 1000:
		var direction := player.global_position.direction_to(destination)
		var displacement: Vector2 = MovementRulesScript.displacement(direction, player.move_speed, DELTA)
		if displacement.length() > player.global_position.distance_to(destination):
			player.global_position = destination
		else:
			player.global_position += displacement
		player.facing = direction
		steps += 1
	player.moved.emit(player.global_position)
	return steps

func _find_pickup(kind: String) -> WorldPickup:
	for child: Node in get_children():
		if child is WorldPickup and (child as WorldPickup).kind == kind:
			return child as WorldPickup
	return null

func _draw() -> void:
	draw_rect(Rect2(-900.0, -600.0, 1800.0, 1200.0), Color("173f46"))
	for x: int in range(-860, 861, 80):
		for y: int in range(-560, 561, 80):
			draw_circle(Vector2(x, y), 2.0, Color("2c6261"))
	draw_rect(Rect2(-880.0, -580.0, 1760.0, 1160.0), Color("7ac6a3"), false, 6.0)
