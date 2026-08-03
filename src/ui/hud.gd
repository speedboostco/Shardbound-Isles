class_name GameHud
extends CanvasLayer

signal equipment_panel_requested
signal equipment_panel_closed
signal equip_requested(index: int)
signal salvage_requested(index: int)
signal unequip_requested

@onready var health_label: Label = $Margin/VBox/Health
@onready var wood_label: Label = $Margin/VBox/Wood
@onready var loot_label: Label = $Margin/VBox/Loot
@onready var attack_label: Label = $Margin/VBox/Attack
@onready var equipment_panel: PanelContainer = $EquipmentPanel
@onready var item_name_label: Label = $EquipmentPanel/Margin/VBox/ItemName
@onready var comparison_label: Label = $EquipmentPanel/Margin/VBox/Comparison
@onready var equipped_label: Label = $EquipmentPanel/Margin/VBox/Equipped
@onready var scrap_label: Label = $EquipmentPanel/Margin/VBox/Scrap
@onready var equip_button: Button = $EquipmentPanel/Margin/VBox/Actions/Equip
@onready var salvage_button: Button = $EquipmentPanel/Margin/VBox/Actions/Salvage
@onready var unequip_button: Button = $EquipmentPanel/Margin/VBox/Actions/Unequip

var _items: Array[Dictionary] = []
var _equipped_id: String = ""
var _displayed_attack_damage: int = 1
var _displayed_scrap: int = 0

func _ready() -> void:
	equip_button.pressed.connect(func() -> void: equip_requested.emit(0))
	salvage_button.pressed.connect(func() -> void: salvage_requested.emit(0))
	unequip_button.pressed.connect(func() -> void: unequip_requested.emit())
	$EquipmentPanel/Margin/VBox/Close.pressed.connect(close_equipment_panel)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equipment"):
		if equipment_panel.visible:
			close_equipment_panel()
		else:
			equipment_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif equipment_panel.visible and event.is_action_pressed("ui_cancel"):
		close_equipment_panel()
		get_viewport().set_input_as_handled()

func set_health(current: int, maximum: int) -> void:
	health_label.text = "HEALTH  %d / %d" % [current, maximum]

func set_wood(amount: int) -> void:
	wood_label.text = "WOOD    %d" % amount

func set_loot(item: Dictionary) -> void:
	loot_label.text = "FOUND  %s  |  POWER %d" % [item.get("name", "None"), item.get("power", 0)]

func refresh_equipment(items: Array[Dictionary], equipped_item: Dictionary, scrap: int, attack_damage: int) -> void:
	_items = items
	_equipped_id = String(equipped_item.get("id", ""))
	_displayed_scrap = scrap
	_displayed_attack_damage = attack_damage
	attack_label.text = "ATTACK  %d" % attack_damage
	scrap_label.text = "SALVAGE SCRAP  %d" % scrap
	equipped_label.text = "EQUIPPED  %s" % String(equipped_item.get("name", "Unarmed"))
	if items.is_empty():
		item_name_label.text = "NO EQUIPMENT IN PACK"
		comparison_label.text = "Defeat enemies to find equipment."
		equip_button.disabled = true
		salvage_button.disabled = true
	else:
		var item := items[0]
		var equipped_power := int(equipped_item.get("power", 0))
		var delta := int(item.get("power", 0)) - equipped_power
		item_name_label.text = "%s  •  %s  •  POWER %d" % [item.get("name", "Unknown"), String(item.get("rarity", "common")).to_upper(), item.get("power", 0)]
		comparison_label.text = "POWER CHANGE  %+d    |    SALVAGE VALUE  %d" % [delta, _salvage_value(String(item.get("rarity", "common")))]
		equip_button.disabled = String(item.get("id", "")) == _equipped_id
		salvage_button.disabled = String(item.get("id", "")) == _equipped_id
	unequip_button.disabled = _equipped_id.is_empty()

func open_equipment_panel() -> void:
	equipment_panel.visible = true
	if not equip_button.disabled:
		equip_button.grab_focus()
	elif not unequip_button.disabled:
		unequip_button.grab_focus()
	else:
		$EquipmentPanel/Margin/VBox/Close.grab_focus()

func close_equipment_panel() -> void:
	equipment_panel.visible = false
	equipment_panel_closed.emit()

func is_equipment_panel_open() -> bool:
	return equipment_panel.visible

func has_valid_action_focus() -> bool:
	return get_viewport().gui_get_focus_owner() != null

func get_inventory_item_count() -> int:
	return _items.size()

func get_displayed_attack_damage() -> int:
	return _displayed_attack_damage

func get_displayed_scrap() -> int:
	return _displayed_scrap

func _salvage_value(rarity: String) -> int:
	return 2 if rarity == "uncommon" else 1

