class_name GameHud
extends CanvasLayer

signal equipment_panel_requested
signal equipment_panel_closed
signal equip_requested(index: int)
signal salvage_requested(index: int)
signal favorite_requested(index: int, favorite: bool)
signal unequip_requested
signal workbench_panel_requested
signal workbench_panel_closed
signal craft_requested(recipe_id: String)
signal tidecatcher_build_requested
signal upgrade_requested(confirmed: bool)
signal placement_socket_requested(offset: int)
signal placement_rotate_requested
signal placement_confirm_requested
signal placement_cancel_requested
signal base_deposit_requested(resource_id: String)
signal base_withdraw_requested(resource_id: String)
signal system_menu_requested
signal system_menu_closed
signal save_requested
signal load_requested
signal island_panel_requested
signal island_panel_closed
signal island_install_requested(index: int, slot_id: String)
signal island_remove_requested(slot_id: String)
signal rift_requested

@onready var health_label: Label = $Margin/VBox/Health
@onready var wood_label: Label = $Margin/VBox/Wood
@onready var stone_label: Label = $Margin/VBox/Stone
@onready var moonleaf_label: Label = $Margin/VBox/Moonleaf
@onready var plank_label: Label = $Margin/VBox/Plank
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
@onready var favorite_button: Button = $EquipmentPanel/Margin/VBox/Actions/Favorite
@onready var unequip_button: Button = $EquipmentPanel/Margin/VBox/Actions/Unequip
@onready var workbench_panel: PanelContainer = $WorkbenchPanel
@onready var workbench_recipe_label: Label = $WorkbenchPanel/Margin/VBox/Recipe
@onready var workbench_effect_label: Label = $WorkbenchPanel/Margin/VBox/Effect
@onready var workbench_previous_button: Button = $WorkbenchPanel/Margin/VBox/Selection/Previous
@onready var workbench_count_label: Label = $WorkbenchPanel/Margin/VBox/Selection/Count
@onready var workbench_next_button: Button = $WorkbenchPanel/Margin/VBox/Selection/Next
@onready var recipe_cost_label: Label = $WorkbenchPanel/Margin/VBox/Cost
@onready var recipe_status_label: Label = $WorkbenchPanel/Margin/VBox/Status
@onready var craft_button: Button = $WorkbenchPanel/Margin/VBox/Craft
@onready var tidecatcher_build_button: Button = $WorkbenchPanel/Margin/VBox/BuildTidecatcher
@onready var upgrade_preview_label: Label = $WorkbenchPanel/Margin/VBox/UpgradePreview
@onready var upgrade_button: Button = $WorkbenchPanel/Margin/VBox/Upgrade
@onready var base_deposit_button: Button = $WorkbenchPanel/Margin/VBox/BaseTransfer/DepositWood
@onready var base_withdraw_button: Button = $WorkbenchPanel/Margin/VBox/BaseTransfer/CollectPlanks
@onready var automation_label: Label = $AutomationStatus
@onready var base_status_label: Label = $BaseStatus
@onready var placement_panel: PanelContainer = $PlacementPanel
@onready var placement_title_label: Label = $PlacementPanel/Margin/VBox/Title
@onready var placement_state_label: Label = $PlacementPanel/Margin/VBox/State
@onready var placement_confirm_button: Button = $PlacementPanel/Margin/VBox/Actions/Confirm
@onready var system_panel: PanelContainer = $SystemPanel
@onready var system_feedback_label: Label = $SystemPanel/Margin/VBox/Feedback
@onready var save_button: Button = $SystemPanel/Margin/VBox/Save
@onready var island_panel: PanelContainer = $IslandPanel
@onready var island_name_label: Label = $IslandPanel/Margin/VBox/ShardName
@onready var island_previous_button: Button = $IslandPanel/Margin/VBox/Selection/Previous
@onready var island_count_label: Label = $IslandPanel/Margin/VBox/Selection/Count
@onready var island_next_button: Button = $IslandPanel/Margin/VBox/Selection/Next
@onready var island_slot_previous_button: Button = $IslandPanel/Margin/VBox/SlotSelection/Previous
@onready var island_slot_label: Label = $IslandPanel/Margin/VBox/SlotSelection/Slot
@onready var island_slot_next_button: Button = $IslandPanel/Margin/VBox/SlotSelection/Next
@onready var island_synergy_label: Label = $IslandPanel/Margin/VBox/Synergy
@onready var island_status_label: Label = $IslandPanel/Margin/VBox/Status
@onready var island_install_button: Button = $IslandPanel/Margin/VBox/Actions/Install
@onready var island_remove_button: Button = $IslandPanel/Margin/VBox/Actions/Remove
@onready var encounter_label: Label = $EncounterStatus
@onready var rift_label: Label = $RiftStatus
@onready var interaction_prompt: Label = $InteractionPrompt

