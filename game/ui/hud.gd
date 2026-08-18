class_name GameHud
extends CanvasLayer

signal equipment_panel_requested
signal equipment_panel_closed
signal equip_requested(index: int)
signal salvage_requested(index: int)
signal favorite_requested(index: int, favorite: bool)
signal unequip_requested
signal technology_learn_requested(technology_id: String)
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
signal contract_accept_requested
signal contract_claim_requested
signal contract_decline_requested
signal contract_panel_closed
signal island_story_action_requested(action_id: String)
signal island_story_panel_closed

@onready var health_label: Label = $Margin/VBox/Health
@onready var health_bar: ProgressBar = $Margin/VBox/HealthBar
@onready var mana_bar: ProgressBar = $Margin/VBox/ManaBar
@onready var wood_label: Label = $Margin/VBox/Wood
@onready var stone_label: Label = $Margin/VBox/Stone
@onready var moonleaf_label: Label = $Margin/VBox/Moonleaf
@onready var plank_label: Label = $Margin/VBox/Plank
@onready var smelting_charge_label: Label = $Margin/VBox/SmeltingCharge
@onready var loot_label: Label = $Margin/VBox/Loot
@onready var attack_label: Label = $Margin/VBox/Attack
@onready var equipment_panel: PanelContainer = $EquipmentPanel
@onready var inventory_page: MarginContainer = $EquipmentPanel/Margin
@onready var stats_summary_label: Label = $EquipmentPanel/Margin/VBox/StatsSummary
@onready var item_name_label: Label = $EquipmentPanel/Margin/VBox/ItemIdentity/Details/ItemName
@onready var equipment_icon: TextureRect = $EquipmentPanel/Margin/VBox/ItemIdentity/Icon
@onready var equipment_slot_summary: Label = $EquipmentPanel/Margin/VBox/ItemIdentity/Details/SlotSummary
@onready var equipment_previous_button: Button = $EquipmentPanel/Margin/VBox/Selection/Previous
@onready var equipment_count_label: Label = $EquipmentPanel/Margin/VBox/Selection/Count
@onready var equipment_next_button: Button = $EquipmentPanel/Margin/VBox/Selection/Next
@onready var inventory_strip: HBoxContainer = $EquipmentPanel/Margin/VBox/InventoryStrip
@onready var comparison_label: Label = $EquipmentPanel/Margin/VBox/Comparison
@onready var equipment_tooltip_scroll: ScrollContainer = $EquipmentPanel/Margin/VBox/TooltipScroll
@onready var affix_label: Label = $EquipmentPanel/Margin/VBox/TooltipScroll/Affix
@onready var equipped_label: Label = $EquipmentPanel/Margin/VBox/Equipped
@onready var scrap_label: Label = $EquipmentPanel/Margin/VBox/Scrap
@onready var open_technology_button: Button = $EquipmentPanel/Margin/VBox/ProgressionActions/OpenTechnology
@onready var open_journey_button: Button = $EquipmentPanel/Margin/VBox/ProgressionActions/OpenJourney
@onready var technology_page: MarginContainer = $EquipmentPanel/TechnologyPage
@onready var technology_heading_label: Label = $EquipmentPanel/TechnologyPage/VBox/Heading
@onready var technology_tree_view: Variant = $EquipmentPanel/TechnologyPage/VBox/TreeGraph
@onready var technology_details_label: Label = $EquipmentPanel/TechnologyPage/VBox/Details
@onready var technology_previous_button: Button = $EquipmentPanel/TechnologyPage/VBox/Actions/Previous
@onready var technology_count_label: Label = $EquipmentPanel/TechnologyPage/VBox/Actions/Count
@onready var technology_next_button: Button = $EquipmentPanel/TechnologyPage/VBox/Actions/Next
@onready var technology_learn_button: Button = $EquipmentPanel/TechnologyPage/VBox/Actions/Learn
@onready var technology_back_button: Button = $EquipmentPanel/TechnologyPage/VBox/Actions/Back
@onready var journey_page: MarginContainer = $EquipmentPanel/JourneyPage
@onready var journey_heading_label: Label = $EquipmentPanel/JourneyPage/VBox/Heading
@onready var journey_details_label: Label = $EquipmentPanel/JourneyPage/VBox/Details
@onready var journey_previous_button: Button = $EquipmentPanel/JourneyPage/VBox/Actions/Previous
@onready var journey_count_label: Label = $EquipmentPanel/JourneyPage/VBox/Actions/Count
@onready var journey_next_button: Button = $EquipmentPanel/JourneyPage/VBox/Actions/Next
@onready var journey_back_button: Button = $EquipmentPanel/JourneyPage/VBox/Actions/Back
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
@onready var island_icon: TextureRect = $IslandPanel/Margin/VBox/ShardIcon
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
@onready var objective_label: Label = $Objective
@onready var expedition_status_label: Label = $ExpeditionStatus
@onready var contract_status_label: Label = $ContractStatus
@onready var island_story_status_label: Label = $IslandStoryStatus
@onready var contract_panel: PanelContainer = $ContractPanel
@onready var contract_title_label: Label = $ContractPanel/Margin/VBox/Title
@onready var contract_details_label: Label = $ContractPanel/Margin/VBox/Details
@onready var contract_reward_label: Label = $ContractPanel/Margin/VBox/Reward
@onready var contract_action_button: Button = $ContractPanel/Margin/VBox/Actions/Action
@onready var contract_close_button: Button = $ContractPanel/Margin/VBox/Actions/Close
@onready var island_story_panel: PanelContainer = $IslandStoryPanel
@onready var island_story_title_label: Label = $IslandStoryPanel/Margin/VBox/Title
@onready var island_story_details_label: Label = $IslandStoryPanel/Margin/VBox/Details
@onready var island_story_reward_label: Label = $IslandStoryPanel/Margin/VBox/Reward
@onready var island_story_action_a: Button = $IslandStoryPanel/Margin/VBox/Actions/ActionA
@onready var island_story_action_b: Button = $IslandStoryPanel/Margin/VBox/Actions/ActionB
@onready var island_story_action_c: Button = $IslandStoryPanel/Margin/VBox/Actions/ActionC
@onready var island_story_close_button: Button = $IslandStoryPanel/Margin/VBox/Close

