class_name FirstPlayableWorld
extends Node2D

const GameLoggerScript := preload("res://game/core/game_logger.gd")
const InteractionSelectorScript := preload("res://game/core/interaction_selector.gd")
const MovementRulesScript := preload("res://game/core/movement_rules.gd")
const ResourceInventoryScript := preload("res://game/core/resource_inventory.gd")
const LivingWorldPropScript := preload("res://game/features/living_world_prop.gd")
const WorldObstacleScript := preload("res://game/features/world_obstacle.gd")
const WeaponCastVisualScript := preload("res://game/features/weapon_cast_visual.gd")
const TechnologyTreeScript := preload("res://game/core/technology_tree.gd")
const WorldResidentScript := preload("res://game/features/world_resident.gd")
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
const LIVING_WORLD_LAYOUT: Array[Dictionary] = [
	{"id": "moonleaf_west", "type": "moonleaf_thicket", "position": Vector2(-155, -55)},
	{"id": "moonleaf_south", "type": "moonleaf_thicket", "position": Vector2(235, 155)},
	{"id": "moonleaf_edge", "type": "moonleaf_thicket", "position": Vector2(-690, -155)},
	{"id": "tidewell_north", "type": "tidewell", "position": Vector2(-285, -300)},
	{"id": "whispering_shrine_south", "type": "whispering_shrine", "position": Vector2(120, 360)},
	{"id": "firefly_east", "type": "firefly_hollow", "position": Vector2(610, -195)},
	{"id": "firefly_south_east", "type": "firefly_hollow", "position": Vector2(565, 205)},
]
const HANDDRAWN_DECO_LAYOUT: Array[Dictionary] = [
	{"position": Vector2(-770, -440), "frame": 6}, {"position": Vector2(-610, -315), "frame": 4},
	{"position": Vector2(-430, -220), "frame": 0}, {"position": Vector2(-260, -315), "frame": 5},
	{"position": Vector2(205, -355), "frame": 7}, {"position": Vector2(410, -250), "frame": 2},
	{"position": Vector2(690, -390), "frame": 4}, {"position": Vector2(755, -145), "frame": 1},
	{"position": Vector2(-735, 135), "frame": 3}, {"position": Vector2(-560, 330), "frame": 6},
	{"position": Vector2(-365, 205), "frame": 1}, {"position": Vector2(-185, 415), "frame": 5},
	{"position": Vector2(235, 260), "frame": 0}, {"position": Vector2(395, 425), "frame": 7},
	{"position": Vector2(590, 300), "frame": 4}, {"position": Vector2(760, 465), "frame": 2},
	{"position": Vector2(-835, -120), "frame": 2}, {"position": Vector2(-655, -405), "frame": 7},
	{"position": Vector2(-510, -455), "frame": 3}, {"position": Vector2(-335, -435), "frame": 0},
	{"position": Vector2(-105, -485), "frame": 6}, {"position": Vector2(125, -455), "frame": 1},
	{"position": Vector2(350, -475), "frame": 5}, {"position": Vector2(570, -465), "frame": 3},
	{"position": Vector2(-825, 385), "frame": 7}, {"position": Vector2(-665, 470), "frame": 0},
	{"position": Vector2(-475, 485), "frame": 4}, {"position": Vector2(-295, 505), "frame": 2},
	{"position": Vector2(105, 505), "frame": 5}, {"position": Vector2(300, 485), "frame": 1},
	{"position": Vector2(500, 500), "frame": 6}, {"position": Vector2(835, 120), "frame": 0},
	{"position": Vector2(-585, -245), "frame": 0}, {"position": Vector2(-475, -155), "frame": 5},
	{"position": Vector2(-365, -345), "frame": 1}, {"position": Vector2(-245, -205), "frame": 6},
	{"position": Vector2(-125, -325), "frame": 2}, {"position": Vector2(135, -310), "frame": 7},
	{"position": Vector2(255, -220), "frame": 3}, {"position": Vector2(385, -335), "frame": 4},
	{"position": Vector2(515, -235), "frame": 1}, {"position": Vector2(625, -125), "frame": 6},
	{"position": Vector2(-595, 185), "frame": 5}, {"position": Vector2(-455, 305), "frame": 0},
	{"position": Vector2(-315, 175), "frame": 7}, {"position": Vector2(-155, 285), "frame": 2},
	{"position": Vector2(155, 215), "frame": 4}, {"position": Vector2(325, 335), "frame": 1},
	{"position": Vector2(475, 185), "frame": 6}, {"position": Vector2(615, 295), "frame": 3},
]
const WORLD_OBSTACLE_LAYOUT: Array[Dictionary] = [
	{"position": Vector2(-825, -500), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-690, -510), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-545, -515), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(525, -510), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(680, -505), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(825, -495), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-840, -315), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-845, 285), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(845, -305), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(840, 315), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-790, 510), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-625, 515), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(610, 510), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(780, 505), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-505, 430), "asset": "boulder", "radius": 18.0},
	{"position": Vector2(485, -430), "asset": "boulder", "radius": 18.0},
	{"position": Vector2(-735, -370), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-625, -385), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-745, 390), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-650, 405), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(705, -345), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(770, -250), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(690, 390), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(775, 315), "asset": "forest_tree", "radius": 20.0},
	{"position": Vector2(-520, -365), "asset": "boulder", "radius": 18.0},
	{"position": Vector2(430, 370), "asset": "boulder", "radius": 18.0},
	{"position": Vector2(555, 425), "asset": "boulder", "radius": 18.0},
	{"position": Vector2(-590, 370), "asset": "boulder", "radius": 18.0},
]

@onready var player: PlayerCharacter = $Player
@onready var tree: ResourceNode = $Tree
@onready var stone_node: ResourceNode = $StoneNode
@onready var enemy: ChaserEnemy = $Enemy
@onready var second_slime: ChaserEnemy = $SecondSlime
@onready var camera: CameraRig = $Player/Camera2D
@onready var workbench: Workbench = $Workbench
@onready var tidecatcher: Tidecatcher = $Tidecatcher
@onready var base_buildings: Node2D = $BaseBuildings
@onready var island_slot: IslandSlot = $IslandSlot
@onready var north_east_island_slot: IslandSlot = $NorthEastIslandSlot
@onready var south_east_island_slot: IslandSlot = $SouthEastIslandSlot
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
var moonleaf: int:
	get: return resource_inventory.amount("moonleaf")
	set(value): resource_inventory.set_amount("moonleaf", maxi(0, value))
var plank: int:
	get: return resource_inventory.amount("plank")
	set(value): resource_inventory.set_amount("plank", maxi(0, value))
var equipment_inventory := EquipmentInventory.new()
var equipment: Array[Dictionary] = equipment_inventory.items
var enemies_defeated: int = 0
var crafting_service := CraftingService.new()
var technology_tree: Variant = TechnologyTreeScript.new()
var reinforced_heart_crafted: bool = false
var runed_whetstone_crafted: bool = false
var herbal_compass_crafted: bool = false
var tidecatcher_built: bool = false
var save_service := SaveService.new()
var island_shards: Array[Dictionary] = []
var installed_shard: Dictionary = {}
var archipelago := ArchipelagoModel.new(SaveService.DEFAULT_WORLD_SEED)
var island_slots: Dictionary = {}
var rift_controller := RiftRunController.new()
var rift_enemies: Array[Node2D] = []
var _rift_spawn_delay_remaining: float = 0.0
var logger: Variant = GameLoggerScript.new(bool(ProjectSettings.get_setting("shardbound/logging/debug_enabled", false)))
var current_interaction_target: Node
var loot_filter := LootFilter.new()
var legendary_event_bus := LegendaryEventBus.new()
var legendary_manager := LegendaryBehaviorManager.new(legendary_event_bus)
var vfx_settings := VfxSettings.from_project_settings()
var _legendary_effect_handlers: Dictionary = {}
var _attack_index: int = 0
var _event_tick: int = 0
var _pickup_spawn_order: int = 0
var _burning_targets: Dictionary = {}
var base_placement := BasePlacementModel.new()
var shared_storage := SharedStorage.new()
var lumber_mill_simulation := LumberMillSimulation.new()
var collector_simulation := CollectorSimulation.new()
var crafted_building_kits: Dictionary = {"lumber_mill_kit": false, "collector_kit": false}
var last_simulation_unix: int = 0
var _building_nodes: Dictionary = {}
var _placement_visual: BaseBuildingVisual
var _placement_socket_index: int = 0
var _automation_timer: Timer
var _living_world_props: Dictionary = {}
var _living_world_guardians: Dictionary = {}
var _world_obstacles: Array[WorldObstacle] = []
var _world_residents: Array[Node2D] = []
var _active_weapon_instance_id: String = ""
var _resolve_player_projectiles_immediately: bool = false
const PLACEMENT_SOCKET_IDS: Array[String] = ["west", "north", "east", "south"]
const PLACEMENT_WORLD_POSITIONS: Dictionary = {"west": Vector2(-245, -285), "north": Vector2(0, -390), "east": Vector2(245, -285), "south": Vector2(0, 55)}