var _items: Array[Dictionary] = []
var _equipped_id: String = ""
var _equipped_item: Dictionary = {}
var _equipped_slots: Dictionary = {}
var _selected_equipment_index: int = 0
var _displayed_attack_damage: int = 1
var _displayed_attack_speed: float = 1.0
var _displayed_scrap: int = 0
var _displayed_stone: int = 0
var _selected_recipe_index: int = 0
var _workbench_wood: int = 0
var _workbench_stone: int = 0
var _workbench_moonleaf: int = 0
var _workbench_scrap: int = 0
var _workbench_plank: int = 0
var _heart_crafted: bool = false
var _whetstone_crafted: bool = false
var _herbal_compass_crafted: bool = false
var _workbench_unlocks: Dictionary = {}
var _workbench_crafted: Dictionary = {}
var _upgrade_confirmation_armed: bool = false
var _island_shards: Array[Dictionary] = []
var _archipelago_data: Dictionary = {}
var _selected_island_index: int = 0
var _selected_island_slot_index: int = 0
var _pending_island_action: String = ""
const ISLAND_SLOT_IDS: Array[String] = ["east", "north_east", "south_east"]

func _ready() -> void:
	equipment_previous_button.pressed.connect(func() -> void: _select_relative_equipment(-1))
	equipment_next_button.pressed.connect(func() -> void: _select_relative_equipment(1))
	equip_button.pressed.connect(func() -> void: equip_requested.emit(_selected_equipment_index))
	salvage_button.pressed.connect(func() -> void: salvage_requested.emit(_selected_equipment_index))
	favorite_button.pressed.connect(_toggle_selected_favorite)
	unequip_button.pressed.connect(func() -> void: unequip_requested.emit())
	$EquipmentPanel/Margin/VBox/Close.pressed.connect(close_equipment_panel)
	workbench_previous_button.pressed.connect(func() -> void: _select_relative_recipe(-1))
	workbench_next_button.pressed.connect(func() -> void: _select_relative_recipe(1))
	craft_button.pressed.connect(func() -> void: craft_requested.emit(get_selected_recipe_id()))
	tidecatcher_build_button.pressed.connect(func() -> void: tidecatcher_build_requested.emit())
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	base_deposit_button.pressed.connect(func() -> void: base_deposit_requested.emit("wood"))
	base_withdraw_button.pressed.connect(func() -> void: base_withdraw_requested.emit("plank"))
	$WorkbenchPanel/Margin/VBox/Close.pressed.connect(close_workbench_panel)
	$PlacementPanel/Margin/VBox/Actions/Previous.pressed.connect(func() -> void: placement_socket_requested.emit(-1))
	$PlacementPanel/Margin/VBox/Actions/Next.pressed.connect(func() -> void: placement_socket_requested.emit(1))
	$PlacementPanel/Margin/VBox/Actions/Rotate.pressed.connect(func() -> void: placement_rotate_requested.emit())
	placement_confirm_button.pressed.connect(func() -> void: placement_confirm_requested.emit())
	$PlacementPanel/Margin/VBox/Actions/Cancel.pressed.connect(func() -> void: placement_cancel_requested.emit())
	save_button.pressed.connect(func() -> void: save_requested.emit())
	$SystemPanel/Margin/VBox/Load.pressed.connect(func() -> void: load_requested.emit())
	$SystemPanel/Margin/VBox/Close.pressed.connect(close_system_menu)
	island_previous_button.pressed.connect(func() -> void: _select_relative_island(-1))
	island_next_button.pressed.connect(func() -> void: _select_relative_island(1))
	island_slot_previous_button.pressed.connect(func() -> void: _select_relative_island_slot(-1))
	island_slot_next_button.pressed.connect(func() -> void: _select_relative_island_slot(1))
	island_install_button.pressed.connect(_request_selected_island_install)
	island_remove_button.pressed.connect(_request_selected_island_remove)
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
	elif placement_panel.visible and event.is_action_pressed("ui_cancel"):
		placement_cancel_requested.emit()
		get_viewport().set_input_as_handled()

