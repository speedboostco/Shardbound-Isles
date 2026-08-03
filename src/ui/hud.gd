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
signal island_panel_requested
signal island_panel_closed
signal island_install_requested(index: int)
signal island_remove_requested
signal rift_requested

@onready var health_label: Label = $Margin/VBox/Health
@onready var wood_label: Label = $Margin/VBox/Wood
@onready var loot_label: Label = $Margin/VBox/Loot
@onready var attack_label: Label = $Margin/VBox/Attack
@onready var equipment_panel: PanelContainer = $EquipmentPanel
@onready var item_name_label: Label = $EquipmentPanel/Margin/VBox/ItemName
@onready var equipment_previous_button: Button = $EquipmentPanel/Margin/VBox/Selection/Previous
@onready var equipment_count_label: Label = $EquipmentPanel/Margin/VBox/Selection/Count
@onready var equipment_next_button: Button = $EquipmentPanel/Margin/VBox/Selection/Next
@onready var comparison_label: Label = $EquipmentPanel/Margin/VBox/Comparison
@onready var affix_label: Label = $EquipmentPanel/Margin/VBox/Affix
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
@onready var island_panel: PanelContainer = $IslandPanel
@onready var island_name_label: Label = $IslandPanel/Margin/VBox/ShardName
@onready var island_previous_button: Button = $IslandPanel/Margin/VBox/Selection/Previous
@onready var island_count_label: Label = $IslandPanel/Margin/VBox/Selection/Count
@onready var island_next_button: Button = $IslandPanel/Margin/VBox/Selection/Next
@onready var island_status_label: Label = $IslandPanel/Margin/VBox/Status
@onready var island_install_button: Button = $IslandPanel/Margin/VBox/Actions/Install
@onready var island_remove_button: Button = $IslandPanel/Margin/VBox/Actions/Remove
@onready var encounter_label: Label = $EncounterStatus
@onready var rift_label: Label = $RiftStatus

var _items: Array[Dictionary] = []
var _equipped_id: String = ""
var _equipped_item: Dictionary = {}
var _selected_equipment_index: int = 0
var _displayed_attack_damage: int = 1
var _displayed_scrap: int = 0
var _island_shards: Array[Dictionary] = []
var _installed_island: Dictionary = {}
var _selected_island_index: int = 0

func _ready() -> void:
	equipment_previous_button.pressed.connect(func() -> void: _select_relative_equipment(-1))
	equipment_next_button.pressed.connect(func() -> void: _select_relative_equipment(1))
	equip_button.pressed.connect(func() -> void: equip_requested.emit(_selected_equipment_index))
	salvage_button.pressed.connect(func() -> void: salvage_requested.emit(_selected_equipment_index))
	unequip_button.pressed.connect(func() -> void: unequip_requested.emit())
	$EquipmentPanel/Margin/VBox/Close.pressed.connect(close_equipment_panel)
	craft_button.pressed.connect(func() -> void: craft_requested.emit())
	tidecatcher_build_button.pressed.connect(func() -> void: tidecatcher_build_requested.emit())
	$WorkbenchPanel/Margin/VBox/Close.pressed.connect(close_workbench_panel)
	save_button.pressed.connect(func() -> void: save_requested.emit())
	$SystemPanel/Margin/VBox/Load.pressed.connect(func() -> void: load_requested.emit())
	$SystemPanel/Margin/VBox/Close.pressed.connect(close_system_menu)
	island_previous_button.pressed.connect(func() -> void: _select_relative_island(-1))
	island_next_button.pressed.connect(func() -> void: _select_relative_island(1))
	island_install_button.pressed.connect(func() -> void: island_install_requested.emit(_selected_island_index))
	island_remove_button.pressed.connect(func() -> void: island_remove_requested.emit())
	$IslandPanel/Margin/VBox/Close.pressed.connect(close_island_panel)

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
		elif not workbench_panel.visible and not system_panel.visible and not island_panel.visible:
			equipment_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("craft"):
		if workbench_panel.visible:
			close_workbench_panel()
		elif not equipment_panel.visible and not system_panel.visible and not island_panel.visible:
			workbench_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("islands"):
		if island_panel.visible:
			close_island_panel()
		elif not equipment_panel.visible and not workbench_panel.visible and not system_panel.visible:
			island_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rift"):
		if not equipment_panel.visible and not workbench_panel.visible and not system_panel.visible and not island_panel.visible:
			rift_requested.emit()
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
	elif island_panel.visible and event.is_action_pressed("ui_cancel"):
		close_island_panel()
		get_viewport().set_input_as_handled()