var _items: Array[Dictionary] = []
var _equipped_id: String = ""
var _equipped_item: Dictionary = {}
var _equipped_slots: Dictionary = {}
var _selected_equipment_index: int = 0
var _displayed_attack_damage: int = 1
var _displayed_attack_speed: float = 1.0
var _displayed_scrap: int = 0
var _pending_salvage_id: String = ""
var _displayed_stone: int = 0
var _inventory_stats: Dictionary = {}
var _technology_entries: Array[Dictionary] = []
var _selected_technology_index: int = 0
var _learned_technology_count: int = 0
var _learned_technology_ids: Array[String] = []
var _technology_resources: Dictionary = {}
var _selected_recipe_index: int = 0
var _workbench_wood: int = 0
var _workbench_stone: int = 0
var _workbench_moonleaf: int = 0
var _workbench_scrap: int = 0
var _workbench_plank: int = 0
var _workbench_fiber: int = 0
var _workbench_emberberry: int = 0
var _ration_capacity: int = 0
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
var _journey_entries: Array[Dictionary] = []
var _selected_journey_index: int = 0
const ISLAND_SLOT_IDS: Array[String] = ["east", "north_east", "south_east"]

func _ready() -> void:
	equipment_previous_button.pressed.connect(func() -> void: _select_relative_equipment(-1))
	equipment_next_button.pressed.connect(func() -> void: _select_relative_equipment(1))
	equip_button.pressed.connect(func() -> void: equip_requested.emit(_selected_equipment_index))
	salvage_button.pressed.connect(_on_salvage_pressed)
	favorite_button.pressed.connect(_toggle_selected_favorite)
	unequip_button.pressed.connect(func() -> void: unequip_requested.emit())
	open_technology_button.pressed.connect(open_technology_page)
	open_journey_button.pressed.connect(open_journey_page)
	technology_previous_button.pressed.connect(func() -> void: _select_relative_technology(-1))
	technology_next_button.pressed.connect(func() -> void: _select_relative_technology(1))
	technology_learn_button.pressed.connect(_request_selected_technology)
	technology_back_button.pressed.connect(close_technology_page)
	journey_previous_button.pressed.connect(func() -> void: _select_relative_journey(-1))
	journey_next_button.pressed.connect(func() -> void: _select_relative_journey(1))
	journey_back_button.pressed.connect(close_journey_page)
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
	contract_action_button.pressed.connect(_on_contract_action_pressed)
	contract_close_button.pressed.connect(_on_contract_close_pressed)
	island_story_action_a.pressed.connect(func() -> void: island_story_action_requested.emit(String(island_story_action_a.get_meta("action_id", ""))))
	island_story_action_b.pressed.connect(func() -> void: island_story_action_requested.emit(String(island_story_action_b.get_meta("action_id", ""))))
	island_story_action_c.pressed.connect(func() -> void: island_story_action_requested.emit(String(island_story_action_c.get_meta("action_id", ""))))
	island_story_close_button.pressed.connect(close_island_story_panel)