func _ready() -> void:
	y_sort_enabled = true
	island_slots = {"east": island_slot, "north_east": north_east_island_slot, "south_east": south_east_island_slot}
	island_slot.configure_slot("east", Vector2i(1, 0))
	north_east_island_slot.configure_slot("north_east", Vector2i(1, -1))
	south_east_island_slot.configure_slot("south_east", Vector2i(2, -1))
	if archipelago.slots.is_empty():
		archipelago.initialize_default_slots()
	_legendary_effect_handlers = {
		"riftwake_pulse": Callable(self, "_handle_riftwake_effect"),
		"chain_mining": Callable(self, "_handle_chain_mining_effect"),
		"burning_smelter": Callable(self, "_handle_burning_smelter_effect"),
		"living_arrows": Callable(self, "_handle_living_arrows_effect"),
	}
	legendary_event_bus.effect_triggered.connect(_on_legendary_effect_triggered)
	player.attack_requested.connect(_on_attack_requested)
	player.interaction_requested.connect(_on_interaction_requested)
	player.moved.connect(_on_player_moved)
	player.health_changed.connect(hud.set_health)
	player.mana_changed.connect(hud.set_mana)
	player.mana_spend_failed.connect(_on_mana_spend_failed)
	player.defeated.connect(_on_player_defeated)
	resource_inventory.changed.connect(_on_resource_inventory_changed)
	equipment_inventory.inventory_changed.connect(_on_equipment_inventory_changed)
	equipment_inventory.equipment_changed.connect(_on_equipment_changed)
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
	hud.set_moonleaf(moonleaf)
	hud.set_plank(plank)
	hud.equipment_panel_requested.connect(open_equipment_panel)
	hud.equipment_panel_closed.connect(_on_equipment_panel_closed)
	hud.equip_requested.connect(equip_selected_item)
	hud.salvage_requested.connect(salvage_selected_item)
	hud.favorite_requested.connect(set_item_favorite)
	hud.unequip_requested.connect(unequip_item)
	hud.technology_learn_requested.connect(learn_technology)
	hud.workbench_panel_requested.connect(try_open_workbench)
	hud.workbench_panel_closed.connect(_on_workbench_panel_closed)
	hud.craft_requested.connect(_on_craft_requested)
	hud.tidecatcher_build_requested.connect(build_tidecatcher)
	hud.upgrade_requested.connect(upgrade_equipped_item)
	hud.placement_socket_requested.connect(cycle_placement_socket)
	hud.placement_rotate_requested.connect(rotate_building_preview)
	hud.placement_confirm_requested.connect(confirm_building_placement)
	hud.placement_cancel_requested.connect(cancel_building_placement)
	hud.base_deposit_requested.connect(func(resource_id: String) -> void: deposit_base_resource(resource_id, resource_inventory.amount(resource_id)))
	hud.base_withdraw_requested.connect(func(resource_id: String) -> void: withdraw_base_resource(resource_id, shared_storage.amount(resource_id)))
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
	_automation_timer = Timer.new()
	_automation_timer.wait_time = 0.5
	_automation_timer.autostart = true
	_automation_timer.timeout.connect(_on_automation_tick)
	add_child(_automation_timer)
	last_simulation_unix = int(Time.get_unix_time_from_system())
	_refresh_equipment_ui()
	_refresh_workbench_ui()
	_refresh_island_ui()
	_rebuild_materialized_islands()
	_spawn_world_obstacles()
	_spawn_living_world_props()
	_spawn_world_residents()
	_sync_combat_phase(false)
	_refresh_interaction_target()

func _process(delta: float) -> void:
	advance_rift_spawn(delta)

func _spawn_living_world_props() -> void:
	if not _living_world_props.is_empty():
		return
	for placement: Dictionary in LIVING_WORLD_LAYOUT:
		var prop := LivingWorldPropScript.new() as LivingWorldProp
		prop.name = String(placement.id).to_pascal_case()
		prop.position = placement.position as Vector2
		prop.configure(String(placement.type), String(placement.id), player)
		prop.effect_requested.connect(_on_living_world_effect_requested)
		prop.availability_changed.connect(_refresh_interaction_target)
		add_child(prop)
		_living_world_props[prop.stable_id] = prop

func _spawn_world_obstacles() -> void:
	if not _world_obstacles.is_empty():
		return
	for placement: Dictionary in WORLD_OBSTACLE_LAYOUT:
		var obstacle := WorldObstacleScript.new() as WorldObstacle
		obstacle.name = "WorldObstacle%d" % _world_obstacles.size()
		obstacle.position = placement.position as Vector2
		obstacle.configure(String(placement.asset), float(placement.radius), 4.0)
		add_child(obstacle)
		_world_obstacles.append(obstacle)

func _spawn_world_residents() -> void:
	if not _world_residents.is_empty():
		return
	var definitions: Array[Dictionary] = [
		{"id": "mira", "name": "MIRA", "role": "CARTOGRAPHER", "position": Vector2(-120, -130), "actor": "hero_unarmed", "messages": ["This island is quiet until you choose to wake it.", "Gather wood and stone, then learn Fieldcraft in your inventory.", "Every shard changes both opportunity and risk."]},
		{"id": "orin", "name": "ORIN", "role": "ARCANIST", "position": Vector2(165, -145), "actor": "boss", "messages": ["A scepter spends mana; watch the violet range sigil before casting.", "Moonleaf unlocks deeper channeling and faster recovery.", "Power is useful only when its cost changes your decisions."]},
	]
	for definition: Dictionary in definitions:
		var resident: Variant = WorldResidentScript.new()
		resident.name = String(definition.id).to_pascal_case()
		resident.position = definition.position as Vector2
		resident.configure(String(definition.id), String(definition.name), String(definition.role), definition.messages as Array, String(definition.actor))
		resident.spoken.connect(_on_resident_spoken)
		add_child(resident)
		_world_residents.append(resident)

func _on_resident_spoken(resident_name: String, message: String) -> void:
	hud.set_encounter_feedback("%s — %s" % [resident_name, message])

func world_resident_count() -> int:
	return _world_residents.size()

func world_obstacle_count() -> int:
	return _world_obstacles.size()

func non_colliding_detail_count() -> int:
	return HANDDRAWN_DECO_LAYOUT.size()

func terrain_micro_biome_count() -> int:
	return 4

func living_world_prop_count() -> int:
	return _living_world_props.size()

func living_world_prop(stable_id: String) -> LivingWorldProp:
	return _living_world_props.get(stable_id) as LivingWorldProp

func active_living_world_guardian_count() -> int:
	var active := 0
	for guardian_value: Variant in _living_world_guardians.values():
		if is_instance_valid(guardian_value as Node) and not (guardian_value as Node).is_queued_for_deletion():
			active += 1
	return active

func _on_living_world_effect_requested(source: LivingWorldProp, effect_id: String, amount: int) -> void:
	match effect_id:
		"resource_reward":
			_spawn_pickup(source.global_position + Vector2(0, 24), "moonleaf", amount)
			_spawn_gameplay_vfx(source.global_position, "reward")
			hud.set_encounter_feedback("MOONLEAF THICKET — LUMINOUS HERBS READY")
		"heal":
			player.health_component.heal(amount)
			_spawn_gameplay_vfx(source.global_position, "reward")
			hud.set_encounter_feedback("TIDEWELL — HEALTH RESTORED")
		"resource_cache":
			_spawn_pickup(source.global_position + Vector2(-12, 20), "wood", amount)
			_spawn_pickup(source.global_position + Vector2(12, 20), "stone", amount)
			_spawn_gameplay_vfx(source.global_position, "pickup")
			hud.set_encounter_feedback("FIREFLIES REVEALED A HIDDEN CACHE")
		"guardian_challenge":
			if not is_combat_unlocked():
				hud.set_encounter_feedback("THE SHRINE IS DORMANT — LEARN COMBAT TRAINING")
				return
			_spawn_living_world_guardian(source, amount)
	_refresh_interaction_target()

func _spawn_living_world_guardian(source: LivingWorldProp, reward_amount: int) -> RangedEnemy:
	var existing: Node = _living_world_guardians.get(source.stable_id) as Node
	if is_instance_valid(existing) and not existing.is_queued_for_deletion():
		return existing as RangedEnemy
	var guardian := RangedEnemy.new()
	guardian.name = "%sGuardian" % source.name
	guardian.elite = true
	guardian.move_speed = 72.0
	guardian.loot_seed = 730000 + abs(source.stable_id.hash() % 10000)
	guardian.target = player
	guardian.global_position = source.global_position + Vector2(0, 105)
	guardian.volley_requested.connect(_on_enemy_volley_requested)
	guardian.defeated.connect(_on_living_world_guardian_defeated.bind(source, guardian, reward_amount))
	add_child(guardian)
	_living_world_guardians[source.stable_id] = guardian
	_spawn_gameplay_vfx(guardian.global_position, "rift")
	hud.set_encounter_feedback("WHISPERING SHRINE — GUARDIAN AWAKENED")
	return guardian

func _on_living_world_guardian_defeated(drop_position: Vector2, _loot_seed: int, source: LivingWorldProp, guardian: RangedEnemy, reward_amount: int) -> void:
	if is_instance_valid(guardian):
		_emit_enemy_killed(guardian, drop_position)
	_living_world_guardians.erase(source.stable_id)
	if is_instance_valid(source):
		source.complete_challenge()
	enemies_defeated += 1
	_spawn_gameplay_vfx(drop_position, "death")
	_spawn_pickup(drop_position, "moonleaf", reward_amount)
	hud.set_encounter_feedback("SHRINE GUARDIAN DEFEATED — MOONLEAF REWARD")
	_check_boss_unlock()

func _on_attack_requested(origin: Vector2, direction: Vector2) -> void:
	_attack_index += 1
	_event_tick += 20
	var candidates: Array[Dictionary] = []
	var targets_by_id: Dictionary = {}
	for candidate: Node in get_tree().get_nodes_in_group("attackable"):
		if not candidate is Node2D:
			continue
		var target_node := candidate as Node2D
		var target_id := str(target_node.get_instance_id())
		candidates.append({"id": target_id, "position": target_node.global_position})
		targets_by_id[target_id] = target_node
	var selected_ids := AttackProfileRules.select_targets(origin, direction, candidates, player.attack_profile)
	var primary_target: Node2D
	var critical_rng := SeededRngStreams.from_seed(_equipped_weapon_seed() ^ (_attack_index * 65537))
	var primary_damage := player.attack_damage
	var critical := critical_rng.randf() < player.critical_chance
	if critical:
		primary_damage = maxi(1, roundi(float(primary_damage) * player.critical_damage))
	var weapon_type := _canonical_weapon_type()
	_spawn_weapon_cast_visual(origin, direction, weapon_type, float(player.attack_profile.get("range", 90.0)))
	for index: int in selected_ids.size():
		var target_node: Node = targets_by_id.get(selected_ids[index])
		if not is_instance_valid(target_node) or not target_node.has_method("receive_attack"):
			continue
		if index == 0:
			primary_target = target_node as Node2D
		var damage := primary_damage if index == 0 else maxi(1, primary_damage / 2)
		if target_node is ResourceNode:
			damage = maxi(1, roundi(player.gathering_power))
		if weapon_type == "bow":
			_spawn_player_projectile(origin, direction, target_node as Node2D, damage, critical and index == 0)
			continue
		var target_position := (target_node as Node2D).global_position
		target_node.receive_attack(damage)
		legendary_event_bus.emit_hit({"target_id": selected_ids[index], "position": target_position, "damage": damage, "critical": critical and index == 0, "weapon_type": weapon_type})
		if critical and index == 0:
			legendary_event_bus.emit_critical_hit({"target_id": selected_ids[index], "position": target_position, "damage": damage, "weapon_type": weapon_type})
		_spawn_gameplay_vfx(target_position, "gather_hit" if target_node is ResourceNode else ("critical_hit" if critical and index == 0 else "normal_hit"))
		if _canonical_weapon_type() == "wand" and not target_node is ResourceNode:
			_burning_targets[str(target_node.get_instance_id())] = true
	if weapon_type == "bow" and selected_ids.is_empty():
		_spawn_player_projectile(origin, direction, null, 1, false)
	if is_instance_valid(primary_target) and weapon_type != "bow":
		player.confirm_hit()
		camera.request_shake(4.0 * vfx_settings.shake_scale(), 0.1)
		if primary_target is ResourceNode:
			_emit_resource_hit(primary_target, primary_damage)
	var impact_position := primary_target.global_position if is_instance_valid(primary_target) else origin + direction.normalized() * 90.0
	legendary_event_bus.emit_attack({"origin": origin, "impact_position": impact_position, "primary_target_id": str(primary_target.get_instance_id()) if is_instance_valid(primary_target) else "", "weapon_type": _canonical_weapon_type(), "seed": _equipped_weapon_seed(), "attack_index": _attack_index})

