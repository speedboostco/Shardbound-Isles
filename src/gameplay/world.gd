class_name FirstPlayableWorld
extends Node2D

const EQUIPMENT_SEED: int = 424242
const DEFAULT_SAVE_PATH: String = "user://shardbound-save.json"
const ISLAND_SHARD_SEED: int = 9001
const BASE_TREE_YIELD: int = 3
const BASE_ENEMY_SPEED: float = 75.0
const BASE_RANGED_SPEED: float = 65.0
const BASE_ELITE_SPEED: float = 85.0
const RANGED_LOOT_SEED: int = 424243
const ELITE_LOOT_SEED: int = 424244

@onready var player: PlayerCharacter = $Player
@onready var tree: ResourceNode = $Tree
@onready var enemy: ChaserEnemy = $Enemy
@onready var workbench: Workbench = $Workbench
@onready var tidecatcher: Tidecatcher = $Tidecatcher
@onready var island_slot: IslandSlot = $IslandSlot
@onready var ranged_enemy: RangedEnemy = $RangedEnemy
@onready var elite_ranged_enemy: RangedEnemy = $EliteRangedEnemy
@onready var hud: GameHud = $HUD

var wood: int = 0
var equipment_inventory := EquipmentInventory.new()
var equipment: Array[Dictionary] = equipment_inventory.items
var enemies_defeated: int = 0
var crafting_service := CraftingService.new()
var reinforced_heart_crafted: bool = false
var tidecatcher_built: bool = false
var save_service := SaveService.new()
var island_shards: Array[Dictionary] = []
var installed_shard: Dictionary = {}

func _ready() -> void:
	player.attack_requested.connect(_on_attack_requested)
	player.health_changed.connect(hud.set_health)
	tree.depleted.connect(_on_tree_depleted)
	enemy.target = player
	enemy.defeated.connect(_on_enemy_defeated)
	ranged_enemy.target = player
	elite_ranged_enemy.target = player
	ranged_enemy.volley_requested.connect(_on_enemy_volley_requested)
	elite_ranged_enemy.volley_requested.connect(_on_enemy_volley_requested)
	ranged_enemy.defeated.connect(_on_ranged_enemy_defeated)
	elite_ranged_enemy.defeated.connect(_on_ranged_enemy_defeated)
	hud.set_health(player.health, player.maximum_health)
	hud.set_wood(wood)
	hud.equipment_panel_requested.connect(open_equipment_panel)
	hud.equipment_panel_closed.connect(_on_equipment_panel_closed)
	hud.equip_requested.connect(equip_selected_item)
	hud.salvage_requested.connect(salvage_selected_item)
	hud.unequip_requested.connect(unequip_item)
	hud.workbench_panel_requested.connect(try_open_workbench)
	hud.workbench_panel_closed.connect(_on_workbench_panel_closed)
	hud.craft_requested.connect(craft_reinforced_heart)
	hud.tidecatcher_build_requested.connect(build_tidecatcher)
	hud.system_menu_requested.connect(open_system_menu)
	hud.system_menu_closed.connect(_on_system_menu_closed)
	hud.save_requested.connect(save_game)
	hud.load_requested.connect(load_game)
	hud.island_panel_requested.connect(open_island_panel)
	hud.island_panel_closed.connect(_on_island_panel_closed)
	hud.island_install_requested.connect(install_selected_shard)
	hud.island_remove_requested.connect(remove_installed_shard)
	tidecatcher.wood_collected.connect(_on_tidecatcher_wood_collected)
	tidecatcher.storage_changed.connect(_on_tidecatcher_storage_changed)
	_refresh_equipment_ui()
	_refresh_workbench_ui()
	_refresh_island_ui()

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

func _on_tree_depleted(drop_position: Vector2, amount: int) -> void:
	_spawn_pickup(drop_position, "wood", amount)