func set_health(current: int, maximum: int) -> void:
	health_label.text = "HEALTH  %d / %d" % [current, maximum]

func set_wood(amount: int) -> void:
	wood_label.text = "WOOD    %d" % amount

func set_stone(amount: int) -> void:
	_displayed_stone = amount
	stone_label.text = "STONE   %d" % amount

func set_moonleaf(amount: int) -> void:
	moonleaf_label.text = "MOONLEAF  %d" % amount

func set_plank(amount: int) -> void:
	plank_label.text = "PLANKS  %d" % amount

func get_displayed_stone() -> int:
	return _displayed_stone

func set_interaction_prompt(label: String) -> void:
	interaction_prompt.visible = not label.is_empty()
	interaction_prompt.text = "A / E  %s" % label.to_upper() if not label.is_empty() else ""

func get_interaction_prompt() -> String:
	return interaction_prompt.text if interaction_prompt.visible else ""

func get_displayed_attack_speed() -> float:
	return _displayed_attack_speed

func set_loot(item: Dictionary) -> void:
	loot_label.text = "FOUND  %s  |  DMG %d  |  SPEED %.2fx" % [item.get("name", "None"), item.get("damage", item.get("power", 0)), item.get("attack_speed", 1.0)]

func refresh_equipment(items: Array[Dictionary], equipped_item: Dictionary, scrap: int, attack_damage: int, attack_speed: float = 1.0, equipped_slots: Dictionary = {}) -> void:
	_items.clear()
	for item: Dictionary in items:
		_items.append(item.duplicate(true))
	_equipped_item = equipped_item.duplicate(true)
	_equipped_id = String(equipped_item.get("id", ""))
	_equipped_slots = equipped_slots.duplicate(true)
	if _equipped_slots.is_empty() and not _equipped_id.is_empty():
		_equipped_slots["weapon"] = _equipped_id
	_displayed_scrap = scrap
	_displayed_attack_damage = attack_damage
	_displayed_attack_speed = attack_speed
	attack_label.text = "ATTACK  %d    SPEED  %.2fx" % [attack_damage, attack_speed]
	scrap_label.text = "SALVAGE SCRAP  %d" % scrap
	equipped_label.text = "EQUIPPED  %s" % String(equipped_item.get("name", "Unarmed"))
	loot_label.text = "WEAPON  %s" % String(equipped_item.get("name", "UNARMED"))
	if not equipped_item.is_empty():
		loot_label.text += "  |  DMG %d  |  SPEED %.2fx" % [equipped_item.get("damage", equipped_item.get("power", 0)), equipped_item.get("attack_speed", 1.0)]
	if _items.is_empty():
		_selected_equipment_index = 0
	else:
		_selected_equipment_index = clampi(_selected_equipment_index, 0, _items.size() - 1)
	_render_selected_equipment()
	_recover_equipment_focus()