func _spawn_weapon_cast_visual(origin: Vector2, direction: Vector2, weapon_type: String, attack_range: float) -> void:
	if weapon_type not in ["bow", "wand"]:
		return
	var visual: Node2D = WeaponCastVisualScript.new() as Node2D
	visual.global_position = origin
	visual.configure("magic" if weapon_type == "wand" else "bow", direction, attack_range)
	add_child(visual)

func _spawn_player_projectile(origin: Vector2, direction: Vector2, target_node: Node2D, damage: int, critical: bool = false) -> PlayerWeaponProjectile:
	var projectile := PlayerWeaponProjectile.new()
	projectile.global_position = origin
	projectile.configure(target_node, damage, direction, critical, _equipped_weapon_seed(), _attack_index)
	projectile.impacted.connect(_on_player_projectile_impacted)
	add_child(projectile)
	if _resolve_player_projectiles_immediately:
		projectile.resolve_immediately()
	return projectile

func _on_player_projectile_impacted(target_node: Node2D, damage: int, critical: bool, weapon_seed: int, attack_index: int) -> void:
	if not is_instance_valid(target_node) or not target_node.has_method("receive_attack"):
		return
	var target_position := target_node.global_position
	target_node.receive_attack(damage)
	legendary_event_bus.emit_hit({"target_id": str(target_node.get_instance_id()), "position": target_position, "damage": damage, "critical": critical, "weapon_type": "bow", "seed": weapon_seed, "attack_index": attack_index})
	if critical:
		legendary_event_bus.emit_critical_hit({"target_id": str(target_node.get_instance_id()), "position": target_position, "damage": damage, "weapon_type": "bow"})
	_spawn_gameplay_vfx(target_position, "gather_hit" if target_node is ResourceNode else ("critical_hit" if critical else "projectile_impact"))
	player.confirm_hit()
	camera.request_shake(4.0 * vfx_settings.shake_scale(), 0.1)
	if target_node is ResourceNode:
		_emit_resource_hit(target_node, damage)

func _clear_player_weapon_effects() -> void:
	for projectile: Node in get_tree().get_nodes_in_group("player_weapon_projectile"):
		if is_ancestor_of(projectile):
			projectile.queue_free()

func _canonical_weapon_type() -> String:
	return "bow" if player.weapon_base_type == "ranged" else ("wand" if player.weapon_base_type == "magic" else ("sword" if player.weapon_base_type == "melee" else player.weapon_base_type))

func _equipped_weapon_seed() -> int:
	return int(equipment_inventory.equipped_item("weapon").get("seed", EQUIPMENT_SEED))

func _emit_resource_hit(primary_target: Node2D, source_damage: int) -> void:
	var nearby: Array[Dictionary] = []
	for candidate: Node in get_tree().get_nodes_in_group("attackable"):
		if not candidate is Node2D or candidate == primary_target:
			continue
		var target_node := candidate as Node2D
		var distance := primary_target.global_position.distance_to(target_node.global_position)
		if distance <= 150.0:
			nearby.append({"id": str(target_node.get_instance_id()), "kind": "resource" if target_node is ResourceNode else "enemy", "distance": distance})
	legendary_event_bus.emit_resource_hit({"tick": _event_tick, "chain_depth": 0, "source_damage": source_damage, "origin": primary_target.global_position, "targets": nearby})

func _on_legendary_effect_triggered(effect_id: String, payload: Dictionary) -> void:
	var handler: Callable = _legendary_effect_handlers.get(effect_id, Callable())
	if handler.is_valid():
		handler.call(payload)

func _handle_riftwake_effect(payload: Dictionary) -> void:
	var primary: Node2D
	var primary_id := String(payload.get("primary_target_id", ""))
	if not primary_id.is_empty():
		var value: Object = instance_from_id(int(primary_id))
		if value is Node2D:
			primary = value as Node2D
	_trigger_legendary_pulse(payload.get("origin", player.global_position) as Vector2, primary)

func _handle_chain_mining_effect(payload: Dictionary) -> void:
	var target_positions: Array[Vector2] = []
	for target_value: Variant in payload.get("targets", []):
		if not target_value is Dictionary:
			continue
		var target: Object = instance_from_id(int((target_value as Dictionary).get("id", "0")))
		if is_instance_valid(target) and target.has_method("receive_attack"):
			if target is Node2D:
				target_positions.append((target as Node2D).global_position)
			target.receive_attack(int(payload.get("damage", 1)))
	_spawn_legendary_visual(payload.get("origin", player.global_position) as Vector2, "chain_mining", target_positions)

func _handle_burning_smelter_effect(payload: Dictionary) -> void:
	var ore_id := String(payload.get("ore_id", ""))
	if not ore_id.is_empty():
		var ore: Object = instance_from_id(int(ore_id))
		if is_instance_valid(ore) and ore is ResourceNode:
			ore.receive_attack((ore as ResourceNode).remaining_hits)
	else:
		var awarded := int(payload.get("smelting_charges", 0))
		if awarded > 0:
			resource_inventory.add("smelting_charge", awarded)
			hud.set_encounter_feedback("BURNING SMELTER — +%d CHARGE; NEXT STONE YIELDS +1" % awarded)
	_spawn_legendary_visual(payload.get("position", player.global_position) as Vector2, "burning_smelter")

func _handle_living_arrows_effect(payload: Dictionary) -> void:
	if get_tree().get_nodes_in_group("temporary_legendary").size() >= 3:
		return
	var plant := LivingArrowPlant.new()
	plant.plant_id = String(payload.get("plant_id", ""))
	plant.lifetime = float(payload.get("lifetime", 6.0))
	plant.global_position = payload.get("position", player.global_position) as Vector2
	plant.expired.connect(legendary_event_bus.emit_temporary_expired)
	add_child(plant)
	_spawn_legendary_visual(plant.global_position, "living_arrows")

func _spawn_legendary_visual(position_value: Vector2, effect_id: String, target_positions: Array[Vector2] = []) -> void:
	var visual := LegendaryEffectVisual.new()
	visual.effect_id = effect_id
	visual.global_position = position_value
	for target_position: Vector2 in target_positions:
		visual.target_offsets.append(target_position - position_value)
	add_child(visual)

func _spawn_gameplay_vfx(position_value: Vector2, effect_kind: String) -> GameplayVfx:
	var visual := GameplayVfx.new()
	visual.configure(effect_kind, vfx_settings)
	visual.global_position = position_value
	add_child(visual)
	return visual

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
	legendary_event_bus.emit_resource_destroyed({"position": drop_position, "resource_id": resource_id, "amount": amount})
	_spawn_gameplay_vfx(drop_position, "resource_break")
	_spawn_pickup(drop_position, resource_id, amount)

func _on_enemy_defeated(drop_position: Vector2) -> void:
	_emit_enemy_killed(enemy, drop_position)
	_spawn_gameplay_vfx(drop_position, "death")
	enemies_defeated += 1
	logger.debug(GameLoggerScript.LOOT, "enemy loot generated", {"equipment_seed": EQUIPMENT_SEED, "island_seed": ISLAND_SHARD_SEED})
	if LootDropDecision.decide(EQUIPMENT_SEED, "arena_first_slime", 0.99):
		_spawn_pickup(drop_position, "equipment", EquipmentGenerator.generate(EQUIPMENT_SEED))
	_spawn_pickup(drop_position + Vector2(25.0, 0.0), "island_shard", IslandShardGenerator.generate(ISLAND_SHARD_SEED))
	_check_boss_unlock()

func _on_second_slime_defeated(_drop_position: Vector2) -> void:
	_emit_enemy_killed(second_slime, _drop_position)
	_spawn_gameplay_vfx(_drop_position, "death")
	enemies_defeated += 1
	logger.debug(GameLoggerScript.LOOT, "slime loot roll completed", {"enemy_id": "second_slime", "equipment_seed": EQUIPMENT_SEED})
	if LootDropDecision.decide(EQUIPMENT_SEED, "arena_second_slime", 0.01):
		_spawn_pickup(_drop_position, "equipment", EquipmentGenerator.generate(EQUIPMENT_SEED, "second_slime"))
	_check_boss_unlock()

func _on_ranged_enemy_defeated(drop_position: Vector2, loot_seed: int) -> void:
	_emit_enemy_killed(ranged_enemy if loot_seed == RANGED_LOOT_SEED else elite_ranged_enemy, drop_position)
	enemies_defeated += 1
	_spawn_gameplay_vfx(drop_position, "death")
	var base_id := "sword" if loot_seed == RANGED_LOOT_SEED else "wand"
	var rarity := "rare" if loot_seed == RANGED_LOOT_SEED else "epic"
	var item_level := 12 if loot_seed == RANGED_LOOT_SEED else 18
	_spawn_pickup(drop_position, "equipment", LootGenerator.generate(loot_seed, "arena", item_level, base_id, rarity))
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
	_emit_enemy_killed(boss, drop_position)
	_spawn_gameplay_vfx(drop_position, "death")
	_spawn_pickup(drop_position, "equipment", BossReward.generate())
	hud.set_encounter_feedback("WARDEN DEFEATED — RIFTWAKE CORE DROPPED")
	rift_portal.unlock()
	hud.set_rift_feedback("RIFT UNLOCKED — APPROACH PORTAL AND PRESS LB / K")