func set_health(current: int, maximum: int) -> void:
	health_label.text = "HEALTH  %d / %d" % [current, maximum]

func set_wood(amount: int) -> void:
	wood_label.text = "WOOD    %d" % amount

func set_loot(item: Dictionary) -> void:
	loot_label.text = "FOUND  %s  |  POWER %d" % [item.get("name", "None"), item.get("power", 0)]

func refresh_equipment(items: Array[Dictionary], equipped_item: Dictionary, scrap: int, attack_damage: int) -> void:
	_items.clear()
	for item: Dictionary in items:
		_items.append(item.duplicate(true))
	_equipped_item = equipped_item.duplicate(true)
	_equipped_id = String(equipped_item.get("id", ""))
	_displayed_scrap = scrap
	_displayed_attack_damage = attack_damage
	attack_label.text = "ATTACK  %d" % attack_damage
	scrap_label.text = "SALVAGE SCRAP  %d" % scrap
	equipped_label.text = "EQUIPPED  %s" % String(equipped_item.get("name", "Unarmed"))
	if _items.is_empty():
		_selected_equipment_index = 0
	else:
		_selected_equipment_index = clampi(_selected_equipment_index, 0, _items.size() - 1)
	_render_selected_equipment()
	_recover_equipment_focus()

func _render_selected_equipment() -> void:
	if _items.is_empty():
		item_name_label.text = "NO EQUIPMENT IN PACK"
		comparison_label.text = "Defeat enemies to find equipment."
		affix_label.text = ""
		equipment_count_label.text = "0 / 0"
		equipment_previous_button.disabled = true
		equipment_next_button.disabled = true
		equip_button.disabled = true
		salvage_button.disabled = true
	else:
		var item := _items[_selected_equipment_index]
		var equipped_power := int(_equipped_item.get("power", 0))
		var delta := int(item.get("power", 0)) - equipped_power
		item_name_label.text = "%s  •  %s  •  POWER %d" % [item.get("name", "Unknown"), String(item.get("rarity", "common")).to_upper(), item.get("power", 0)]
		comparison_label.text = "POWER CHANGE  %+d    |    SALVAGE VALUE  %d" % [delta, _salvage_value(String(item.get("rarity", "common")))]
		var affix_name := String(item.get("legendary_affix_name", ""))
		var affix_description := String(item.get("legendary_affix_description", ""))
		affix_label.text = "%s — %s" % [affix_name.to_upper(), affix_description] if not affix_name.is_empty() else ""
		equipment_count_label.text = "%d / %d" % [_selected_equipment_index + 1, _items.size()]
		equipment_previous_button.disabled = _items.size() <= 1
		equipment_next_button.disabled = _items.size() <= 1
		equip_button.disabled = String(item.get("id", "")) == _equipped_id
		salvage_button.disabled = String(item.get("id", "")) == _equipped_id
	unequip_button.disabled = _equipped_id.is_empty()

func select_equipment(index: int) -> bool:
	if index < 0 or index >= _items.size():
		return false
	_selected_equipment_index = index
	_render_selected_equipment()
	_recover_equipment_focus()
	return true

func _select_relative_equipment(offset: int) -> void:
	if _items.is_empty():
		return
	select_equipment(posmod(_selected_equipment_index + offset, _items.size()))

func _recover_equipment_focus() -> void:
	if not equipment_panel.visible:
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is Control and (focused as Control).is_visible_in_tree():
		if not focused is BaseButton or not (focused as BaseButton).disabled:
			return
	if not equip_button.disabled:
		equip_button.grab_focus()
	elif not salvage_button.disabled:
		salvage_button.grab_focus()
	elif not unequip_button.disabled:
		unequip_button.grab_focus()
	else:
		$EquipmentPanel/Margin/VBox/Close.grab_focus()

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