func _on_enemy_defeated(drop_position: Vector2) -> void:
	enemies_defeated += 1
	_spawn_pickup(drop_position, "equipment", EquipmentGenerator.generate(EQUIPMENT_SEED))
	_spawn_pickup(drop_position + Vector2(25.0, 0.0), "island_shard", IslandShardGenerator.generate(ISLAND_SHARD_SEED))

func _on_ranged_enemy_defeated(drop_position: Vector2, loot_seed: int) -> void:
	enemies_defeated += 1
	_spawn_pickup(drop_position, "equipment", EquipmentGenerator.generate(loot_seed))

func _on_enemy_volley_requested(origin: Vector2, base_direction: Vector2, angles: Array[float], damage: int) -> void:
	for angle: float in angles:
		spawn_enemy_projectile(origin, base_direction.rotated(angle), damage)

func spawn_enemy_projectile(origin: Vector2, projectile_direction: Vector2, projectile_damage: int) -> EnemyProjectile:
	var projectile := EnemyProjectile.new()
	projectile.target = player
	projectile.global_position = origin
	projectile.direction = projectile_direction
	projectile.damage = projectile_damage
	add_child(projectile)
	return projectile

func _spawn_pickup(drop_position: Vector2, kind: String, payload: Variant) -> WorldPickup:
	var pickup := WorldPickup.new()
	pickup.kind = kind
	pickup.payload = payload
	pickup.target = player
	pickup.position = drop_position
	pickup.collected.connect(_on_pickup_collected)
	add_child(pickup)
	return pickup

func _on_pickup_collected(kind: String, payload: Variant) -> void:
	if kind == "wood":
		wood += int(payload)
		hud.set_wood(wood)
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
	player.attack_damage = equipment_inventory.attack_damage()
	_refresh_equipment_ui()
	return equipped

func unequip_item() -> bool:
	var unequipped := equipment_inventory.unequip()
	player.attack_damage = equipment_inventory.attack_damage()
	_refresh_equipment_ui()
	return unequipped

func salvage_selected_item(index: int) -> int:
	var reward := equipment_inventory.salvage(index)
	_refresh_equipment_ui()
	return reward

func _refresh_equipment_ui() -> void:
	hud.refresh_equipment(equipment_inventory.items, equipment_inventory.equipped_item(), equipment_inventory.scrap, equipment_inventory.attack_damage())
	_refresh_workbench_ui()

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

func craft_reinforced_heart() -> bool:
	var result := crafting_service.craft(wood, equipment_inventory.scrap, reinforced_heart_crafted)
	if not bool(result.get("success", false)):
		var reason := String(result.get("reason", ""))
		_refresh_workbench_ui("ALREADY CRAFTED" if reason == "already_crafted" else "NEED MORE RESOURCES")
		return false
	wood -= int(result.get("wood_spent", 0))
	equipment_inventory.scrap -= int(result.get("scrap_spent", 0))
	reinforced_heart_crafted = true
	player.add_maximum_health(int(result.get("maximum_health_bonus", 0)))
	refresh_all_ui("CRAFTED — MAX HEALTH +2")
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
	wood += amount
	hud.set_wood(wood)
	hud.set_automation_status(true, 0, WoodProduction.STORAGE_CAPACITY, "TIDECATCHER COLLECTED +%d WOOD" % amount)

func _on_tidecatcher_storage_changed(stored: int, capacity: int) -> void:
	hud.set_automation_status(true, stored, capacity)

func refresh_all_ui(crafting_feedback: String = "") -> void:
	hud.set_health(player.health, player.maximum_health)
	hud.set_wood(wood)
	_refresh_equipment_ui()
	_refresh_workbench_ui(crafting_feedback)
	_refresh_island_ui()

func _refresh_workbench_ui(feedback: String = "") -> void:
	hud.refresh_workbench(wood, equipment_inventory.scrap, reinforced_heart_crafted, tidecatcher_built, feedback)

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
	hud.set_system_feedback("GAME SAVED" if succeeded else "SAVE FAILED — %s" % String(result.get("error", "unknown")).to_upper())
	return succeeded