func _emit_enemy_killed(combatant: Node2D, death_position: Vector2) -> void:
	var combatant_id := str(combatant.get_instance_id())
	var nearby_ores: Array[Dictionary] = []
	if is_instance_valid(stone_node) and not stone_node.is_queued_for_deletion():
		var distance := death_position.distance_to(stone_node.global_position)
		if distance <= 220.0:
			nearby_ores.append({"id": str(stone_node.get_instance_id()), "distance": distance})
	legendary_event_bus.emit_enemy_killed({"enemy_id": combatant_id, "burning": bool(_burning_targets.get(combatant_id, false)), "nearby_ores": nearby_ores, "position": death_position})
	_burning_targets.erase(combatant_id)

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
	if kind == "equipment" and payload is Dictionary:
		var equipment_drops: Array[WorldPickup] = []
		var descriptions: Array[Dictionary] = []
		for child: Node in get_children():
			if child is WorldPickup:
				var existing := child as WorldPickup
				if existing.kind == "equipment" and not existing.is_queued_for_deletion() and existing.payload is Dictionary:
					equipment_drops.append(existing)
					descriptions.append({"rarity": String((existing.payload as Dictionary).get("rarity", "common")), "spawn_order": existing.spawn_order})
		if equipment_drops.size() >= LootDropPolicy.MAX_WORLD_EQUIPMENT:
			var eviction_index := LootDropPolicy.select_eviction(descriptions)
			if eviction_index >= 0:
				equipment_drops[eviction_index].queue_free()
			else:
				hud.set_encounter_feedback("LEGENDARY DROP PROTECTED — COLLECT IT")
				if not LootDropPolicy.is_important(payload as Dictionary):
					return null
	var pickup := WorldPickup.new()
	pickup.kind = kind
	pickup.payload = payload
	pickup.rarity = String(payload.get("rarity", "common")).to_lower() if payload is Dictionary else ("rare" if kind == "island_shard" else "ordinary")
	pickup.target = player
	pickup.position = drop_position
	pickup.spawn_order = _pickup_spawn_order
	_pickup_spawn_order += 1
	pickup.important = kind == "equipment" and payload is Dictionary and LootDropPolicy.is_important(payload as Dictionary)
	pickup.collector = _on_pickup_collected
	add_child(pickup)
	pickup.collected.connect(func(_kind: String, _payload: Variant) -> void:
		_spawn_gameplay_vfx(pickup.global_position, "reward" if pickup.important else "pickup")
	)
	if pickup.important:
		_spawn_gameplay_vfx(drop_position, "reward")
	return pickup

func _on_pickup_collected(kind: String, payload: Variant) -> bool:
	if kind in ["wood", "stone", "moonleaf", "plank"]:
		var amount := int(payload)
		if kind == "stone" and resource_inventory.amount("smelting_charge") > 0:
			resource_inventory.remove("smelting_charge", 1)
			amount += 1
			hud.set_encounter_feedback("BURNING SMELTER — CHARGE REFINED +1 STONE")
		return resource_inventory.add(kind, amount)
	elif kind == "equipment":
		if not payload is Dictionary:
			return false
		var item := payload as Dictionary
		if loot_filter.should_auto_salvage(item):
			equipment_inventory.scrap += EquipmentInventory.salvage_value(item)
			_refresh_equipment_ui()
			return true
		if not equipment_inventory.collect(item):
			return false
		hud.set_loot(item)
		return true
	elif kind == "island_shard":
		if not payload is Dictionary:
			return false
		var shard := payload as Dictionary
		if not _has_shard(String(shard.get("id", ""))):
			island_shards.append(shard.duplicate(true))
			_refresh_island_ui()
			return true
		return false
	return false

func _on_equipment_inventory_changed(_reason: String, _item_id: String) -> void:
	_refresh_equipment_ui()

func _on_equipment_changed(_slot: String, _previous_id: String, _current_id: String) -> void:
	_sync_player_equipment()
	_refresh_equipment_ui()

func _on_resource_inventory_changed(resource_id: String, amount: int, _delta: int) -> void:
	if resource_id == "wood":
		hud.set_wood(amount)
	elif resource_id == "stone":
		hud.set_stone(amount)
	elif resource_id == "moonleaf":
		hud.set_moonleaf(amount)
	elif resource_id == "smelting_charge":
		hud.set_smelting_charge(amount)
	_refresh_progression_ui()

func _on_mana_spend_failed(required: float, current: float) -> void:
	hud.set_encounter_feedback("NOT ENOUGH MANA — NEED %.0f, HAVE %.0f" % [required, current])

func _progression_resources() -> Dictionary:
	return {"wood": wood, "stone": stone, "moonleaf": moonleaf, "plank": plank}

func is_combat_unlocked() -> bool:
	return technology_tree.is_learned("combat_training")

func learn_technology(technology_id: String) -> bool:
	var combat_was_unlocked := is_combat_unlocked()
	var result: Dictionary = technology_tree.learn(technology_id, _progression_resources())
	if not bool(result.get("success", false)):
		hud.set_encounter_feedback("TECHNOLOGY NOT LEARNED — %s" % String(result.get("reason", "unavailable")).replace("_", " ").to_upper())
		_refresh_progression_ui()
		return false
	var after := result.resources_after as Dictionary
	wood = int(after.get("wood", wood))
	stone = int(after.get("stone", stone))
	moonleaf = int(after.get("moonleaf", moonleaf))
	plank = int(after.get("plank", plank))
	_apply_technology_effects()
	if not combat_was_unlocked and is_combat_unlocked():
		_sync_combat_phase(true)
	else:
		hud.set_encounter_feedback("TECHNOLOGY LEARNED — %s" % String((result.technology as Dictionary).get("name", technology_id)).to_upper())
	_refresh_equipment_ui()
	return true

func _apply_technology_effects() -> void:
	var maximum_mana := (80.0 if technology_tree.is_learned("mana_channeling") else 60.0) + (10.0 if bool(crafted_building_kits.get("mana_vessel", false)) else 0.0) + (20.0 if bool(crafted_building_kits.get("ley_capacitor", false)) else 0.0)
	var regeneration := (9.0 if technology_tree.is_learned("arcane_mastery") else 6.0) + (2.0 if technology_tree.is_learned("ley_resonance") else 0.0) + (2.0 if bool(crafted_building_kits.get("arcane_conduit", false)) else 0.0)
	player.mana_pool.regeneration_per_second = regeneration
	if not is_equal_approx(player.mana_pool.maximum, maximum_mana):
		player.mana_pool.set_maximum(maximum_mana, true)
	_sync_player_equipment()

func _authored_opening_enemies() -> Array[Node2D]:
	var result: Array[Node2D] = []
	for combatant: Node2D in [enemy, second_slime, ranged_enemy, elite_ranged_enemy]:
		if is_instance_valid(combatant):
			result.append(combatant)
	return result

func _sync_combat_phase(show_feedback: bool) -> void:
	var unlocked := is_combat_unlocked()
	var gameplay_active := unlocked and not hud.is_equipment_panel_open() and not hud.is_workbench_panel_open() and not hud.is_system_menu_open() and not hud.is_island_panel_open()
	for combatant: Node2D in _authored_opening_enemies():
		combatant.visible = unlocked
		combatant.set_physics_process(gameplay_active)
		if unlocked:
			combatant.add_to_group("attackable")
		else:
			combatant.remove_from_group("attackable")
		if show_feedback and unlocked:
			_spawn_gameplay_vfx(combatant.global_position, "rift")
	if show_feedback and unlocked:
		hud.set_encounter_feedback("COMBAT TRAINING COMPLETE — ISLAND THREATS AWAKENED")
	_refresh_progression_ui()

func _refresh_progression_ui() -> void:
	if not is_instance_valid(hud) or not is_instance_valid(player):
		return
	hud.set_mana(player.mana_pool.current, player.mana_pool.maximum)
	hud.refresh_inventory_stats({
		"wood": wood, "stone": stone, "moonleaf": moonleaf, "plank": plank, "scrap": equipment_inventory.scrap,
		"health": player.health, "maximum_health": player.maximum_health,
		"mana": player.mana_pool.current, "maximum_mana": player.mana_pool.maximum, "mana_regeneration": player.mana_pool.regeneration_per_second,
		"attack_damage": player.attack_damage, "attack_speed": player.attack_speed, "critical_chance": player.critical_chance,
		"gathering_power": player.gathering_power, "pickup_radius": player.pickup_radius, "production_speed": player.production_speed,
	})
	var phase_name := "combat awakened" if is_combat_unlocked() else "exploration phase"
	hud.refresh_technologies(technology_tree.all_definitions(), technology_tree.learned, phase_name, _progression_resources())
	hud.set_objective("EXPLORE • GATHER • LEARN\n[Y] INVENTORY + TECH   [A] USE   [X] HARVEST" if not is_combat_unlocked() else "BUILD • FIGHT • EXPAND\n[L] MOVE   [X] ATTACK   [A] USE   [Y] INVENTORY   [RB] ISLANDS")

func _on_player_moved(_position_value: Vector2) -> void:
	_refresh_interaction_target()

func _refresh_interaction_target() -> void:
	if is_instance_valid(current_interaction_target) and current_interaction_target.has_method("set_interaction_targeted"):
		current_interaction_target.set_interaction_targeted(false)
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
	if is_instance_valid(current_interaction_target) and current_interaction_target.has_method("set_interaction_targeted"):
		current_interaction_target.set_interaction_targeted(true)
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
	return equipped

func unequip_item(slot: String = "") -> bool:
	var target_slot := slot
	if target_slot.is_empty():
		var selected_index := hud.get_selected_equipment_index()
		if selected_index >= 0 and selected_index < equipment_inventory.items.size():
			var selected := equipment_inventory.items[selected_index]
			var selected_slot := String(selected.get("slot", "weapon"))
			if String(equipment_inventory.equipped_slots.get(selected_slot, "")) == String(selected.get("id", "")):
				target_slot = selected_slot
	if target_slot.is_empty():
		target_slot = "weapon"
	var unequipped := equipment_inventory.unequip(target_slot)
	return unequipped

func salvage_selected_item(index: int) -> int:
	return equipment_inventory.salvage(index)

func set_item_favorite(index: int, favorite: bool) -> bool:
	return equipment_inventory.set_favorite(index, favorite)

func _refresh_equipment_ui() -> void:
	hud.refresh_equipment(equipment_inventory.items, equipment_inventory.equipped_item("weapon"), equipment_inventory.scrap, player.attack_damage, player.attack_speed, equipment_inventory.equipped_slots)
	_refresh_progression_ui()
	_refresh_workbench_ui()