func _unhandled_input(event: InputEvent) -> void:
	if island_story_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			close_island_story_panel()
			get_viewport().set_input_as_handled()
		return
	if contract_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			close_contract_panel()
			get_viewport().set_input_as_handled()
		return
	if journey_page.visible and event.is_action_pressed("ui_cancel"):
		close_journey_page()
		get_viewport().set_input_as_handled()
	elif technology_page.visible and event.is_action_pressed("ui_cancel"):
		close_technology_page()
		get_viewport().set_input_as_handled()
	elif equipment_panel.visible and not technology_page.visible and event.is_action_pressed("islands"):
		scroll_equipment_details(1)
		get_viewport().set_input_as_handled()
	elif equipment_panel.visible and not technology_page.visible and event.is_action_pressed("rift"):
		scroll_equipment_details(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause"):
		if system_panel.visible:
			close_system_menu()
		else:
			system_menu_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("equipment"):
		if equipment_panel.visible:
			close_equipment_panel()
		elif not workbench_panel.visible and not system_panel.visible and not island_panel.visible and not contract_panel.visible and not island_story_panel.visible:
			equipment_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("craft"):
		if workbench_panel.visible:
			close_workbench_panel()
		elif not equipment_panel.visible and not system_panel.visible and not island_panel.visible and not contract_panel.visible and not island_story_panel.visible:
			workbench_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("islands"):
		if island_panel.visible:
			close_island_panel()
		elif not equipment_panel.visible and not workbench_panel.visible and not system_panel.visible and not contract_panel.visible and not island_story_panel.visible:
			island_panel_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rift"):
		if not equipment_panel.visible and not workbench_panel.visible and not system_panel.visible and not island_panel.visible and not contract_panel.visible and not island_story_panel.visible:
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
	health_label.text = "HEALTH"
	health_bar.max_value = maxf(1.0, float(maximum))
	health_bar.value = float(current)
	_inventory_stats["health"] = current
	_inventory_stats["maximum_health"] = maximum
	_render_stats_summary()

func set_mana(current: float, maximum: float) -> void:
	mana_bar.max_value = maxf(1.0, maximum)
	mana_bar.value = current
	_inventory_stats["mana"] = current
	_inventory_stats["maximum_mana"] = maximum
	_render_stats_summary()

func set_wood(amount: int) -> void:
	wood_label.text = "WOOD    %d" % amount

func set_stone(amount: int) -> void:
	_displayed_stone = amount
	stone_label.text = "STONE   %d" % amount

func set_moonleaf(amount: int) -> void:
	moonleaf_label.text = "MOONLEAF  %d" % amount

func set_plank(amount: int) -> void:
	plank_label.text = "PLANKS  %d" % amount

func set_smelting_charge(amount: int) -> void:
	smelting_charge_label.text = "SMELT CHARGE  %d" % amount

func get_displayed_stone() -> int:
	return _displayed_stone

func set_interaction_prompt(label: String) -> void:
	interaction_prompt.visible = not label.is_empty()
	interaction_prompt.text = "[A]  %s" % label.to_upper() if not label.is_empty() else ""

func set_objective(text_value: String) -> void:
	objective_label.text = text_value

func set_expedition_status(text_value: String) -> void:
	expedition_status_label.text = text_value

func set_contract_status(text_value: String) -> void:
	contract_status_label.visible = not text_value.is_empty() and not contract_panel.visible and not island_story_panel.visible
	contract_status_label.text = text_value

func set_island_story_status(text_value: String) -> void:
	island_story_status_label.visible = not text_value.is_empty() and not island_story_panel.visible
	island_story_status_label.text = text_value

func present_contract(definition: Dictionary, status: String, progress: int) -> void:
	if definition.is_empty():
		contract_title_label.text = "NO CONTRACT AVAILABLE"
		contract_details_label.text = "Return when the expedition cycle changes."
		contract_reward_label.text = ""
		contract_action_button.visible = false
		return
	contract_title_label.text = "%s  •  %s %s" % [String(definition.title).to_upper(), String(definition.biome).to_upper(), String(definition.weather).to_upper()]
	contract_details_label.text = "%s\n\nPROGRESS  %d / %d" % [String(definition.instruction), progress, int(definition.target)]
	contract_reward_label.text = "REWARD  1 EXPEDITION MARK  •  SEEDED RARE GEAR  •  ISLAND SHARD"
	contract_action_button.visible = status in ["offered", "completed"]
	contract_action_button.text = "ACCEPT CONTRACT" if status == "offered" else "CLAIM LOOT"

func open_contract_panel(definition: Dictionary, status: String, progress: int) -> void:
	present_contract(definition, status, progress)
	encounter_label.visible = false
	rift_label.visible = false
	interaction_prompt.visible = false
	objective_label.visible = false
	contract_status_label.visible = false
	island_story_status_label.visible = false
	contract_panel.visible = true
	if contract_action_button.visible:
		contract_action_button.grab_focus()
	else:
		contract_close_button.grab_focus()

func close_contract_panel() -> void:
	contract_panel.visible = false
	objective_label.visible = true
	contract_status_label.visible = not contract_status_label.text.is_empty()
	island_story_status_label.visible = not island_story_status_label.text.is_empty()
	contract_panel_closed.emit()

func is_contract_panel_open() -> bool:
	return contract_panel.visible

func _on_contract_action_pressed() -> void:
	if contract_action_button.text.begins_with("CLAIM"):
		contract_claim_requested.emit()
	else:
		contract_accept_requested.emit()

func _on_contract_close_pressed() -> void:
	contract_decline_requested.emit()
	close_contract_panel()

func present_island_story(state: Dictionary, expedition_marks: int) -> void:
	var definition := state.get("definition", {}) as Dictionary
	var status := String(state.get("status", "locked"))
	var stage := int(state.get("stage", 0))
	var branch := String(state.get("branch", ""))
	var progress := int(state.get("progress", 0))
	var purchased := state.get("purchased_offer_ids", []) as Array
	for button: Button in [island_story_action_a, island_story_action_b, island_story_action_c]:
		button.visible = false
		button.disabled = false
		button.set_meta("action_id", "")
	if definition.is_empty():
		island_story_title_label.text = "NO INSTALLED ISLAND"
		island_story_details_label.text = "Install an island shard to reveal Tala's story."
		island_story_reward_label.text = ""
		return
	island_story_title_label.text = "%s  •  %s  LV.%d" % [String(definition.title).to_upper(), String(definition.biome).to_upper(), int(definition.level)]
	match status:
		"offered":
			island_story_details_label.text = "The shard is repeating a broken memory. Survey two echoes before deciding what this island should become."
			island_story_reward_label.text = "RESTORE  →  2 MARKS + HIGHER-LEVEL SHARD\nPURGE  →  2 MARKS + EPIC EQUIPMENT"
			_configure_story_action(island_story_action_a, "accept", "BEGIN SURVEY")
		"active":
			if stage == 0:
				island_story_details_label.text = "ATTUNE TWO %s SITES\n\nPROGRESS  %d / 2" % [String(definition.survey_event).replace("_", " ").to_upper(), progress]
				island_story_reward_label.text = "Follow the floating shard sigils on the installed island."
			elif stage == 1 and branch.is_empty():
				island_story_details_label.text = "RESTORE binds the island safely and yields a stronger shard.\nPURGE converts its instability into immediate epic equipment."
				island_story_reward_label.text = "THIS CHOICE CHANGES THE FINAL LOOT."
				_configure_story_action(island_story_action_a, "restoration", "RESTORE ISLAND")
				_configure_story_action(island_story_action_b, "purge", "PURGE CORRUPTION")
			elif stage == 1:
				var event_name := String(definition.restoration_event if branch == "restoration" else definition.purge_event).replace("_", " ").to_upper()
				island_story_details_label.text = "%s TWO %s SITES\n\nPROGRESS  %d / 2" % ["RESTORE" if branch == "restoration" else "SEVER", event_name, progress]
				island_story_reward_label.text = "The Warden will emerge when both sites are resolved."
			else:
				island_story_details_label.text = "DEFEAT %s\n\nPROGRESS  %d / 1" % [String(definition.warden_name).to_upper(), progress]
				island_story_reward_label.text = "Its attacks are telegraphed; use the island's open combat pocket."
		"completed":
			island_story_details_label.text = "%s has fallen. Tala can now stabilize the result of your choice." % String(definition.warden_name)
			island_story_reward_label.text = "CLAIM  2 EXPEDITION MARKS + %s" % ("HIGHER-LEVEL ISLAND SHARD" if branch == "restoration" else "EPIC EQUIPMENT")
			_configure_story_action(island_story_action_a, "claim", "CLAIM STORY REWARD")
		"claimed":
			island_story_details_label.text = "TALA'S EXPEDITION MARK EXCHANGE\nMARKS AVAILABLE  %d" % expedition_marks
			island_story_reward_label.text = "Purchased offers are permanent for this island story. Rewards appear as ordinary world loot."
			_configure_story_action(island_story_action_a, "buy:wayfinder_cache", "RARE GEAR  •  1 MARK", "wayfinder_cache" in purchased)
			_configure_story_action(island_story_action_b, "buy:focused_shard", "FOCUSED SHARD  •  2 MARKS", "focused_shard" in purchased)
			_configure_story_action(island_story_action_c, "buy:field_supplies", "3 MOONLEAF  •  1 MARK", "field_supplies" in purchased)

func _configure_story_action(button: Button, action_id: String, label: String, purchased: bool = false) -> void:
	button.visible = true
	button.disabled = purchased
	button.text = "PURCHASED" if purchased else label
	button.set_meta("action_id", action_id)

func open_island_story_panel(state: Dictionary, expedition_marks: int) -> void:
	present_island_story(state, expedition_marks)
	encounter_label.visible = false
	rift_label.visible = false
	interaction_prompt.visible = false
	objective_label.visible = false
	contract_status_label.visible = false
	island_story_status_label.visible = false
	island_story_panel.visible = true
	recover_island_story_focus()

func recover_island_story_focus() -> void:
	for button: Button in [island_story_action_a, island_story_action_b, island_story_action_c]:
		if button.visible and not button.disabled:
			button.grab_focus()
			return
	island_story_close_button.grab_focus()

func close_island_story_panel() -> void:
	island_story_panel.visible = false
	objective_label.visible = true
	contract_status_label.visible = not contract_status_label.text.is_empty()
	island_story_status_label.visible = not island_story_status_label.text.is_empty()
	island_story_panel_closed.emit()

func is_island_story_panel_open() -> bool:
	return island_story_panel.visible

func get_interaction_prompt() -> String:
	return interaction_prompt.text if interaction_prompt.visible else ""

func get_displayed_attack_speed() -> float:
	return _displayed_attack_speed

func set_loot(item: Dictionary) -> void:
	loot_label.text = "FOUND  %s  |  DMG %d  |  SPEED %.2fx" % [item.get("name", "None"), item.get("damage", item.get("power", 0)), item.get("attack_speed", 1.0)]

func refresh_inventory_stats(stats: Dictionary) -> void:
	_inventory_stats.merge(stats, true)
	_render_stats_summary()

func _render_stats_summary() -> void:
	if not is_instance_valid(stats_summary_label):
		return
	stats_summary_label.text = "MATERIALS  WOOD %d  •  STONE %d  •  MOONLEAF %d  •  PLANK %d  •  SCRAP %d\nSURVIVAL  FIBER %d  •  BERRIES %d  •  RATIONS %d/3  •  PREPARED %d  •  MARKS %d\nVITALS  HEALTH %d/%d  •  MANA %.0f/%.0f  •  REGEN %.1f/s\nCOMBAT  ATTACK %d  •  SPEED %.2fx  •  CRIT %.0f%%\nUTILITY  GATHER %.2f  •  PICKUP %.0f  •  PRODUCTION %.2fx" % [
		int(_inventory_stats.get("wood", 0)), int(_inventory_stats.get("stone", 0)), int(_inventory_stats.get("moonleaf", 0)), int(_inventory_stats.get("plank", 0)), int(_inventory_stats.get("scrap", _displayed_scrap)),
		int(_inventory_stats.get("fiber", 0)), int(_inventory_stats.get("emberberry", 0)), int(_inventory_stats.get("rations", 0)), int(_inventory_stats.get("prepared_harvests", 0)), int(_inventory_stats.get("expedition_marks", 0)),
		int(_inventory_stats.get("health", 0)), int(_inventory_stats.get("maximum_health", 0)), float(_inventory_stats.get("mana", 0.0)), float(_inventory_stats.get("maximum_mana", 0.0)), float(_inventory_stats.get("mana_regeneration", 0.0)),
		int(_inventory_stats.get("attack_damage", _displayed_attack_damage)), float(_inventory_stats.get("attack_speed", _displayed_attack_speed)), float(_inventory_stats.get("critical_chance", 0.0)) * 100.0,
		float(_inventory_stats.get("gathering_power", 1.0)), float(_inventory_stats.get("pickup_radius", 0.0)), float(_inventory_stats.get("production_speed", 1.0)),
	]

func refresh_journey(entries: Array[Dictionary]) -> void:
	var selected_id := ""
	if not _journey_entries.is_empty() and _selected_journey_index < _journey_entries.size():
		selected_id = String(_journey_entries[_selected_journey_index].get("id", ""))
	_journey_entries.clear()
	for value: Dictionary in entries:
		_journey_entries.append(value.duplicate(true))
	if not selected_id.is_empty():
		for index: int in _journey_entries.size():
			if String(_journey_entries[index].id) == selected_id:
				_selected_journey_index = index
				break
	_selected_journey_index = clampi(_selected_journey_index, 0, maxi(0, _journey_entries.size() - 1))
	_render_selected_journey()

func _select_relative_journey(offset: int) -> void:
	if _journey_entries.is_empty():
		return
	_selected_journey_index = posmod(_selected_journey_index + offset, _journey_entries.size())
	_render_selected_journey()

func _render_selected_journey() -> void:
	if _journey_entries.is_empty():
		journey_heading_label.text = "JOURNEY JOURNAL — NO ACTIVE ROUTE"
		journey_details_label.text = "Explore the archipelago to reveal new milestones."
		journey_count_label.text = "0 / 0"
		journey_previous_button.disabled = true
		journey_next_button.disabled = true
		return
	var selected := _journey_entries[_selected_journey_index]
	var completed_count := _journey_entries.filter(func(value: Dictionary) -> bool: return bool(value.completed)).size()
	journey_heading_label.text = "FIRST-HOUR JOURNEY  •  %d / %d COMPLETE" % [completed_count, _journey_entries.size()]
	var reward_parts: Array[String] = []
	for reward_value: Variant in (selected.reward as Dictionary):
		reward_parts.append("%d %s" % [int(selected.reward[reward_value]), String(reward_value).replace("_", " ").to_upper()])
	journey_details_label.text = "%s  •  %s\n%s\nPROGRESS  %d / %d\nREWARD  %s" % [
		String(selected.name).to_upper(), "COMPLETE" if bool(selected.completed) else "ACTIVE", String(selected.description), int(selected.progress), int(selected.target), " • ".join(reward_parts),
	]
	journey_count_label.text = "%d / %d" % [_selected_journey_index + 1, _journey_entries.size()]
	journey_previous_button.disabled = _journey_entries.size() <= 1
	journey_next_button.disabled = _journey_entries.size() <= 1

func refresh_technologies(entries: Array[Dictionary], learned_ids: Array[String], phase_name: String, resources: Dictionary) -> void:
	var selected_id := ""
	if not _technology_entries.is_empty() and _selected_technology_index < _technology_entries.size():
		selected_id = String(_technology_entries[_selected_technology_index].get("id", ""))
	var selected_was_just_learned := not selected_id.is_empty() and selected_id not in _learned_technology_ids and selected_id in learned_ids
	_technology_entries.clear()
	for entry: Dictionary in entries:
		_technology_entries.append(entry.duplicate(true))
	_learned_technology_ids = learned_ids.duplicate()
	_learned_technology_count = learned_ids.size()
	_technology_resources = resources.duplicate(true)
	_selected_technology_index = clampi(_selected_technology_index, 0, maxi(0, _technology_entries.size() - 1))
	if selected_was_just_learned:
		_select_first_ready_technology()
	technology_heading_label.text = "TECHNOLOGY TREE  •  %s  •  %d / %d LEARNED" % [phase_name.to_upper(), learned_ids.size(), _technology_entries.size()]
	_render_selected_technology()

func _select_relative_technology(offset: int) -> void:
	if _technology_entries.is_empty():
		return
	_selected_technology_index = posmod(_selected_technology_index + offset, _technology_entries.size())
	_render_selected_technology()

func _render_selected_technology() -> void:
	if _technology_entries.is_empty():
		technology_details_label.text = "NO TECHNOLOGIES AUTHORED\nExplore shards and build the archipelago to reveal future disciplines."
		technology_count_label.text = "0 / 0"
		technology_previous_button.disabled = true
		technology_next_button.disabled = true
		technology_learn_button.disabled = true
		technology_learn_button.text = "NO TECHNOLOGY"
		technology_tree_view.configure([], _learned_technology_ids, "", _technology_resources)
		return
	var entry := _technology_entries[_selected_technology_index]
	var cost: Dictionary = entry.get("cost", {}) as Dictionary
	var cost_parts: Array[String] = []
	for resource_value: Variant in cost:
		var resource_id := String(resource_value)
		var amount := int(cost[resource_value])
		cost_parts.append("%d %s" % [amount, resource_id.to_upper()])
	var prerequisite_parts: Array[String] = []
	for prerequisite_value: Variant in entry.get("prerequisites", []):
		var prerequisite := _technology_definition(String(prerequisite_value))
		prerequisite_parts.append(String(prerequisite.get("name", prerequisite_value)).to_upper())
	var recipe_parts: Array[String] = []
	for recipe_value: Variant in entry.get("unlocks_recipes", []):
		var recipe := RecipeRegistry.get_definition(String(recipe_value))
		recipe_parts.append(String(recipe.get("name", recipe_value)).to_upper())
	var state := _technology_state(entry)
	technology_details_label.text = "%s  •  TIER %d  •  %s\n%s\nREQUIRES  %s   •   COST  %s\nUNLOCKS RECIPES  %s" % [
		String(entry.get("name", "Technology")).to_upper(), int(entry.get("column", 0)) + 1, state.to_upper(), String(entry.get("effect", "")),
		"ROOT DISCIPLINE" if prerequisite_parts.is_empty() else " + ".join(prerequisite_parts), " + ".join(cost_parts),
		"NO RECIPE" if recipe_parts.is_empty() else " • ".join(recipe_parts),
	]
	technology_count_label.text = "%d / %d" % [_selected_technology_index + 1, _technology_entries.size()]
	technology_previous_button.disabled = _technology_entries.size() <= 1
	technology_next_button.disabled = _technology_entries.size() <= 1
	technology_learn_button.disabled = state != "ready"
	match state:
		"learned": technology_learn_button.text = "LEARNED"
		"locked": technology_learn_button.text = "LOCKED BY PREREQUISITE"
		"gather": technology_learn_button.text = "GATHER RESOURCES"
		_: technology_learn_button.text = "LEARN TECHNOLOGY"
	technology_tree_view.configure(_technology_entries, _learned_technology_ids, String(entry.get("id", "")), _technology_resources)

func _technology_state(entry: Dictionary) -> String:
	var technology_id := String(entry.get("id", ""))
	if technology_id in _learned_technology_ids:
		return "learned"
	for prerequisite_value: Variant in entry.get("prerequisites", []):
		if String(prerequisite_value) not in _learned_technology_ids:
			return "locked"
	for resource_value: Variant in entry.get("cost", {}):
		if int(_technology_resources.get(String(resource_value), 0)) < int(entry.cost[resource_value]):
			return "gather"
	return "ready"

func _technology_definition(technology_id: String) -> Dictionary:
	for entry: Dictionary in _technology_entries:
		if String(entry.get("id", "")) == technology_id:
			return entry
	return {}

func _select_first_ready_technology() -> void:
	for index: int in _technology_entries.size():
		if _technology_state(_technology_entries[index]) == "ready":
			_selected_technology_index = index
			return

func _request_selected_technology() -> void:
	if _technology_entries.is_empty() or technology_learn_button.disabled:
		return
	technology_learn_requested.emit(String(_technology_entries[_selected_technology_index].get("id", "")))

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
	_inventory_stats["scrap"] = scrap
	_inventory_stats["attack_damage"] = attack_damage
	_inventory_stats["attack_speed"] = attack_speed
	_render_stats_summary()
	attack_label.text = "ATTACK  %d    SPEED  %.2fx" % [attack_damage, attack_speed]
	scrap_label.text = "SALVAGE SCRAP  %d" % scrap
	equipped_label.text = "EQUIPPED  %s" % String(equipped_item.get("name", "Unarmed"))
	loot_label.text = "WEAPON  %s" % String(equipped_item.get("name", "UNARMED"))
	if not equipped_item.is_empty():
		var weapon_type := String(equipped_item.get("base_type", equipped_item.get("archetype", "weapon"))).to_upper()
		loot_label.text = "%s  •  %s" % [weapon_type, String(equipped_item.get("name", "WEAPON"))]
	if _items.is_empty():
		equipment_icon.texture = ItemIconLibrary.texture("empty")
		equipment_slot_summary.text = "PACK SLOT  •  EMPTY"
		_selected_equipment_index = 0
		_pending_salvage_id = ""
	else:
		_selected_equipment_index = clampi(_selected_equipment_index, 0, _items.size() - 1)
		if not _items.any(func(item: Dictionary) -> bool: return String(item.get("id", "")) == _pending_salvage_id):
			_pending_salvage_id = ""
	_render_selected_equipment()
	_recover_equipment_focus()

func _render_selected_equipment() -> void:
	_render_inventory_strip()
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
		salvage_button.text = "SALVAGE"
		favorite_button.disabled = true
	else:
		var item := _items[_selected_equipment_index]
		var icon_id := ItemIconLibrary.icon_id_for_item(item)
		equipment_icon.texture = ItemIconLibrary.texture(icon_id)
		var presentation := ItemTooltipPresenter.present(item)
		var rarity := String(item.get("rarity", "common"))
		var slot := String(item.get("slot", "weapon"))
		equipment_slot_summary.text = "%s SLOT  •  %s ICON  •  %s" % [slot.to_upper(), icon_id.replace("_", " ").to_upper(), rarity.to_upper()]
		var current := _item_by_id(String(_equipped_slots.get(slot, "")))
		var comparison := ItemTooltipPresenter.compare(item, current)
		item_name_label.text = "%s  •  LEVEL %d%s" % [presentation.name, presentation.level, "  •  FAVORITE" if bool(presentation.favorite) else ""]
		item_name_label.modulate = Color(String(presentation.rarity_color))
		var visible_deltas := (comparison.deltas as Array).slice(0, 3)
		var delta_text := "    ".join(visible_deltas)
		var decision := _decision_summary(comparison.deltas as Array)
		comparison_label.text = "DECISION  %s\nCANDIDATE  %s  |  EQUIPPED  %s\n%s\nSALVAGE VALUE  %d" % [decision, comparison.candidate_name, comparison.equipped_name, delta_text if not delta_text.is_empty() else "NO NUMERIC CHANGE", EquipmentInventory.salvage_value(item)]
		var tooltip_lines: Array[String] = ["CANDIDATE"]
		tooltip_lines.append_array(presentation.base_lines as Array)
		tooltip_lines.append_array(presentation.affix_lines as Array)
		tooltip_lines.append_array(presentation.legendary_lines as Array)
		tooltip_lines.append("EQUIPPED — %s" % String(comparison.equipped_name))
		tooltip_lines.append_array(comparison.equipped_affixes as Array)
		tooltip_lines.append_array(comparison.equipped_behaviors as Array)
		affix_label.text = "\n".join(tooltip_lines)
		equipment_count_label.text = "%d / %d" % [_selected_equipment_index + 1, _items.size()]
		equipment_previous_button.disabled = _items.size() <= 1
		equipment_next_button.disabled = _items.size() <= 1
		var selected_equipped := String(item.get("id", "")) == String(_equipped_slots.get(slot, ""))
		equip_button.disabled = selected_equipped
		salvage_button.disabled = selected_equipped or bool(item.get("favorite", false))
		salvage_button.text = "> CONFIRM DESTROY +%d" % EquipmentInventory.salvage_value(item) if _pending_salvage_id == String(item.get("id", "")) else "SALVAGE"
		if _pending_salvage_id == String(item.get("id", "")):
			comparison_label.text += "\nWARNING — PRESS CONFIRM TO DESTROY THIS ITEM"
		favorite_button.disabled = false
		favorite_button.text = "UNFAVORITE" if bool(item.get("favorite", false)) else "KEEP"
	unequip_button.disabled = _equipped_slots.is_empty()

func _render_inventory_strip() -> void:
	for child: Node in inventory_strip.get_children():
		inventory_strip.remove_child(child)
		child.queue_free()
	for index: int in 6:
		var frame := PanelContainer.new()
		frame.custom_minimum_size = Vector2(52, 52)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("101c24")
		style.border_color = Color("f5df9b") if index == _selected_equipment_index and index < _items.size() else Color("315e66")
		style.set_border_width_all(4 if index == _selected_equipment_index and index < _items.size() else 2)
		style.set_corner_radius_all(5)
		frame.add_theme_stylebox_override("panel", style)
		var icon := TextureRect.new()
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = ItemIconLibrary.texture(ItemIconLibrary.icon_id_for_item(_items[index])) if index < _items.size() else ItemIconLibrary.texture("empty")
		icon.custom_minimum_size = Vector2(44, 44)
		frame.add_child(icon)
		inventory_strip.add_child(frame)

func _decision_summary(deltas: Array) -> String:
	var gain := "NEW PLAYSTYLE"
	var cost := "NONE"
	for value: Variant in deltas:
		var text_value := String(value)
		if "-" in text_value and cost == "NONE":
			cost = text_value
		elif "+" in text_value and gain == "NEW PLAYSTYLE":
			gain = text_value
	return "GAIN %s  •  COST %s" % [gain, cost]

func get_displayed_icon_id() -> String:
	if _items.is_empty():
		return "empty"
	return ItemIconLibrary.icon_id_for_item(_items[_selected_equipment_index])

func _item_by_id(item_id: String) -> Dictionary:
	for item: Dictionary in _items:
		if String(item.get("id", "")) == item_id:
			return item
	return {}

func _format_modifier(stat_id: String, operation: String, value: float) -> String:
	return ItemTooltipPresenter.format_modifier(stat_id, operation, value)

func _on_salvage_pressed() -> void:
	if _items.is_empty() or salvage_button.disabled:
		return
	var item_id := String(_items[_selected_equipment_index].get("id", ""))
	if _pending_salvage_id == item_id:
		_pending_salvage_id = ""
		salvage_requested.emit(_selected_equipment_index)
		return
	_pending_salvage_id = item_id
	_render_selected_equipment()
	salvage_button.grab_focus()

func _toggle_selected_favorite() -> void:
	if _items.is_empty():
		return
	var favorite := not bool(_items[_selected_equipment_index].get("favorite", false))
	favorite_requested.emit(_selected_equipment_index, favorite)

func select_equipment(index: int) -> bool:
	if index < 0 or index >= _items.size():
		return false
	if index != _selected_equipment_index:
		_pending_salvage_id = ""
	_selected_equipment_index = index
	equipment_tooltip_scroll.scroll_vertical = 0
	_render_selected_equipment()
	_recover_equipment_focus()
	return true

func scroll_equipment_details(direction: int) -> void:
	equipment_tooltip_scroll.scroll_vertical += direction * 96

func _select_relative_equipment(offset: int) -> void:
	if _items.is_empty():
		return
	select_equipment(posmod(_selected_equipment_index + offset, _items.size()))

func _recover_equipment_focus() -> void:
	if not equipment_panel.visible:
		return
	if technology_page.visible:
		if not technology_learn_button.disabled:
			technology_learn_button.grab_focus()
		else:
			technology_next_button.grab_focus()
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
	encounter_label.visible = false
	rift_label.visible = false
	interaction_prompt.visible = false
	objective_label.visible = false
	equipment_panel.visible = true
	inventory_page.visible = true
	technology_page.visible = false
	journey_page.visible = false
	if not equip_button.disabled:
		equip_button.grab_focus()
	elif not unequip_button.disabled:
		unequip_button.grab_focus()
	else:
		$EquipmentPanel/Margin/VBox/Close.grab_focus()

func close_equipment_panel() -> void:
	_pending_salvage_id = ""
	inventory_page.visible = true
	technology_page.visible = false
	journey_page.visible = false
	equipment_panel.visible = false
	objective_label.visible = true
	encounter_label.visible = not encounter_label.text.is_empty()
	rift_label.visible = not rift_label.text.is_empty()
	equipment_panel_closed.emit()

func is_equipment_panel_open() -> bool:
	return equipment_panel.visible

func open_technology_page() -> void:
	if not equipment_panel.visible:
		return
	inventory_page.visible = false
	journey_page.visible = false
	technology_page.visible = true
	_render_selected_technology()
	_recover_equipment_focus()

func close_technology_page() -> void:
	technology_page.visible = false
	inventory_page.visible = true
	open_technology_button.grab_focus()

func is_technology_page_open() -> bool:
	return equipment_panel.visible and technology_page.visible

func open_journey_page() -> void:
	if not equipment_panel.visible:
		return
	inventory_page.visible = false
	technology_page.visible = false
	journey_page.visible = true
	_render_selected_journey()
	journey_back_button.grab_focus()

func close_journey_page() -> void:
	journey_page.visible = false
	inventory_page.visible = true
	open_journey_button.grab_focus()

func is_journey_page_open() -> bool:
	return equipment_panel.visible and journey_page.visible

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

func is_salvage_confirmation_armed() -> bool:
	return not _pending_salvage_id.is_empty()

func refresh_workbench(wood: int, stone: int, moonleaf: int, scrap: int, heart_crafted: bool, whetstone_crafted: bool, herbal_compass_crafted: bool, tidecatcher_built: bool, feedback: String = "", plank: int = 0, building_states: Dictionary = {}, forest_unlocked: bool = false, additional_unlocks: Dictionary = {}, survival_resources: Dictionary = {}) -> void:
	_workbench_wood = wood
	_workbench_stone = stone
	_workbench_moonleaf = moonleaf
	_workbench_scrap = scrap
	_workbench_plank = plank
	_workbench_fiber = int(survival_resources.get("fiber", 0))
	_workbench_emberberry = int(survival_resources.get("emberberry", 0))
	_ration_capacity = int(survival_resources.get("ration_capacity", 0))
	_heart_crafted = heart_crafted
	_whetstone_crafted = whetstone_crafted
	_herbal_compass_crafted = herbal_compass_crafted
	_workbench_unlocks = {"reinforced_heart": heart_crafted, "forest_island": forest_unlocked}
	_workbench_unlocks.merge(additional_unlocks, true)
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
	var resources := {"wood": _workbench_wood, "stone": _workbench_stone, "moonleaf": _workbench_moonleaf, "scrap": _workbench_scrap, "plank": _workbench_plank, "fiber": _workbench_fiber, "emberberry": _workbench_emberberry}
	var cost_parts: Array[String] = []
	for resource_value: Variant in recipe.inputs:
		var resource_id := String(resource_value)
		cost_parts.append("%d / %d %s" % [int(resources.get(resource_id, 0)), int(recipe.inputs[resource_value]), resource_id.to_upper()])
	recipe_cost_label.text = "COST  %s" % "    •    ".join(cost_parts)
	var output_capacity := _ration_capacity if String(recipe.id) == "trail_ration" else 1
	var result := CraftingService.new().evaluate(String(recipe.id), resources, _workbench_unlocks, _workbench_crafted, output_capacity)
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
	encounter_label.visible = false
	rift_label.visible = false
	interaction_prompt.visible = false
	objective_label.visible = false
	if not craft_button.disabled:
		craft_button.grab_focus()
	elif not tidecatcher_build_button.disabled:
		tidecatcher_build_button.grab_focus()
	else:
		workbench_next_button.grab_focus()

func close_workbench_panel() -> void:
	workbench_panel.visible = false
	objective_label.visible = true
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
	encounter_label.visible = false
	rift_label.visible = false
	interaction_prompt.visible = false
	objective_label.visible = false
	island_panel.visible = false
	system_panel.visible = true
	save_button.grab_focus()

func close_system_menu() -> void:
	system_panel.visible = false
	objective_label.visible = true
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
		island_icon.texture = ItemIconLibrary.texture("empty")
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
		island_icon.texture = ItemIconLibrary.texture("island_shard")
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
	encounter_label.visible = false
	rift_label.visible = false
	interaction_prompt.visible = false
	objective_label.visible = false
	island_panel.visible = true
	if not island_install_button.disabled:
		island_install_button.grab_focus()
	elif not island_remove_button.disabled:
		island_remove_button.grab_focus()
	else:
		$IslandPanel/Margin/VBox/Close.grab_focus()

func close_island_panel() -> void:
	island_panel.visible = false
	objective_label.visible = true
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