func load_game(path: String = DEFAULT_SAVE_PATH) -> bool:
	var result := save_service.load_from_path(path)
	if not bool(result.get("ok", false)):
		hud.set_system_feedback("LOAD FAILED — %s" % String(result.get("error", "unknown")).to_upper())
		return false
	_apply_state(result.get("state") as Dictionary)
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
		"equipment": {
			"scrap": equipment_inventory.scrap,
			"equipped_id": equipment_inventory.equipped_id,
			"items": saved_items,
		},
		"reinforced_heart_crafted": reinforced_heart_crafted,
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
	equipment_inventory.items.clear()
	for item_value: Variant in equipment_state.items:
		equipment_inventory.items.append((item_value as Dictionary).duplicate(true))
	equipment_inventory.scrap = maxi(0, int(equipment_state.scrap))
	equipment_inventory.equipped_id = String(equipment_state.equipped_id)
	if equipment_inventory.equipped_item().is_empty():
		equipment_inventory.equipped_id = ""
	player.attack_damage = equipment_inventory.attack_damage()
	reinforced_heart_crafted = bool(state.reinforced_heart_crafted)
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
	_apply_island_modifiers()
	_refresh_island_ui()
	return true

func remove_installed_shard() -> bool:
	if installed_shard.is_empty():
		return false
	installed_shard = {}
	_apply_island_modifiers()
	_refresh_island_ui()
	return true

func _apply_island_modifiers() -> void:
	var yield_bonus := int(installed_shard.get("tree_yield_bonus", 0))
	var speed_multiplier := float(installed_shard.get("enemy_speed_multiplier", 1.0))
	if is_instance_valid(tree):
		tree.wood_yield = BASE_TREE_YIELD + yield_bonus
	if is_instance_valid(enemy):
		enemy.move_speed = BASE_ENEMY_SPEED * speed_multiplier
	if is_instance_valid(ranged_enemy):
		ranged_enemy.move_speed = BASE_RANGED_SPEED * speed_multiplier
	if is_instance_valid(elite_ranged_enemy):
		elite_ranged_enemy.move_speed = BASE_ELITE_SPEED * speed_multiplier
	island_slot.set_installed(not installed_shard.is_empty(), String(installed_shard.get("name", "")))

func _refresh_island_ui() -> void:
	hud.refresh_islands(island_shards, installed_shard)

func _has_shard(shard_id: String) -> bool:
	for shard: Dictionary in island_shards:
		if String(shard.get("id", "")) == shard_id:
			return true
	return false

func _set_combat_processing(enabled: bool) -> void:
	for combatant: Node in [enemy, ranged_enemy, elite_ranged_enemy]:
		if is_instance_valid(combatant):
			combatant.set_physics_process(enabled)
	for child: Node in get_children():
		if child is EnemyProjectile:
			child.set_process(enabled)

func run_scripted_smoke() -> Dictionary:
	tree.receive_attack(1)
	tree.receive_attack(1)
	var wood_pickup := _find_pickup("wood")
	wood_pickup.collect_immediately()
	enemy.receive_attack(1)
	enemy.receive_attack(1)
	enemy.receive_attack(1)
	var equipment_pickup := _find_pickup("equipment")
	equipment_pickup.collect_immediately()
	return {
		"seed": EQUIPMENT_SEED,
		"wood": wood,
		"enemies_defeated": enemies_defeated,
		"items_collected": equipment.size(),
		"item": equipment[0] if not equipment.is_empty() else {},
	}

func _find_pickup(kind: String) -> WorldPickup:
	for child: Node in get_children():
		if child is WorldPickup and (child as WorldPickup).kind == kind:
			return child as WorldPickup
	return null

func _draw() -> void:
	draw_rect(Rect2(-640.0, -400.0, 1280.0, 800.0), Color("173f46"))
	for x: int in range(-600, 601, 80):
		for y: int in range(-360, 361, 80):
			draw_circle(Vector2(x, y), 2.0, Color("2c6261"))
	draw_rect(Rect2(-620.0, -370.0, 1240.0, 740.0), Color("7ac6a3"), false, 6.0)
