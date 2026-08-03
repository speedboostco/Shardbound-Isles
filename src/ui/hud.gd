class_name GameHud
extends CanvasLayer

signal equipment_panel_requested
signal equipment_panel_closed
signal equip_requested(index: int)
signal salvage_requested(index: int)
signal unequip_requested
signal workbench_panel_requested
signal workbench_panel_closed
signal craft_requested
signal tidecatcher_build_requested
signal system_menu_requested
signal system_menu_closed
signal save_requested
signal load_requested

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
@onready var workbench_panel: PanelContainer = $WorkbenchPanel
@onready var recipe_cost_label: Label = $WorkbenchPanel/Margin/VBox/Cost
@onready var recipe_status_label: Label = $WorkbenchPanel/Margin/VBox/Status
@onready var craft_button: Button = $WorkbenchPanel/Margin/VBox/Craft
@onready var tidecatcher_build_button: Button = $WorkbenchPanel/Margin/VBox/BuildTidecatcher
@onready var automation_label: Label = $AutomationStatus
@onready var system_panel: PanelContainer = $SystemPanel
@onready var system_feedback_label: Label = $SystemPanel/Margin/VBox/Feedback
@onready var save_button: Button = $SystemPanel/Margin/VBox/Save

var _items: Array[Dictionary] = []
var _equipped_id: String = ""
var _displayed_attack_damage: int = 1
var _displayed_scrap: int = 0

func _ready() -> void:
	equip_button.pressed.connect(func() -> void: equip_requested.emit(0))
	salvage_button.pressed.connect(func() -> void: salvage_requested.emit(0))
	unequip_button.pressed.connect(func() -> void: unequip_requested.emit())
	$EquipmentPanel/Margin/VBox/Close.pressed.connect(close_equipment_panel)
	craft_button.pressed.connect(func() -> void: craft_requested.emit())
	tidecatcher_build_button.pressed.connect(func() -> void: tidecatcher_build_requested.emit())
	$WorkbenchPanel/Margin/VBox/Close.pressed.connect(close_workbench_panel)
	save_button.pressed.connect(func() -> void: save_requested.emit())
	$SystemPanel/Margin/VBox/Load.pressed.connect(func() -> void: load_requested.emit())
	$SystemPanel/Margin/VBox/Close.pressed.connect(close_system_menu)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if system_panel.visible:
			close_system_menu()
		else:
			system_menu_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("equipment"):
		if equipment_panel.visible:
			close_equipment_panel()
		else:
			equipment_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("craft"):
		if workbench_panel.visible:
			close_workbench_panel()
		elif not equipment_panel.visible:
			workbench_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif equipment_panel.visible and event.is_action_pressed("ui_cancel"):
		close_equipment_panel()
		get_viewport().set_input_as_handled()
	elif workbench_panel.visible and event.is_action_pressed("ui_cancel"):
		close_workbench_panel()
		get_viewport().set_input_as_handled()
	elif system_panel.visible and event.is_action_pressed("ui_cancel"):
		close_system_menu()
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

func refresh_workbench(wood: int, scrap: int, already_crafted: bool, tidecatcher_built: bool, feedback: String = "") -> void:
	recipe_cost_label.text = "COST  %d / 3 WOOD    •    %d / 2 SCRAP" % [wood, scrap]
	if already_crafted:
		recipe_status_label.text = feedback if not feedback.is_empty() else "ALREADY CRAFTED"
		craft_button.disabled = true
	else:
		var affordable := wood >= 3 and scrap >= 2
		recipe_status_label.text = feedback if not feedback.is_empty() else ("READY TO CRAFT" if affordable else "NEED MORE RESOURCES")
		craft_button.disabled = not affordable
	if tidecatcher_built:
		tidecatcher_build_button.text = "TIDECATCHER BUILT"
		tidecatcher_build_button.disabled = true
	elif already_crafted:
		tidecatcher_build_button.text = "BUILD TIDECATCHER — FREE"
		tidecatcher_build_button.disabled = false
	else:
		tidecatcher_build_button.text = "TIDECATCHER — REQUIRES HEART"
		tidecatcher_build_button.disabled = true
	if workbench_panel.visible:
		if not craft_button.disabled:
			craft_button.grab_focus()
		elif not tidecatcher_build_button.disabled:
			tidecatcher_build_button.grab_focus()
		else:
			$WorkbenchPanel/Margin/VBox/Close.grab_focus()

func open_workbench_panel() -> void:
	equipment_panel.visible = false
	workbench_panel.visible = true
	if not craft_button.disabled:
		craft_button.grab_focus()
	else:
		$WorkbenchPanel/Margin/VBox/Close.grab_focus()

func close_workbench_panel() -> void:
	workbench_panel.visible = false
	workbench_panel_closed.emit()

func is_workbench_panel_open() -> bool:
	return workbench_panel.visible

func get_crafting_feedback() -> String:
	return recipe_status_label.text

func set_automation_status(active: bool, stored: int, capacity: int, feedback: String = "") -> void:
	automation_label.visible = active or not feedback.is_empty()
	if not feedback.is_empty():
		automation_label.text = feedback
	elif active:
		automation_label.text = "TIDECATCHER  %d / %d WOOD  •  APPROACH TO COLLECT" % [stored, capacity]

func is_tidecatcher_visible() -> bool:
	return automation_label.visible

func get_automation_feedback() -> String:
	return automation_label.text

func is_tidecatcher_build_focused() -> bool:
	return get_viewport().gui_get_focus_owner() == tidecatcher_build_button

func open_system_menu() -> void:
	equipment_panel.visible = false
	workbench_panel.visible = false
	system_panel.visible = true
	save_button.grab_focus()

func close_system_menu() -> void:
	system_panel.visible = false
	system_menu_closed.emit()

func is_system_menu_open() -> bool:
	return system_panel.visible

func set_system_feedback(message: String) -> void:
	system_feedback_label.text = message

func get_system_feedback() -> String:
	return system_feedback_label.text

func _salvage_value(rarity: String) -> int:
	return 2 if rarity == "uncommon" else 1