func get_selected_equipment_index() -> int:
	return _selected_equipment_index

func get_displayed_equipment_id() -> String:
	if _items.is_empty():
		return ""
	return String(_items[_selected_equipment_index].get("id", ""))

func get_displayed_affix_text() -> String:
	return affix_label.text

func get_displayed_comparison_text() -> String:
	return comparison_label.text

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
	island_panel.visible = false
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

func refresh_islands(shards: Array[Dictionary], installed: Dictionary) -> void:
	_island_shards.clear()
	for shard: Dictionary in shards:
		_island_shards.append(shard.duplicate(true))
	_installed_island = installed.duplicate(true)
	if _island_shards.is_empty():
		_selected_island_index = 0
	else:
		_selected_island_index = clampi(_selected_island_index, 0, _island_shards.size() - 1)
	_render_selected_island()

func _render_selected_island() -> void:
	if _island_shards.is_empty():
		island_name_label.text = "NO ISLAND SHARDS"
		$IslandPanel/Margin/VBox/Biome.text = "Defeat enemies to discover world loot."
		$IslandPanel/Margin/VBox/Positive.text = ""
		$IslandPanel/Margin/VBox/Negative.text = ""
		island_count_label.text = "0 / 0"
		island_previous_button.disabled = true
		island_next_button.disabled = true
		island_install_button.disabled = true
	else:
		var shard := _island_shards[_selected_island_index]
		island_name_label.text = String(shard.get("name", "Unknown Shard")).to_upper()
		$IslandPanel/Margin/VBox/Biome.text = "BIOME  %s    •    SEED %d" % [String(shard.get("biome", "unknown")).to_upper(), int(shard.get("seed", 0))]
		$IslandPanel/Margin/VBox/Positive.text = "REWARD  %s" % String(shard.get("reward_description", "Tree nodes yield +%d wood" % int(shard.get("tree_yield_bonus", 0))))
		$IslandPanel/Margin/VBox/Negative.text = "RISK  %s" % String(shard.get("risk_description", "Enemies move %d%% faster" % int(round((float(shard.get("enemy_speed_multiplier", 1.0)) - 1.0) * 100.0))))
		island_count_label.text = "%d / %d" % [_selected_island_index + 1, _island_shards.size()]
		island_previous_button.disabled = _island_shards.size() <= 1
		island_next_button.disabled = _island_shards.size() <= 1
		island_install_button.text = "REPLACE INSTALLED SHARD" if not _installed_island.is_empty() else "INSTALL EASTERN ISLAND"
		island_install_button.disabled = false
	island_remove_button.disabled = _installed_island.is_empty()
	island_status_label.text = "INSTALLED  %s" % String(_installed_island.get("name", "None"))

func select_island(index: int) -> bool:
	if index < 0 or index >= _island_shards.size():
		return false
	_selected_island_index = index
	_render_selected_island()
	return true

func _select_relative_island(offset: int) -> void:
	if _island_shards.is_empty():
		return
	select_island(posmod(_selected_island_index + offset, _island_shards.size()))

func get_selected_island_index() -> int:
	return _selected_island_index

func get_island_count() -> int:
	return _island_shards.size()

func open_island_panel() -> void:
	island_panel.visible = true
	if not island_install_button.disabled:
		island_install_button.grab_focus()
	elif not island_remove_button.disabled:
		island_remove_button.grab_focus()
	else:
		$IslandPanel/Margin/VBox/Close.grab_focus()

func close_island_panel() -> void:
	island_panel.visible = false
	island_panel_closed.emit()

func is_island_panel_open() -> bool:
	return island_panel.visible

func set_encounter_feedback(message: String) -> void:
	encounter_label.visible = not message.is_empty()
	encounter_label.text = message

func get_encounter_feedback() -> String:
	return encounter_label.text

func set_rift_feedback(message: String) -> void:
	rift_label.visible = not message.is_empty()
	rift_label.text = message

func get_rift_feedback() -> String:
	return rift_label.text

func _salvage_value(rarity: String) -> int:
	return EquipmentInventory.salvage_value_for_rarity(rarity)