func _sync_player_equipment() -> void:
	var living_was_active := legendary_manager.is_active("living_arrows")
	var equipped := equipment_inventory.equipped_item("weapon")
	var weapon_instance_id := String(equipped.get("id", ""))
	if weapon_instance_id != _active_weapon_instance_id:
		_clear_player_weapon_effects()
		_active_weapon_instance_id = weapon_instance_id
	var upgrade_bonus := (CraftingService.WHETSTONE_ATTACK_BONUS if runed_whetstone_crafted else 0) + (1 if bool(crafted_building_kits.get("duelist_grip", false)) else 0)
	var base_stats := StatBlock.default_base_stats()
	base_stats.max_health = 10.0 + (2.0 if reinforced_heart_crafted else 0.0)
	base_stats.pickup_radius = float(base_stats.pickup_radius) + (CraftingService.HERBAL_COMPASS_PICKUP_RADIUS_BONUS if herbal_compass_crafted else 0.0)
	if technology_tree.is_learned("ranger_instinct"):
		base_stats.critical_chance = float(base_stats.critical_chance) + 0.05
	if technology_tree.is_learned("weapon_mastery"):
		base_stats.critical_damage = float(base_stats.critical_damage) + 0.25
	if bool(crafted_building_kits.get("ranger_fletching", false)):
		base_stats.critical_chance = float(base_stats.critical_chance) + 0.03
	if bool(crafted_building_kits.get("precision_quiver", false)):
		base_stats.attack_speed = float(base_stats.attack_speed) + 0.08
	if bool(crafted_building_kits.get("shard_prism", false)):
		base_stats.critical_chance = float(base_stats.critical_chance) + 0.05
	if technology_tree.is_learned("efficient_harvest"):
		base_stats.gathering_power = float(base_stats.gathering_power) + 0.5
	if technology_tree.is_learned("master_foraging"):
		base_stats.gathering_power = float(base_stats.gathering_power) + 0.25
	if bool(crafted_building_kits.get("harvest_charm", false)):
		base_stats.gathering_power = float(base_stats.gathering_power) + 0.25
	if bool(crafted_building_kits.get("foresters_toolkit", false)):
		base_stats.gathering_power = float(base_stats.gathering_power) + 0.35
	if bool(crafted_building_kits.get("reinforced_axe", false)):
		base_stats.gathering_power = float(base_stats.gathering_power) + 0.4
	if bool(crafted_building_kits.get("wayfinder_boots", false)):
		base_stats.movement_speed = float(base_stats.movement_speed) + 15.0
	if bool(crafted_building_kits.get("surveyors_lens", false)):
		base_stats.pickup_radius = float(base_stats.pickup_radius) + 30.0
	if technology_tree.is_learned("shard_attunement"):
		base_stats.pickup_radius = float(base_stats.pickup_radius) + 20.0
	if technology_tree.is_learned("island_industry"):
		base_stats.production_speed = float(base_stats.production_speed) + 0.1
	if bool(crafted_building_kits.get("precision_gearbox", false)):
		base_stats.production_speed = float(base_stats.production_speed) + 0.2
	var derived := equipment_inventory.derived_stats(base_stats)
	var desired_maximum := maxi(1, roundi(float(derived.max_health)))
	if player.maximum_health != desired_maximum:
		player.health_component.set_maximum(desired_maximum, true)
	player.set_derived_stats(derived)
	var damage_base := equipment_inventory.attack_damage() + upgrade_bonus + int(installed_shard.get("player_attack_bonus", 0))
	var damage := maxi(1, roundi(float(damage_base) * float(derived.damage_multiplier)))
	var base_type := String(equipped.get("base_type", equipped.get("archetype", "unarmed")))
	var canonical_type := "bow" if base_type == "ranged" else ("wand" if base_type == "magic" else ("sword" if base_type == "melee" else base_type))
	var profile := equipped.get("attack_profile", {}) as Dictionary
	if profile.is_empty() and base_type in ["sword", "bow", "wand"]:
		profile = ItemBaseRegistry.get_definition(base_type).get("attack_profile", {}) as Dictionary
	var effect_ids: Array[String] = []
	for item: Dictionary in equipment_inventory.equipped_items():
		for effect_value: Variant in item.get("legendary_effects", []):
			if String(effect_value) not in effect_ids:
				effect_ids.append(String(effect_value))
		var legacy_effect := String(item.get("legendary_affix_id", ""))
		if not legacy_effect.is_empty() and legacy_effect not in effect_ids:
			effect_ids.append(legacy_effect)
	legendary_manager.sync(effect_ids)
	if living_was_active and not legendary_manager.is_active("living_arrows"):
		_clear_living_arrow_plants()
	player.set_weapon_stats(damage, equipment_inventory.attack_speed() * float(derived.attack_speed), base_type, String(equipped.get("legendary_affix_id", "")), profile, effect_ids)

func _clear_living_arrow_plants() -> void:
	for plant_value: Node in get_tree().get_nodes_in_group("temporary_legendary"):
		if plant_value is LivingArrowPlant and is_ancestor_of(plant_value):
			(plant_value as LivingArrowPlant).cleanup()

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
	if recipe_id in ["lumber_mill_kit", "collector_kit"]:
		craft_building_kit(recipe_id)
	elif recipe_id == CraftingService.WHETSTONE_RECIPE_ID:
		craft_runed_whetstone()
	elif recipe_id == CraftingService.HERBAL_COMPASS_RECIPE_ID:
		craft_herbal_compass()
	elif recipe_id == CraftingService.RECIPE_ID:
		craft_reinforced_heart()
	else:
		craft_progression_upgrade(recipe_id)

func craft_progression_upgrade(recipe_id: String) -> bool:
	var result := crafting_service.evaluate(recipe_id, _crafting_resources(), _technology_unlocks(), _crafted_recipe_state())
	if not bool(result.get("success", false)):
		_refresh_workbench_ui(_crafting_failure_text(result))
		return false
	_apply_crafting_resources(result.resources_after as Dictionary)
	crafted_building_kits[recipe_id] = true
	_apply_technology_effects()
	refresh_all_ui("CRAFTED — %s" % String((result.recipe as Dictionary).get("effect_text", recipe_id)).to_upper())
	return true

func _technology_unlocks() -> Dictionary:
	var unlocks := {"reinforced_heart": reinforced_heart_crafted, "forest_island": _has_forest_island()}
	for technology_id: String in technology_tree.learned:
		unlocks[technology_id] = true
	return unlocks

func craft_reinforced_heart() -> bool:
	var result := crafting_service.evaluate(CraftingService.RECIPE_ID, _crafting_resources(), {"reinforced_heart": reinforced_heart_crafted, "forest_island": _has_forest_island()}, _crafted_recipe_state())
	if not bool(result.get("success", false)):
		_refresh_workbench_ui(_crafting_failure_text(result))
		return false
	_apply_crafting_resources(result.resources_after as Dictionary)
	reinforced_heart_crafted = true
	player.add_maximum_health(CraftingService.MAXIMUM_HEALTH_BONUS)
	refresh_all_ui("CRAFTED — MAX HEALTH +2")
	hud.focus_tidecatcher_build()
	return true

func craft_runed_whetstone() -> bool:
	var result := crafting_service.evaluate(CraftingService.WHETSTONE_RECIPE_ID, _crafting_resources(), {"reinforced_heart": reinforced_heart_crafted, "forest_island": _has_forest_island()}, _crafted_recipe_state())
	if not bool(result.get("success", false)):
		_refresh_workbench_ui(_crafting_failure_text(result))
		return false
	_apply_crafting_resources(result.resources_after as Dictionary)
	runed_whetstone_crafted = true
	_sync_player_equipment()
	refresh_all_ui("CRAFTED — BASE ATTACK +1")
	return true

func craft_herbal_compass() -> bool:
	var result := crafting_service.evaluate(CraftingService.HERBAL_COMPASS_RECIPE_ID, _crafting_resources(), {"reinforced_heart": reinforced_heart_crafted, "forest_island": _has_forest_island()}, _crafted_recipe_state())
	if not bool(result.get("success", false)):
		_refresh_workbench_ui(_crafting_failure_text(result))
		return false
	_apply_crafting_resources(result.resources_after as Dictionary)
	herbal_compass_crafted = true
	_sync_player_equipment()
	refresh_all_ui("CRAFTED — PICKUP RADIUS +40")
	return true

func craft_building_kit(recipe_id: String) -> bool:
	var resources := _crafting_resources()
	var result := crafting_service.evaluate(recipe_id, resources, {"reinforced_heart": reinforced_heart_crafted, "forest_island": _has_forest_island()}, _crafted_recipe_state())
	if not bool(result.get("success", false)):
		_refresh_workbench_ui(_crafting_failure_text(result))
		return false
	_apply_crafting_resources(result.resources_after as Dictionary)
	crafted_building_kits[recipe_id] = true
	refresh_all_ui("CRAFTED — READY TO PLACE")
	return begin_building_placement(recipe_id.trim_suffix("_kit"))

func begin_building_placement(building_id: String, socket_id: String = "west") -> bool:
	var kit_id := "%s_kit" % building_id
	if not bool(crafted_building_kits.get(kit_id, false)) or not base_placement.begin_preview(building_id, socket_id):
		return false
	_placement_socket_index = PLACEMENT_SOCKET_IDS.find(socket_id)
	if is_instance_valid(_placement_visual):
		_placement_visual.queue_free()
	_placement_visual = BaseBuildingVisual.new()
	base_buildings.add_child(_placement_visual)
	_refresh_placement_preview()
	player.input_enabled = false
	_set_combat_processing(false)
	return true

func cycle_placement_socket(offset: int) -> bool:
	if base_placement.preview.is_empty():
		return false
	_placement_socket_index = posmod(_placement_socket_index + offset, PLACEMENT_SOCKET_IDS.size())
	base_placement.select_socket(PLACEMENT_SOCKET_IDS[_placement_socket_index])
	_refresh_placement_preview()
	return true

func rotate_building_preview() -> int:
	var result := base_placement.rotate_preview()
	_refresh_placement_preview()
	return result

func confirm_building_placement() -> bool:
	if base_placement.preview.is_empty():
		return false
	var kit_id := "%s_kit" % String(base_placement.preview.building_id)
	var result := base_placement.commit(_player_placement_cell())
	if not bool(result.get("valid", false)):
		_refresh_placement_preview()
		return false
	crafted_building_kits[kit_id] = false
	if is_instance_valid(_placement_visual):
		_placement_visual.queue_free()
	_placement_visual = null
	hud.close_placement()
	_materialize_base_buildings()
	_refresh_base_ui("%s ONLINE" % String((result.building as Dictionary).building_id).replace("_", " ").to_upper())
	_restore_gameplay_if_no_modal()
	return true

func cancel_building_placement() -> void:
	base_placement.cancel_preview()
	if is_instance_valid(_placement_visual):
		_placement_visual.queue_free()
	_placement_visual = null
	hud.close_placement()
	_restore_gameplay_if_no_modal()

func _refresh_placement_preview() -> void:
	if base_placement.preview.is_empty() or not is_instance_valid(_placement_visual):
		return
	var validation := base_placement.validate_preview(_player_placement_cell())
	var socket_id := String(base_placement.preview.socket_id)
	_placement_visual.position = PLACEMENT_WORLD_POSITIONS[socket_id] as Vector2
	_placement_visual.configure(String(base_placement.preview.building_id), true, bool(validation.valid), int(base_placement.preview.rotation))
	hud.show_placement(String(base_placement.preview.building_id).replace("_", " "), socket_id, int(base_placement.preview.rotation), bool(validation.valid), String(validation.reason))

