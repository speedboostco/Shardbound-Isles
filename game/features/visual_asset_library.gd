class_name VisualAssetLibrary
extends RefCounted

const ATLAS_PATH: String = "res://assets/original/emberwood/emberwood_bootstrap_atlas.png"
const ATLAS: Texture2D = preload(ATLAS_PATH)
const FOREST_TILES: Texture2D = preload("res://assets/original/emberwood/forest_tiles.png")
const CELL_SIZE: int = 64
const CELLS: Dictionary = {
	"hero_south": Vector2i(0, 0),
	"hero_west": Vector2i(1, 0),
	"hero_east": Vector2i(2, 0),
	"hero_north": Vector2i(3, 0),
	"slime_idle": Vector2i(0, 1),
	"slime_attack": Vector2i(1, 1),
	"ranger_idle": Vector2i(2, 1),
	"ranger_attack": Vector2i(3, 1),
	"tree": Vector2i(0, 2),
	"stump": Vector2i(1, 2),
	"stone": Vector2i(2, 2),
	"resource_drop": Vector2i(3, 2),
	"grass": Vector2i(0, 3),
	"dirt": Vector2i(1, 3),
	"hit_burst": Vector2i(2, 3),
	"legendary_plant": Vector2i(3, 3),
}

static func asset_ids() -> Array[String]:
	var result: Array[String] = []
	for asset_id: String in CELLS:
		result.append(asset_id)
	result.sort()
	return result

static func region(asset_id: String) -> Rect2:
	var cell: Vector2i = CELLS.get(asset_id, Vector2i(-1, -1))
	if cell.x < 0 or cell.y < 0:
		return Rect2()
	return Rect2(Vector2(cell * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))

static func texture(asset_id: String) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = ATLAS
	result.region = region(asset_id)
	result.filter_clip = true
	return result

static func terrain_region(asset_id: String) -> Rect2:
	return Rect2(64, 0, 64, 64) if asset_id == "dirt" else Rect2(0, 0, 64, 64)

static func sprite(asset_id: String, scale_value: float = 1.0) -> Sprite2D:
	var result := Sprite2D.new()
	result.texture = texture(asset_id)
	result.scale = Vector2.ONE * scale_value
	result.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	result.name = "EmberwoodSprite"
	return result

static func validate_contract() -> Array[String]:
	var errors: Array[String] = []
	if ATLAS.get_width() != CELL_SIZE * 4 or ATLAS.get_height() != CELL_SIZE * 4:
		errors.append("Emberwood runtime atlas must be 256x256")
	if CELLS.size() != 16:
		errors.append("Emberwood atlas must expose exactly sixteen semantic cells")
	var seen: Dictionary = {}
	for asset_id: String in CELLS:
		var cell: Vector2i = CELLS[asset_id]
		if cell.x < 0 or cell.x >= 4 or cell.y < 0 or cell.y >= 4:
			errors.append("asset cell outside 4x4 atlas: %s" % asset_id)
		if seen.has(cell):
			errors.append("duplicate atlas cell: %s" % cell)
		seen[cell] = asset_id
	if FOREST_TILES.get_width() != 128 or FOREST_TILES.get_height() != 64:
		errors.append("Emberwood forest terrain atlas must be 128x64")
	return errors