func _render_selected_equipment() -> void:
	if _items.is_empty():
		item_name_label.text = "NO EQUIPMENT IN PACK"
		item_name_label.modulate = Color.WHITE
		comparison_label.text = "Defeat enemies to find equipment."
		affix_label.text = ""
		equipment_count_label.text = "0 / 0"
		equipment_previous_button.disabled = true
		equipment_next_button.disabled = true
		equip_button.disabled = true
		salvage_button.disabled = true
		favorite_button.disabled = true
	else:
		var item := _items[_selected_equipment_index]
		var rarity := String(item.get("rarity", "common"))
		var canonical_rarity := "magic" if rarity == "uncommon" else rarity
		var slot := String(item.get("slot", "weapon"))
		var current := _item_by_id(String(_equipped_slots.get(slot, "")))
		var damage_delta := int(item.get("damage", item.get("power", 0))) - int(current.get("damage", current.get("power", 0)))
		var speed_delta := float(item.get("attack_speed", 1.0)) - float(current.get("attack_speed", 1.0))
		item_name_label.text = "%s\nLEVEL %d  •  %s  •  %s%s" % [item.get("name", "Unknown"), item.get("item_level", 1), slot.to_upper(), rarity.to_upper(), "  •  FAVORITE" if bool(item.get("favorite", false)) else ""]
		item_name_label.modulate = Color(String(item.get("rarity_color", RarityRules.color(canonical_rarity))))
		comparison_label.text = "DMG %+d    SPEED %+.2fx    |    SALVAGE VALUE  %d" % [damage_delta, speed_delta, EquipmentInventory.salvage_value(item)]
		var tooltip_lines: Array[String] = []
		if slot == "weapon":
			tooltip_lines.append("BASE  %d damage  •  %.2fx attacks" % [item.get("damage", item.get("power", 0)), item.get("attack_speed", 1.0)])
		var base_stats := item.get("base_stats", {}) as Dictionary
		for stat_id: String in base_stats:
			tooltip_lines.append("BASE  %s" % _format_modifier(stat_id, "add", float(base_stats[stat_id])))
		for affix_value: Variant in item.get("affixes", []):
			if affix_value is Dictionary:
				var affix := affix_value as Dictionary
				tooltip_lines.append("%s  [%s]  %s" % [String(affix.get("name", affix.get("id", "AFFIX"))).to_upper(), String(affix.get("category", "")).to_upper(), _format_modifier(String(affix.get("stat", "")), String(affix.get("operation", "add")), float(affix.get("value", 0.0)))])
		var effect_ids: Array = item.get("legendary_effects", []) as Array
		if effect_ids.is_empty() and not String(item.get("legendary_affix_id", "")).is_empty():
			effect_ids = [String(item.legendary_affix_id)]
		for effect_value: Variant in effect_ids:
			var effect := LegendaryBehaviorRegistry.definition(String(effect_value))
			var effect_name := String(effect.get("name", item.get("legendary_affix_name", effect_value)))
			var effect_description := String(effect.get("description", item.get("legendary_affix_description", "Behavior-changing effect.")))
			tooltip_lines.append("LEGENDARY — %s: %s" % [effect_name.to_upper(), effect_description])
		affix_label.text = "\n".join(tooltip_lines)
		equipment_count_label.text = "%d / %d" % [_selected_equipment_index + 1, _items.size()]
		equipment_previous_button.disabled = _items.size() <= 1
		equipment_next_button.disabled = _items.size() <= 1
		var selected_equipped := String(item.get("id", "")) == String(_equipped_slots.get(slot, ""))
		equip_button.disabled = selected_equipped
		salvage_button.disabled = selected_equipped or bool(item.get("favorite", false))
		favorite_button.disabled = false
		favorite_button.text = "UNFAVORITE" if bool(item.get("favorite", false)) else "KEEP"
	unequip_button.disabled = _equipped_slots.is_empty()

func _item_by_id(item_id: String) -> Dictionary:
	for item: Dictionary in _items:
		if String(item.get("id", "")) == item_id:
			return item
	return {}

func _format_modifier(stat_id: String, operation: String, value: float) -> String:
	var label := stat_id.replace("_", " ").capitalize()
	if stat_id in ["damage_multiplier", "attack_speed", "critical_chance", "critical_damage", "gathering_power", "production_speed"]:
		return "%+.1f%% %s%s" % [value * 100.0, label, " (multiplicative)" if operation == "multiply" else ""]
	return "%+.1f %s%s" % [value, label, " (multiplicative)" if operation == "multiply" else ""]

