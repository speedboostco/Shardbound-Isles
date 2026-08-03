class_name FirstPlayableWorld
extends Node2D

const EQUIPMENT_SEED: int = 424242

@onready var player: PlayerCharacter = $Player
@onready var tree: ResourceNode = $Tree
@onready var enemy: ChaserEnemy = $Enemy
@onready var hud: GameHud = $HUD

var wood: int = 0
var equipment_inventory := EquipmentInventory.new()
var equipment: Array[Dictionary] = equipment_inventory.items
var enemies_defeated: int = 0

func _ready() -> void:
	player.attack_requested.connect(_on_attack_requested)
	player.health_changed.connect(hud.set_health)
	tree.depleted.connect(_on_tree_depleted)
	enemy.target = player
	enemy.defeated.connect(_on_enemy_defeated)
	hud.set_health(player.health, player.maximum_health)
	hud.set_wood(wood)
	hud.equipment_panel_requested.connect(open_equipment_panel)
	hud.equipment_panel_closed.connect(_on_equipment_panel_closed)
	hud.equip_requested.connect(equip_selected_item)
	hud.salvage_requested.connect(salvage_selected_item)
	hud.unequip_requested.connect(unequip_item)
	_refresh_equipment_ui()

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

func open_equipment_panel() -> void:
	_refresh_equipment_ui()
	hud.open_equipment_panel()
	player.input_enabled = false
	if is_instance_valid(enemy):
		enemy.set_physics_process(false)

func close_equipment_panel() -> void:
	hud.close_equipment_panel()

func _on_equipment_panel_closed() -> void:
	player.input_enabled = true
	if is_instance_valid(enemy):
		enemy.set_physics_process(true)

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