func _player_placement_cell() -> Vector2i:
	for socket_id: String in PLACEMENT_SOCKET_IDS:
		if player.global_position.distance_to(PLACEMENT_WORLD_POSITIONS[socket_id] as Vector2) <= 62.0:
			return BasePlacementModel.SOCKETS[socket_id] as Vector2i
	return Vector2i(999, 999)

func _materialize_base_buildings() -> void:
	for node_value: Variant in _building_nodes.values():
		if is_instance_valid(node_value):
			(node_value as Node).queue_free()
	_building_nodes.clear()
	for socket_id: String in base_placement.buildings:
		var state := base_placement.buildings[socket_id] as Dictionary
		var visual := BaseBuildingVisual.new()
		visual.position = PLACEMENT_WORLD_POSITIONS[socket_id] as Vector2
		visual.configure(String(state.building_id), false, true, int(state.rotation))
		base_buildings.add_child(visual)
		_building_nodes[socket_id] = visual

func has_base_building(building_id: String) -> bool:
	for state_value: Variant in base_placement.buildings.values():
		if String((state_value as Dictionary).get("building_id", "")) == building_id:
			return true
	return false

func deposit_base_resource(resource_id: String, amount: int) -> int:
	var available: int = resource_inventory.amount(resource_id)
	var requested: int = mini(maxi(0, amount), available)
	var result: Dictionary = shared_storage.add(resource_id, requested)
	var accepted: int = int(result.accepted)
	if accepted > 0:
		resource_inventory.remove(resource_id, accepted)
	_refresh_base_ui("DEPOSITED %d %s" % [accepted, resource_id.to_upper()] if accepted > 0 else "STORAGE FULL — NOTHING LOST")
	refresh_all_ui()
	return accepted

func withdraw_base_resource(resource_id: String, amount: int) -> int:
	var transferred: int = shared_storage.remove(resource_id, amount)
	if transferred > 0:
		resource_inventory.add(resource_id, transferred)
	refresh_all_ui()
	return transferred

func advance_base_automation(delta_seconds: float) -> Dictionary:
	if has_base_building("collector"):
		collector_simulation.flush_to(shared_storage)
	var result := {"elapsed": 0.0, "cycles": 0, "planks_routed": 0, "blocked": false}
	if has_base_building("lumber_mill"):
		result = OfflineAutomation.simulate_mill(lumber_mill_simulation, shared_storage, effective_automation_elapsed(delta_seconds))
	_refresh_base_ui()
	return result

func effective_automation_elapsed(delta_seconds: float) -> float:
	return maxf(0.0, delta_seconds) * maxf(0.1, player.production_speed)

func collect_automation_batch() -> Dictionary:
	if not has_base_building("collector"):
		return {"collected_ids": [], "amount": 0}
	var collector_position: Vector2 = _building_position("collector")
	var candidates: Array[Dictionary] = []
	var nodes_by_id: Dictionary = {}
	for node: Node in get_tree().get_nodes_in_group("world_pickups"):
		if not node is WorldPickup:
			continue
		var pickup := node as WorldPickup
		if not pickup.payload is int:
			continue
		var stable_id := str(pickup.get_instance_id())
		candidates.append({"id": stable_id, "resource_id": pickup.kind, "amount": int(pickup.payload), "position": pickup.global_position, "rarity": pickup.rarity, "owner": pickup.owner_id, "encounter_reward": pickup.encounter_reward or pickup.important})
		nodes_by_id[stable_id] = pickup
	var result: Dictionary = collector_simulation.collect_batch(candidates, collector_position)
	for id_value: Variant in result.collected_ids:
		var pickup: Node = nodes_by_id.get(String(id_value))
		if is_instance_valid(pickup):
			pickup.queue_free()
	return result

func _building_position(building_id: String) -> Vector2:
	for socket_id: String in base_placement.buildings:
		if String((base_placement.buildings[socket_id] as Dictionary).building_id) == building_id:
			return PLACEMENT_WORLD_POSITIONS[socket_id] as Vector2
	return Vector2.ZERO

func _on_automation_tick() -> void:
	collect_automation_batch()
	advance_base_automation(0.5)

func simulate_offline(current_unix: int) -> Dictionary:
	var elapsed: float = OfflineAutomation.safe_elapsed(last_simulation_unix, current_unix)
	var result: Dictionary = advance_base_automation(elapsed)
	last_simulation_unix = maxi(last_simulation_unix, current_unix)
	return result

func upgrade_equipped_item(confirmed: bool = false) -> bool:
	var equipped: Dictionary = equipment_inventory.equipped_item("weapon")
	if equipped.is_empty():
		_refresh_upgrade_ui("EQUIP AN ITEM FIRST")
		return false
	var resources: Dictionary = {"scrap": equipment_inventory.scrap, "moonleaf": moonleaf}
	var result: Dictionary = ItemUpgradeService.apply(equipped, resources, confirmed)
	if not bool(result.get("success", false)):
		_refresh_upgrade_ui("CONFIRMATION REQUIRED" if String(result.reason) == "confirmation_required" else "UPGRADE BLOCKED — %s" % String(result.reason).replace("_", " ").to_upper())
		return false
	var item_id := String(equipped.id)
	for index: int in equipment_inventory.items.size():
		if String(equipment_inventory.items[index].get("id", "")) == item_id:
			equipment_inventory.items[index] = (result.item as Dictionary).duplicate(true)
			break
	equipment_inventory.scrap = int(result.resources.scrap)
	moonleaf = int(result.resources.moonleaf)
	_sync_player_equipment()
	refresh_all_ui("UPGRADED %s TO +%d" % [String(result.item.get("name", "ITEM")).to_upper(), int(result.item.upgrade_level)])
	return true

func _refresh_upgrade_ui(feedback: String = "") -> void:
	hud.refresh_upgrade_preview(equipment_inventory.equipped_item("weapon"), equipment_inventory.scrap, moonleaf, feedback)

func _crafting_resources() -> Dictionary:
	return {"wood": wood, "stone": stone, "moonleaf": moonleaf, "scrap": equipment_inventory.scrap, "plank": plank}

func _apply_crafting_resources(resources: Dictionary) -> void:
	wood = int(resources.get("wood", wood))
	stone = int(resources.get("stone", stone))
	moonleaf = int(resources.get("moonleaf", moonleaf))
	plank = int(resources.get("plank", plank))
	equipment_inventory.scrap = int(resources.get("scrap", equipment_inventory.scrap))

func _crafted_recipe_state() -> Dictionary:
	var result := {"reinforced_heart": reinforced_heart_crafted, "runed_whetstone": runed_whetstone_crafted, "herbal_compass": herbal_compass_crafted, "lumber_mill_kit": bool(crafted_building_kits.get("lumber_mill_kit", false)) or has_base_building("lumber_mill"), "collector_kit": bool(crafted_building_kits.get("collector_kit", false)) or has_base_building("collector"), "lumber_mill_built": has_base_building("lumber_mill"), "collector_built": has_base_building("collector"), "stored_planks": shared_storage.amount("plank")}
	result.merge(crafted_building_kits, true)
	return result

func _crafting_failure_text(result: Dictionary) -> String:
	var reason := String(result.get("reason", "invalid"))
	if reason == "insufficient_resources":
		var parts: Array[String] = []
		for id_value: Variant in (result.get("missing", {}) as Dictionary):
			parts.append("%d %s" % [int(result.missing[id_value]), String(id_value).to_upper()])
		return "MISSING %s" % ", ".join(parts)
	return reason.replace("_", " ").to_upper()

func _has_forest_island() -> bool:
	for slot_id: String in archipelago.slot_ids():
		var installed: Dictionary = (archipelago.slot(slot_id) as Dictionary).get("installed_island", {}) as Dictionary
		if not installed.is_empty() and String((installed.definition as Dictionary).get("biome", "")) == "Forest":
			return true
	return false

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
	hud.set_mana(player.mana_pool.current, player.mana_pool.maximum)
	hud.set_wood(wood)
	hud.set_stone(stone)
	hud.set_moonleaf(moonleaf)
	hud.set_plank(plank)
	_refresh_equipment_ui()
	_refresh_workbench_ui(crafting_feedback)
	_refresh_upgrade_ui()
	_refresh_base_ui()
	_refresh_island_ui()

func _refresh_workbench_ui(feedback: String = "") -> void:
	hud.refresh_workbench(wood, stone, moonleaf, equipment_inventory.scrap, reinforced_heart_crafted, runed_whetstone_crafted, herbal_compass_crafted, tidecatcher_built, feedback, plank, _crafted_recipe_state(), _has_forest_island(), _technology_unlocks())

func _refresh_base_ui(feedback: String = "") -> void:
	var active := not base_placement.buildings.is_empty()
	var mill_state := "MILL —"
	if has_base_building("lumber_mill"):
		mill_state = "MILL %dW → %dP  %d%%%s" % [lumber_mill_simulation.input_wood, lumber_mill_simulation.output_planks, roundi(lumber_mill_simulation.progress_ratio() * 100.0), " BLOCKED" if lumber_mill_simulation.blocked_output else ""]
	var collector_state := "COLLECTOR %d/%d" % [collector_simulation.total_stored(), CollectorSimulation.STORAGE_CAPACITY] if has_base_building("collector") else "COLLECTOR —"
	var flow := "%s\n%s  →  STORAGE %d/%d  →  %s" % [feedback, collector_state, shared_storage.total(), shared_storage.capacity, mill_state] if not feedback.is_empty() else "%s  →  STORAGE %d/%d  →  %s" % [collector_state, shared_storage.total(), shared_storage.capacity, mill_state]
	hud.set_base_status(active or not feedback.is_empty(), flow)

func _restore_gameplay_if_no_modal() -> void:
	if hud.is_equipment_panel_open() or hud.is_workbench_panel_open() or hud.is_system_menu_open() or hud.is_island_panel_open() or hud.is_placement_panel_open():
		return
	player.input_enabled = true
	_set_combat_processing(true)
	_refresh_interaction_target()
	hud.set_encounter_feedback(hud.get_encounter_feedback())
	hud.set_rift_feedback(hud.get_rift_feedback())
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
			"mana": player.mana_pool.current,
			"maximum_mana": player.mana_pool.maximum,
			"mana_regeneration": player.mana_pool.regeneration_per_second,
			"position": {"x": player.global_position.x, "y": player.global_position.y},
		},
		"wood": wood,
		"stone": stone,
		"moonleaf": moonleaf,
		"plank": plank,
		"equipment": {
			"scrap": equipment_inventory.scrap,
			"equipped_id": equipment_inventory.equipped_id,
			"equipped_slots": equipment_inventory.equipped_slots.duplicate(true),
			"items": saved_items,
		},
		"reinforced_heart_crafted": reinforced_heart_crafted,
		"runed_whetstone_crafted": runed_whetstone_crafted,
		"herbal_compass_crafted": herbal_compass_crafted,
		"tidecatcher": {"built": tidecatcher_built, "stored_wood": tidecatcher.stored_wood()},
		"islands": {"inventory": saved_shards, "installed": installed_shard.duplicate(true), "archipelago": archipelago.to_dictionary()},
		"base": {"placement": base_placement.to_dictionary(), "storage": shared_storage.to_dictionary(), "lumber_mill": lumber_mill_simulation.to_dictionary(), "collector": collector_simulation.to_dictionary(), "crafted_kits": crafted_building_kits.duplicate(true), "saved_unix": int(Time.get_unix_time_from_system())},
		"technologies": {"learned": technology_tree.learned.duplicate()},
	}