func _toggle_selected_favorite() -> void:
	if _items.is_empty():
		return
	var favorite := not bool(_items[_selected_equipment_index].get("favorite", false))
	favorite_requested.emit(_selected_equipment_index, favorite)

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
	elif not favorite_button.disabled:
		favorite_button.grab_focus()
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

func refresh_workbench(wood: int, stone: int, moonleaf: int, scrap: int, heart_crafted: bool, whetstone_crafted: bool, herbal_compass_crafted: bool, tidecatcher_built: bool, feedback: String = "", plank: int = 0, building_states: Dictionary = {}, forest_unlocked: bool = false) -> void:
	_workbench_wood = wood
	_workbench_stone = stone
	_workbench_moonleaf = moonleaf
	_workbench_scrap = scrap
	_workbench_plank = plank
	_heart_crafted = heart_crafted
	_whetstone_crafted = whetstone_crafted
	_herbal_compass_crafted = herbal_compass_crafted
	_workbench_unlocks = {"reinforced_heart": heart_crafted, "forest_island": forest_unlocked}
	_workbench_crafted = {"reinforced_heart": heart_crafted, "runed_whetstone": whetstone_crafted, "herbal_compass": herbal_compass_crafted}
	for key: Variant in building_states:
		_workbench_crafted[String(key)] = bool(building_states[key])
	base_deposit_button.disabled = not bool(building_states.get("lumber_mill_built", false)) or wood <= 0
	base_deposit_button.text = "DEPOSIT ALL WOOD (%d)" % wood
	base_withdraw_button.disabled = not bool(building_states.get("lumber_mill_built", false)) or int(building_states.get("stored_planks", 0)) <= 0
	base_withdraw_button.text = "COLLECT PLANKS (%d)" % int(building_states.get("stored_planks", 0))
	_render_selected_recipe(feedback)
	if tidecatcher_built:
		tidecatcher_build_button.text = "TIDECATCHER BUILT"
		tidecatcher_build_button.disabled = true
	elif heart_crafted:
		tidecatcher_build_button.text = "BUILD TIDECATCHER — FREE"
		tidecatcher_build_button.disabled = false
	else:
		tidecatcher_build_button.text = "TIDECATCHER — REQUIRES HEART"
		tidecatcher_build_button.disabled = true
	_recover_workbench_focus()

func _render_selected_recipe(feedback: String = "") -> void:
	var recipes := RecipeRegistry.all()
	_selected_recipe_index = clampi(_selected_recipe_index, 0, recipes.size() - 1)
	var recipe: Dictionary = recipes[_selected_recipe_index]
	workbench_count_label.text = "%d / %d" % [_selected_recipe_index + 1, recipes.size()]
	workbench_recipe_label.text = String(recipe.name).to_upper()
	workbench_effect_label.text = String(recipe.effect_text)
	var resources := {"wood": _workbench_wood, "stone": _workbench_stone, "moonleaf": _workbench_moonleaf, "scrap": _workbench_scrap, "plank": _workbench_plank}
	var cost_parts: Array[String] = []
	for resource_value: Variant in recipe.inputs:
		var resource_id := String(resource_value)
		cost_parts.append("%d / %d %s" % [int(resources.get(resource_id, 0)), int(recipe.inputs[resource_value]), resource_id.to_upper()])
	recipe_cost_label.text = "COST  %s" % "    •    ".join(cost_parts)
	var result := CraftingService.new().evaluate(String(recipe.id), resources, _workbench_unlocks, _workbench_crafted)
	craft_button.text = "CRAFT %s" % String(recipe.name).to_upper()
	craft_button.disabled = not bool(result.get("success", false))
	if not feedback.is_empty():
		recipe_status_label.text = feedback
	elif bool(result.get("success", false)):
		recipe_status_label.text = "READY TO CRAFT"
	elif String(result.get("reason", "")) == "already_crafted":
		recipe_status_label.text = "ALREADY CRAFTED"
	elif String(result.get("reason", "")) == "locked":
		recipe_status_label.text = "LOCKED — REQUIRES %s" % String(result.get("requirement", "progress")).replace("_", " ").to_upper()
	else:
		var missing_parts: Array[String] = []
		for missing_id: Variant in (result.get("missing", {}) as Dictionary):
			missing_parts.append("%d %s" % [int(result.missing[missing_id]), String(missing_id).to_upper()])
		recipe_status_label.text = "MISSING %s" % ", ".join(missing_parts)

