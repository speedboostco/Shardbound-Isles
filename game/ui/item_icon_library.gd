class_name ItemIconLibrary
extends RefCounted

const ATLAS_PATH: String = "res://assets/original/emberwood/emberwood_item_icons_v3.png"
const ATLAS: Texture2D = preload(ATLAS_PATH)
const CELL_SIZE: int = 64
const FALLBACK_ID: String = "fallback"
const CELLS: Dictionary = {
	"sword": Vector2i(0, 0), "bow": Vector2i(1, 0), "wand": Vector2i(2, 0), "axe": Vector2i(3, 0),
	"pickaxe": Vector2i(4, 0), "spear": Vector2i(5, 0), "shield": Vector2i(6, 0), "quiver": Vector2i(7, 0),
	"helmet": Vector2i(0, 1), "body": Vector2i(1, 1), "boots": Vector2i(2, 1), "ring": Vector2i(3, 1),
	"amulet": Vector2i(4, 1), "gloves": Vector2i(5, 1), "belt": Vector2i(6, 1), "cloak": Vector2i(7, 1),
	"wood": Vector2i(0, 2), "stone": Vector2i(1, 2), "moonleaf": Vector2i(2, 2), "plank": Vector2i(3, 2),
	"scrap": Vector2i(4, 2), "iron_ore": Vector2i(5, 2), "rare_spores": Vector2i(6, 2), "obsidian": Vector2i(7, 2),
	"ordinary_sword": Vector2i(0, 3), "magic_sword": Vector2i(1, 3), "rare_sword": Vector2i(2, 3), "epic_sword": Vector2i(3, 3),
	"legendary_sword": Vector2i(4, 3), "common_bow": Vector2i(5, 3), "magic_bow": Vector2i(6, 3), "living_bow": Vector2i(7, 3),
	"chain_mining": Vector2i(0, 4), "burning_smelter": Vector2i(1, 4), "living_arrows": Vector2i(2, 4), "riftwake_pulse": Vector2i(3, 4),
	"herbal_compass": Vector2i(4, 4), "runed_whetstone": Vector2i(5, 4), "reinforced_heart": Vector2i(6, 4), "island_shard": Vector2i(7, 4),
	"forest_shard": Vector2i(0, 5), "swamp_shard": Vector2i(1, 5), "volcanic_shard": Vector2i(2, 5), "frozen_shard": Vector2i(3, 5),
	"graveyard_shard": Vector2i(4, 5), "settlement_shard": Vector2i(5, 5), "arcane_shard": Vector2i(6, 5), "unknown_shard": Vector2i(7, 5),
	"workbench_kit": Vector2i(0, 6), "collector_kit": Vector2i(1, 6), "storage_kit": Vector2i(2, 6), "lumber_mill_kit": Vector2i(3, 6),
	"tidecatcher_kit": Vector2i(4, 6), "reward_chest": Vector2i(5, 6), "favorite": Vector2i(6, 6), "locked": Vector2i(7, 6),
	"empty": Vector2i(0, 7), FALLBACK_ID: Vector2i(1, 7), "health": Vector2i(2, 7), "attack": Vector2i(3, 7),
	"speed": Vector2i(4, 7), "critical": Vector2i(5, 7), "pickup": Vector2i(6, 7), "gathering": Vector2i(7, 7),
}

static func resolved_id(icon_id: String) -> String:
	return icon_id if CELLS.has(icon_id) else FALLBACK_ID

static func texture(icon_id: String) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = ATLAS
	var cell: Vector2i = CELLS[resolved_id(icon_id)]
	result.region = Rect2(Vector2(cell * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
	result.filter_clip = true
	return result

static func icon_id_for_item(item: Dictionary) -> String:
	var explicit := String(item.get("icon_id", ""))
	if not explicit.is_empty():
		return resolved_id(explicit)
	var definition := ItemBaseRegistry.get_definition(String(item.get("definition_id", "")))
	if not definition.is_empty():
		return resolved_id(String(definition.get("icon_id", "")))
	var base_type := String(item.get("base_type", item.get("archetype", "")))
	if base_type == "melee":
		base_type = "sword"
	elif base_type == "ranged":
		base_type = "bow"
	elif base_type == "magic":
		base_type = "wand"
	return resolved_id(base_type)

static func validate_contract() -> Array[String]:
	var errors: Array[String] = []
	if ATLAS.get_width() != 512 or ATLAS.get_height() != 512:
		errors.append("item icon atlas must be 512x512")
	if CELLS.size() != 64 or not CELLS.has(FALLBACK_ID):
		errors.append("item icon atlas must expose sixty-three semantic icons plus fallback")
	for definition: Dictionary in ItemBaseRegistry.all():
		var icon_id := String(definition.get("icon_id", ""))
		if icon_id.is_empty() or not CELLS.has(icon_id):
			errors.append("item base has missing or unknown icon_id: %s" % String(definition.get("id", "")))
	return errors