func _apply_state(state: Dictionary) -> void:
	var player_state := state.player as Dictionary
	var position_state := player_state.position as Dictionary
	var equipment_state := state.equipment as Dictionary
	var tidecatcher_state := state.tidecatcher as Dictionary
	var islands_state := state.islands as Dictionary
	var base_state := state.base as Dictionary
	var technology_state := state.technologies as Dictionary
	player.maximum_health = int(player_state.maximum_health)
	player.health = clampi(int(player_state.health), 0, player.maximum_health)
	player.global_position = Vector2(float(position_state.x), float(position_state.y))
	wood = maxi(0, int(state.wood))
	stone = maxi(0, int(state.stone))
	moonleaf = maxi(0, int(state.moonleaf))
	plank = maxi(0, int(state.plank))
	equipment_inventory.items.clear()
	for item_value: Variant in equipment_state.items:
		equipment_inventory.items.append((item_value as Dictionary).duplicate(true))
	equipment_inventory.scrap = maxi(0, int(equipment_state.scrap))
	var saved_slots := equipment_state.get("equipped_slots", {}) as Dictionary
	if not equipment_inventory.restore_slots(saved_slots):
		equipment_inventory.equipped_slots.clear()
	reinforced_heart_crafted = bool(state.reinforced_heart_crafted)
	runed_whetstone_crafted = bool(state.runed_whetstone_crafted)
	herbal_compass_crafted = bool(state.herbal_compass_crafted)
	technology_tree.restore(technology_state.learned as Array)
	_apply_technology_effects()
	player.mana_pool.restore(float(player_state.mana), float(player_state.maximum_mana), float(player_state.mana_regeneration))
	_sync_player_equipment()
	tidecatcher_built = bool(tidecatcher_state.built)
	tidecatcher.restore_state(tidecatcher_built, int(tidecatcher_state.stored_wood), player)
	island_shards.clear()
	for shard_value: Variant in islands_state.inventory:
		island_shards.append((shard_value as Dictionary).duplicate(true))
	var restored_archipelago := ArchipelagoModel.from_dictionary(islands_state.archipelago as Dictionary)
	if restored_archipelago != null:
		archipelago = restored_archipelago
	var restored_placement := BasePlacementModel.from_dictionary(base_state.placement as Dictionary)
	var restored_storage := SharedStorage.from_dictionary(base_state.storage as Dictionary)
	if restored_placement != null:
		base_placement = restored_placement
	if restored_storage != null:
		shared_storage = restored_storage
	lumber_mill_simulation.restore(base_state.lumber_mill as Dictionary)
	collector_simulation.restore(base_state.collector as Dictionary)
	crafted_building_kits = (base_state.crafted_kits as Dictionary).duplicate(true)
	_apply_technology_effects()
	last_simulation_unix = int(base_state.saved_unix)
	simulate_offline(int(Time.get_unix_time_from_system()))
	_sync_archipelago_compatibility()
	_rebuild_materialized_islands()
	_materialize_base_buildings()
	_apply_island_modifiers()
	_sync_combat_phase(false)
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

func install_selected_shard(index: int, slot_id: String = "east") -> bool:
	if index < 0 or index >= island_shards.size() or not island_slots.has(slot_id):
		return false
	var shard := island_shards[index].duplicate(true)
	if not IslandShardDefinition.validate_dictionary(shard).is_empty():
		return false
	var target_slot := island_slots[slot_id] as IslandSlot
	var prior := (archipelago.slot(slot_id).installed_island as Dictionary).duplicate(true)
	if not prior.is_empty() and target_slot.contains_world_position(player.global_position):
		return false
	var runtime := IslandRuntimeState.create(shard)
	var installed_candidate := {"definition": shard, "runtime": IslandRuntimeState.progress_only(runtime)}
	var bundle := _modifier_bundle(shard, slot_id, true)
	if not target_slot.materialize(installed_candidate, bundle.effects, bundle.indicators, player):
		return false
	if not archipelago.install(slot_id, shard, runtime):
		target_slot.clear_materialized()
		if not prior.is_empty():
			_materialize_slot(slot_id)
		return false
	island_shards.remove_at(index)
	if not prior.is_empty():
		island_shards.append((prior.definition as Dictionary).duplicate(true))
	_sync_archipelago_compatibility()
	_rebuild_materialized_islands()
	var materialization := IslandMaterializationVfx.new()
	materialization.global_position = target_slot.global_position
	add_child(materialization)
	logger.debug(GameLoggerScript.WORLD, "island shard installed", {"id": String(shard.get("id", "")), "seed": int(shard.get("seed", 0)), "slot": slot_id})
	_apply_island_modifiers()
	_refresh_equipment_ui()
	_refresh_island_ui()
	return true

func remove_installed_shard(slot_id: String = "east") -> bool:
	if not island_slots.has(slot_id):
		return false
	var target_slot := island_slots[slot_id] as IslandSlot
	if target_slot.contains_world_position(player.global_position):
		return false
	var removed := archipelago.remove(slot_id)
	if removed.is_empty():
		return false
	island_shards.append((removed.definition as Dictionary).duplicate(true))
	target_slot.clear_materialized()
	_sync_archipelago_compatibility()
	_rebuild_materialized_islands()
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

func _sync_archipelago_compatibility() -> void:
	var east := archipelago.slot("east")
	var east_installed := east.get("installed_island", {}) as Dictionary
	installed_shard = {} if east_installed.is_empty() else (east_installed.definition as Dictionary).duplicate(true)

func _rebuild_materialized_islands() -> void:
	for slot_id: String in island_slots:
		(island_slots[slot_id] as IslandSlot).clear_materialized()
	for slot_id: String in archipelago.slot_ids():
		_materialize_slot(slot_id)
	if hud != null and (hud.is_island_panel_open() or hud.is_equipment_panel_open() or hud.is_workbench_panel_open() or hud.is_system_menu_open()):
		_set_combat_processing(false)

func _materialize_slot(slot_id: String) -> bool:
	var slot_data := archipelago.slot(slot_id)
	var installed := slot_data.get("installed_island", {}) as Dictionary
	if installed.is_empty() or not island_slots.has(slot_id):
		return false
	var definition := installed.definition as Dictionary
	var bundle := _modifier_bundle(definition, slot_id, false)
	var target_slot := island_slots[slot_id] as IslandSlot
	if not target_slot.materialize(installed, bundle.effects, bundle.indicators, player):
		return false
	var materialized := target_slot.materialized
	materialized.resource_depleted.connect(_on_island_resource_depleted)
	materialized.encounter_completed.connect(_on_island_encounter_completed)
	materialized.modifier_triggered.connect(_on_island_modifier_triggered)
	materialized.enemy_volley_requested.connect(_on_enemy_volley_requested)
	materialized.enemy_defeated.connect(_on_island_enemy_defeated)
	return true

func _modifier_bundle(definition: Dictionary, slot_id: String, preview_candidate: bool) -> Dictionary:
	var ids: Array[String] = []
	for value: Variant in (definition.positive_modifiers as Array) + (definition.negative_modifiers as Array):
		ids.append(String(value))
	var manager := IslandModifierManager.new()
	manager.sync(ids, {"level": int(definition.level), "biome": String(definition.biome), "neighbor_count": archipelago.neighbor_ids(slot_id).size()})
	var effects := manager.effects()
	var synergies := archipelago.preview_synergies(definition, slot_id) if preview_candidate else archipelago.active_synergies()
	for synergy: Dictionary in synergies:
		if preview_candidate or slot_id in (synergy.get("slots", []) as Array):
			for key: String in (synergy.effects as Dictionary):
				effects[key] = synergy.effects[key]
	for neighbor_id: String in archipelago.neighbor_ids(slot_id):
		var neighbor := archipelago.slot(neighbor_id).installed_island as Dictionary
		if not neighbor.is_empty() and "overgrown" in (neighbor.definition.positive_modifiers as Array):
			effects["resource_density_multiplier"] = maxf(float(effects.get("resource_density_multiplier", 1.0)), 1.25)
	return {"effects": effects, "indicators": manager.indicators()}

func _on_island_resource_depleted(slot_id: String, instance_id: String, position_value: Vector2, resource_id: String, amount: int) -> void:
	var runtime := archipelago.slots[slot_id].installed_island.runtime as Dictionary
	if instance_id not in (runtime.destroyed_resources as Array):
		(runtime.destroyed_resources as Array).append(instance_id)
	legendary_event_bus.emit_resource_destroyed({"position": position_value, "resource_id": resource_id, "amount": amount, "island_slot": slot_id})
	_spawn_gameplay_vfx(position_value, "resource_break")
	_spawn_pickup(position_value, resource_id, amount)

func _on_island_enemy_defeated(enemy_id: String, position_value: Vector2) -> void:
	var nearby_ores: Array[Dictionary] = []
	for candidate: Node in get_tree().get_nodes_in_group("attackable"):
		if candidate is ResourceNode and (candidate as ResourceNode).resource_id == "stone" and not candidate.is_queued_for_deletion():
			var distance := position_value.distance_to((candidate as Node2D).global_position)
			if distance <= 220.0:
				nearby_ores.append({"id": str(candidate.get_instance_id()), "distance": distance})
	legendary_event_bus.emit_enemy_killed({"enemy_id": enemy_id, "burning": bool(_burning_targets.get(enemy_id, false)), "nearby_ores": nearby_ores, "position": position_value})
	_burning_targets.erase(enemy_id)