func _select_relative_recipe(offset: int) -> void:
	_selected_recipe_index = posmod(_selected_recipe_index + offset, RecipeRegistry.all().size())
	_render_selected_recipe()
	_recover_workbench_focus()

func get_selected_recipe_id() -> String:
	return String(RecipeRegistry.all()[_selected_recipe_index].id)

func get_recipe_cost_text() -> String:
	return recipe_cost_label.text

func _recover_workbench_focus() -> void:
	if not workbench_panel.visible:
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is Control and (focused as Control).is_visible_in_tree():
		if not focused is BaseButton or not (focused as BaseButton).disabled:
			return
	if not craft_button.disabled:
		craft_button.grab_focus()
	elif not tidecatcher_build_button.disabled:
		tidecatcher_build_button.grab_focus()
	else:
		workbench_next_button.grab_focus()

func open_workbench_panel() -> void:
	equipment_panel.visible = false
	workbench_panel.visible = true
	base_status_label.visible = false
	if not craft_button.disabled:
		craft_button.grab_focus()
	elif not tidecatcher_build_button.disabled:
		tidecatcher_build_button.grab_focus()
	else:
		workbench_next_button.grab_focus()

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

func focus_tidecatcher_build() -> void:
	if workbench_panel.visible and not tidecatcher_build_button.disabled:
		tidecatcher_build_button.grab_focus()

func refresh_upgrade_preview(item: Dictionary, scrap: int, moonleaf: int, feedback: String = "") -> void:
	_upgrade_confirmation_armed = false
	if item.is_empty():
		upgrade_preview_label.text = "UPGRADE STATION — EQUIP AN ITEM"
		upgrade_button.disabled = true
		upgrade_button.text = "UPGRADE EQUIPPED ITEM"
		return
	var plan := ItemUpgradeService.preview(item, {"scrap": scrap, "moonleaf": moonleaf})
	upgrade_button.disabled = not bool(plan.get("ok", false))
	upgrade_button.text = "UPGRADE %s" % String(item.get("name", "ITEM")).to_upper()
	if not feedback.is_empty():
		upgrade_preview_label.text = feedback
	elif String(plan.get("reason", "")) == "maximum_level":
		upgrade_preview_label.text = "%s  +10 MAX" % String(item.get("name", "ITEM")).to_upper()
	elif bool(plan.get("ok", false)):
		upgrade_preview_label.text = "+%d → +%d  •  POWER %d → %d  •  COST %d SCRAP%s" % [int(plan.from_level), int(plan.to_level), int(plan.power_before), int(plan.power_after), int(plan.cost.scrap), " + %d MOONLEAF" % int(plan.cost.moonleaf) if int(plan.cost.moonleaf) > 0 else ""]
	else:
		upgrade_preview_label.text = "UPGRADE BLOCKED — MISSING RESOURCES"

func _on_upgrade_pressed() -> void:
	if upgrade_button.disabled:
		return
	if not _upgrade_confirmation_armed:
		_upgrade_confirmation_armed = true
		upgrade_button.text = "CONFIRM UPGRADE — PRESS A AGAIN"
		upgrade_preview_label.text += "  •  CONFIRM?"
		return
	upgrade_requested.emit(true)

func is_upgrade_confirmation_armed() -> bool:
	return _upgrade_confirmation_armed