func _on_island_encounter_completed(slot_id: String, event_id: String, position_value: Vector2) -> void:
	var installed := archipelago.slots[slot_id].installed_island as Dictionary
	var runtime := installed.runtime as Dictionary
	if event_id in (runtime.collected_rewards as Array):
		return
	(runtime.collected_rewards as Array).append(event_id)
	runtime.encounter_completed = true
	var bundle := _modifier_bundle(installed.definition as Dictionary, slot_id, false)
	var reward_amount := 2 if float(bundle.effects.get("night_reward_multiplier", 1.0)) <= 1.0 else 3
	var encounter_pickup := _spawn_pickup(position_value + Vector2(76.0, 0.0), "moonleaf", reward_amount)
	encounter_pickup.encounter_reward = true
	encounter_pickup.rarity = "rare"
	encounter_pickup.important = true
	encounter_pickup.queue_redraw()
	if float(bundle.effects.get("magical_loot_weight", 1.0)) > 1.0:
		_spawn_pickup(position_value + Vector2(24, 0), "equipment", LootGenerator.generate(int(installed.definition.seed) ^ 44551, "island_event", int(installed.definition.level), "", "magic"))
	hud.set_encounter_feedback("%s COMPLETE — MOONLEAF REWARD" % String(installed.definition.encounter).to_upper())

func _on_island_modifier_triggered(_slot_id: String, modifier_id: String, position_value: Vector2) -> void:
	var visual := LegendaryEffectVisual.new()
	visual.effect_id = modifier_id
	visual.global_position = position_value
	add_child(visual)
	hud.set_encounter_feedback("VOLATILE ORE — AREA BLAST")

func _refresh_island_ui() -> void:
	hud.refresh_islands(island_shards, archipelago.to_dictionary())

func _has_shard(shard_id: String) -> bool:
	for shard: Dictionary in island_shards:
		if String(shard.get("id", "")) == shard_id:
			return true
	return false

func _set_combat_processing(enabled: bool) -> void:
	for combatant: Node in get_tree().get_nodes_in_group("attackable"):
		if combatant is ChaserEnemy or combatant is RangedEnemy or combatant is AbyssalWarden:
			combatant.set_physics_process(enabled)
	for descendant: Node in find_children("*", "", true, false):
		if descendant is EnemyProjectile:
			descendant.set_process(enabled)

func handle_rift_action() -> void:
	if rift_controller.status == RiftRunController.Status.ACTIVE:
		_fail_rift("RIFT FAILED — RETREATED")
	elif rift_controller.status in [RiftRunController.Status.COMPLETE, RiftRunController.Status.FAILED]:
		rift_controller.exit()
		_rift_spawn_delay_remaining = 0.0
		hud.set_rift_feedback("RIFT READY — APPROACH PORTAL FOR RUN %d" % (rift_controller.run_index + 1))
	else:
		try_enter_rift()

func try_enter_rift() -> bool:
	if not rift_portal.is_player_in_range(player.global_position):
		return false
	if not rift_controller.start():
		return false
	_rift_spawn_delay_remaining = 0.0
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
	_rift_spawn_delay_remaining = 0.0
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
	_emit_enemy_killed(combatant, combatant.global_position)
	_spawn_gameplay_vfx(combatant.global_position, "death")
	rift_enemies.erase(combatant)
	if not rift_enemies.is_empty() or rift_controller.status != RiftRunController.Status.ACTIVE:
		return
	if rift_controller.next_wave():
		_rift_spawn_delay_remaining = RiftRules.WAVE_RESPITE_SECONDS
		hud.set_rift_feedback("RIFT RUN %d — RESPITE %.1fs — WAVE %d INCOMING" % [rift_controller.run_index, RiftRules.WAVE_RESPITE_SECONDS, rift_controller.wave_index])
	else:
		_rift_spawn_delay_remaining = 0.0
		rift_controller.complete()
		_spawn_pickup(rift_portal.global_position, "equipment", RiftRules.reward(rift_controller.run_index))
		hud.set_rift_feedback("RIFT COMPLETE — CACHE DROPPED — PRESS LB / K TO EXIT")

func _on_player_defeated() -> void:
	if rift_controller.status == RiftRunController.Status.ACTIVE:
		_fail_rift("RIFT FAILED — SAFE RECOVERY")

func _fail_rift(message: String) -> void:
	_rift_spawn_delay_remaining = 0.0
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

func advance_rift_spawn(delta: float) -> void:
	if delta <= 0.0 or _rift_spawn_delay_remaining <= 0.0:
		return
	if rift_controller.status != RiftRunController.Status.ACTIVE or not rift_enemies.is_empty():
		_rift_spawn_delay_remaining = 0.0
		return
	_rift_spawn_delay_remaining = maxf(0.0, _rift_spawn_delay_remaining - delta)
	if _rift_spawn_delay_remaining <= 0.0:
		_spawn_rift_wave()

func rift_spawn_delay_remaining() -> float:
	return _rift_spawn_delay_remaining

func run_scripted_smoke() -> Dictionary:
	_set_combat_processing(false)
	_resolve_player_projectiles_immediately = true
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
	for cache_id: String in ["firefly_east", "firefly_south_east"]:
		var cache := living_world_prop(cache_id)
		movement_steps += _scripted_move_to(cache.global_position)
		cache.interact(player)
		var cache_wood := _find_pickup("wood")
		var cache_stone := _find_pickup("stone")
		cache_wood.collect_immediately()
		cache_stone.collect_immediately()
	var gathered_wood := wood
	var gathered_stone := stone
	learn_technology("fieldcraft")
	learn_technology("combat_training")
	_set_combat_processing(false)
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
	var metrics := {
		"seed": EQUIPMENT_SEED,
		"wood": wood,
		"stone": stone,
		"gathered_wood": gathered_wood,
		"gathered_stone": gathered_stone,
		"technologies": technology_tree.learned.duplicate(),
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
	_resolve_player_projectiles_immediately = false
	return metrics

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
		if child is WorldPickup and not child.is_queued_for_deletion() and (child as WorldPickup).kind == kind:
			return child as WorldPickup
	return null

func _draw() -> void:
	draw_rect(Rect2(-1024.0, -704.0, 2048.0, 1408.0), Color("193d4a"))
	for water_y: int in range(-672, 704, 96):
		var offset := 34.0 if posmod(water_y / 96, 2) == 0 else 0.0
		for water_x: int in range(-992, 992, 128):
			draw_line(Vector2(water_x + offset, water_y), Vector2(water_x + offset + 38.0, water_y), Color(0.35, 0.71, 0.72, 0.24), 3.0)
	for x: int in range(-896, 896, 64):
		for y: int in range(-576, 576, 64):
			var asset_id := handdrawn_terrain_id(Vector2i(x, y))
			draw_texture_rect_region(VisualAssetLibrary.HANDDRAWN_TERRAIN_ATLAS, Rect2(x, y, 64, 64), VisualAssetLibrary.handdrawn_terrain_region(asset_id))
	draw_rect(Rect2(-896.0, -576.0, 1792.0, 1152.0), Color(0.03, 0.13, 0.10, 0.16))
	_draw_terrain_micro_biomes()
	for placement: Dictionary in HANDDRAWN_DECO_LAYOUT:
		var position_value := placement.position as Vector2
		draw_texture_rect(VisualAssetLibrary.handdrawn_deco_texture(int(placement.frame)), Rect2(position_value - Vector2(32, 32), Vector2(64, 64)), false)

func _draw_terrain_micro_biomes() -> void:
	var grove := PackedVector2Array([Vector2(-875, -520), Vector2(-425, -520), Vector2(-385, -390), Vector2(-470, -250), Vector2(-710, -220), Vector2(-875, -315)])
	var moonleaf_meadow := PackedVector2Array([Vector2(-835, 120), Vector2(-560, 70), Vector2(-390, 185), Vector2(-430, 470), Vector2(-760, 520), Vector2(-875, 360)])
	var stone_rise := PackedVector2Array([Vector2(315, -525), Vector2(835, -525), Vector2(875, -305), Vector2(735, -135), Vector2(470, -190), Vector2(355, -345)])
	var sunlit_lowland := PackedVector2Array([Vector2(315, 170), Vector2(585, 105), Vector2(855, 225), Vector2(860, 520), Vector2(405, 520), Vector2(265, 365)])
	var zones: Array[Dictionary] = [
		{"points": grove, "fill": Color(0.08, 0.24, 0.13, 0.28), "edge": Color(0.32, 0.57, 0.30, 0.42)},
		{"points": moonleaf_meadow, "fill": Color(0.18, 0.13, 0.28, 0.24), "edge": Color(0.55, 0.42, 0.72, 0.38)},
		{"points": stone_rise, "fill": Color(0.26, 0.27, 0.22, 0.25), "edge": Color(0.64, 0.62, 0.46, 0.42)},
		{"points": sunlit_lowland, "fill": Color(0.33, 0.25, 0.08, 0.18), "edge": Color(0.84, 0.66, 0.28, 0.36)},
	]
	for zone: Dictionary in zones:
		var points := zone.points as PackedVector2Array
		draw_colored_polygon(points, zone.fill as Color)
		var outline := points.duplicate()
		outline.append(points[0])
		draw_polyline(outline, Color(zone.edge, 0.2), 2.0)
	for index: int in 28:
		var x := -790.0 + float(posmod(index * 173, 1580))
		var y := -490.0 + float(posmod(index * 257, 980))
		var point := Vector2(x, y)
		draw_colored_polygon(PackedVector2Array([point + Vector2(0, -3), point + Vector2(4, 0), point + Vector2(0, 3), point + Vector2(-4, 0)]), Color(0.64, 0.78, 0.43, 0.26))
	for edge_y: int in range(-470, 500, 96):
		draw_line(Vector2(-902, edge_y), Vector2(-884, edge_y + 10), Color(0.72, 0.84, 0.55, 0.42), 3.0)
		draw_line(Vector2(902, edge_y + 24), Vector2(884, edge_y + 34), Color(0.72, 0.84, 0.55, 0.42), 3.0)

func handdrawn_terrain_id(tile_position: Vector2i) -> String:
	var x := tile_position.x
	var y := tile_position.y
	var main_path := absf(float(y)) < 64.0 and x >= -640 and x <= 704
	var north_path := absf(float(x)) < 64.0 and y >= -448 and y <= 128
	if main_path and north_path:
		return "path_cross"
	if main_path:
		return "path_horizontal"
	if north_path:
		return "path_vertical"
	if x == -896 and y == -576:
		return "grass_top_left"
	if x == 832 and y == -576:
		return "grass_top_right"
	if x == -896 and y == 512:
		return "grass_bottom_left"
	if x == 832 and y == 512:
		return "grass_bottom_right"
	if y == -576:
		return "grass_top"
	if y == 512:
		return "grass_bottom"
	if x == -896:
		return "grass_left"
	if x == 832:
		return "grass_right"
	var variation := posmod((x / 64) * 3 + (y / 64) * 5, 11)
	if variation == 0:
		return "grass_b"
	if variation == 1:
		return "grass_c"
	return "grass"

func uses_plus_terrain_markers() -> bool:
	return false