func show_placement(building_name: String, socket_name: String, rotation_degrees: int, valid: bool, reason: String) -> void:
	workbench_panel.visible = false
	base_status_label.visible = false
	placement_panel.visible = true
	placement_title_label.text = "PLACE %s" % building_name.to_upper()
	placement_state_label.text = "%s  •  %d°  •  %s" % [socket_name.to_upper(), rotation_degrees, "VALID — PRESS A" if valid else "INVALID — %s" % reason.replace("_", " ").to_upper()]
	placement_state_label.modulate = Color("75e6a5") if valid else Color("ff7181")
	placement_confirm_button.disabled = not valid
	if valid:
		placement_confirm_button.grab_focus()
	else:
		$PlacementPanel/Margin/VBox/Actions/Next.grab_focus()

func close_placement() -> void:
	placement_panel.visible = false

func is_placement_panel_open() -> bool:
	return placement_panel.visible

func set_base_status(active: bool, text_value: String) -> void:
	base_status_label.visible = active and not workbench_panel.visible and not placement_panel.visible and not system_panel.visible and not island_panel.visible and not equipment_panel.visible
	base_status_label.text = text_value

func get_base_status() -> String:
	return base_status_label.text

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

func refresh_islands(shards: Array[Dictionary], archipelago_data: Dictionary) -> void:
	_island_shards.clear()
	for shard: Dictionary in shards:
		_island_shards.append(shard.duplicate(true))
	_archipelago_data = archipelago_data.duplicate(true)
	_pending_island_action = ""
	if _island_shards.is_empty():
		_selected_island_index = 0
	else:
		_selected_island_index = clampi(_selected_island_index, 0, _island_shards.size() - 1)
	_render_selected_island()

func _render_selected_island() -> void:
	if _island_shards.is_empty():
		island_name_label.text = "NO ISLAND SHARDS"
		$IslandPanel/Margin/VBox/Biome.text = "Defeat enemies to discover world loot."
		$IslandPanel/Margin/VBox/Resources.text = "RESOURCES  —"
		$IslandPanel/Margin/VBox/Enemies.text = "ENEMIES  —"
		$IslandPanel/Margin/VBox/Positive.text = ""
		$IslandPanel/Margin/VBox/Negative.text = ""
		$IslandPanel/Margin/VBox/Encounter.text = "ENCOUNTER  —"
		$IslandPanel/Margin/VBox/Rewards.text = "EXPECTED REWARDS  —"
		island_count_label.text = "0 / 0"
		island_previous_button.disabled = true
		island_next_button.disabled = true
		island_install_button.disabled = true
	else:
		var shard := _island_shards[_selected_island_index]
		island_name_label.text = String(shard.get("name", "Unknown Shard")).to_upper()
		$IslandPanel/Margin/VBox/Biome.text = "BIOME  %s    •    LEVEL %d    •    %s    •    %s" % [String(shard.get("biome", "unknown")).to_upper(), int(shard.get("level", 1)), String(shard.get("size", "small")).to_upper(), String(shard.get("rarity", "common")).to_upper()]
		$IslandPanel/Margin/VBox/Resources.text = "RESOURCES  %s" % _join_preview(shard.get("resources", []))
		$IslandPanel/Margin/VBox/Enemies.text = "ENEMIES  %s" % _join_preview(shard.get("enemies", []))
		$IslandPanel/Margin/VBox/Positive.text = "POSITIVE  %s" % _modifier_names(shard.get("positive_modifiers", []))
		$IslandPanel/Margin/VBox/Negative.text = "RISKS  %s" % _modifier_names(shard.get("negative_modifiers", []))
		$IslandPanel/Margin/VBox/Encounter.text = "ENCOUNTER  %s" % String(shard.get("encounter", "None"))
		$IslandPanel/Margin/VBox/Rewards.text = "EXPECTED REWARDS  %s" % _join_preview(shard.get("expected_rewards", []))
		island_count_label.text = "%d / %d" % [_selected_island_index + 1, _island_shards.size()]
		island_previous_button.disabled = _island_shards.size() <= 1
		island_next_button.disabled = _island_shards.size() <= 1
		island_install_button.disabled = false
	_render_selected_island_slot()

func _render_selected_island_slot() -> void:
	var slot_id := get_selected_island_slot_id()
	island_slot_label.text = "SLOT  %s" % slot_id.replace("_", " ").to_upper()
	var slot_data := ((_archipelago_data.get("slots", {}) as Dictionary).get(slot_id, {}) as Dictionary)
	var installed := slot_data.get("installed_island", {}) as Dictionary
	island_remove_button.disabled = installed.is_empty()
	island_install_button.text = "REPLACE ISLAND" if not installed.is_empty() else "INSTALL IN FREE SLOT"
	island_status_label.text = "SLOT STATUS  %s" % ("FREE" if installed.is_empty() else String(installed.definition.name).to_upper())
	island_synergy_label.text = "ADJACENCY  None"
	if not _island_shards.is_empty():
		var model := ArchipelagoModel.from_dictionary(_archipelago_data)
		if model != null:
			var previews := model.preview_synergies(_island_shards[_selected_island_index], slot_id)
			if not previews.is_empty():
				var synergy := previews[0] as Dictionary
				island_synergy_label.text = "ADJACENCY  %s — + %s  /  PRICE: %s" % [String(synergy.name).to_upper(), String(synergy.benefit), String(synergy.price)]

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

func _select_relative_island_slot(offset: int) -> void:
	_selected_island_slot_index = posmod(_selected_island_slot_index + offset, ISLAND_SLOT_IDS.size())
	_pending_island_action = ""
	_render_selected_island_slot()

func get_selected_island_slot_id() -> String:
	return ISLAND_SLOT_IDS[_selected_island_slot_index]

func select_island_slot(slot_id: String) -> bool:
	var index := ISLAND_SLOT_IDS.find(slot_id)
	if index < 0:
		return false
	_selected_island_slot_index = index
	_pending_island_action = ""
	_render_selected_island_slot()
	return true

func get_island_preview_text() -> String:
	return "\n".join([$IslandPanel/Margin/VBox/Biome.text, $IslandPanel/Margin/VBox/Resources.text, $IslandPanel/Margin/VBox/Enemies.text, $IslandPanel/Margin/VBox/Positive.text, $IslandPanel/Margin/VBox/Negative.text, $IslandPanel/Margin/VBox/Encounter.text, $IslandPanel/Margin/VBox/Rewards.text, island_synergy_label.text])

func _request_selected_island_install() -> void:
	var slot_id := get_selected_island_slot_id()
	var installed := (((_archipelago_data.get("slots", {}) as Dictionary).get(slot_id, {}) as Dictionary).get("installed_island", {}) as Dictionary)
	var action_key := "replace:%d:%s" % [_selected_island_index, slot_id]
	if not installed.is_empty() and _pending_island_action != action_key:
		_pending_island_action = action_key
		island_status_label.text = "WARNING — REPLACING CLEARS ACTIVE ISLAND ENTITIES. PRESS REPLACE AGAIN."
		return
	_pending_island_action = ""
	island_install_requested.emit(_selected_island_index, slot_id)

func _request_selected_island_remove() -> void:
	var slot_id := get_selected_island_slot_id()
	var action_key := "remove:%s" % slot_id
	if _pending_island_action != action_key:
		_pending_island_action = action_key
		island_status_label.text = "WARNING — REMOVAL CLEARS ACTIVE ISLAND ENTITIES. PRESS REMOVE AGAIN."
		return
	_pending_island_action = ""
	island_remove_requested.emit(slot_id)

func _join_preview(values: Variant) -> String:
	var result: Array[String] = []
	if values is Array:
		for value: Variant in values:
			result.append(String(value).replace("_", " ").capitalize())
	return ", ".join(result) if not result.is_empty() else "None"

func _modifier_names(values: Variant) -> String:
	var names: Array[String] = []
	if values is Array:
		for value: Variant in values:
			var definition := IslandModifierRegistry.definition(String(value))
			names.append("%s: %s" % [String(definition.get("name", String(value).capitalize())), String(definition.get("description", ""))])
	return " | ".join(names) if not names.is_empty() else "None"

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
