class_name VisualAssetLibrary
extends RefCounted

const ATLAS_PATH: String = "res://assets/original/emberwood/emberwood_bootstrap_atlas.png"
const ATLAS: Texture2D = preload(ATLAS_PATH)
const FOREST_TILES: Texture2D = preload("res://assets/original/emberwood/forest_tiles.png")
const ANIMATION_ATLAS_PATH: String = "res://assets/original/emberwood/emberwood_animation_atlas.png"
const ANIMATION_ATLAS: Texture2D = preload(ANIMATION_ATLAS_PATH)
const PUNY_HERO_ATLAS: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_hero.png")
const PUNY_ORC_ATLAS: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_orc.png")
const PUNY_ARCHER_ATLAS: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_archer.png")
const PUNY_MAGE_ATLAS: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_mage.png")
const PUNY_WORLD_ATLAS: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_world.png")
const PUNY_TREE_TEXTURE: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_tree.png")
const PUNY_FLORA_1_TEXTURE: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_flora_1.png")
const PUNY_FLORA_2_TEXTURE: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_flora_2.png")
const PUNY_BOULDER_TEXTURE: Texture2D = preload("res://assets/third_party/shade/puny_cc0/puny_boulder.png")
const HERO_IDLE_ATLAS: Texture2D = PUNY_HERO_ATLAS
const HERO_MOVE_ATLAS: Texture2D = PUNY_HERO_ATLAS
const HERO_UNARMED_ATLAS: Texture2D = PUNY_HERO_ATLAS
const HERO_MELEE_ATLAS: Texture2D = PUNY_HERO_ATLAS
const HERO_RANGED_ATLAS: Texture2D = PUNY_HERO_ATLAS
const HERO_MAGIC_ATLAS: Texture2D = PUNY_HERO_ATLAS
const HERO_HIT_ATLAS: Texture2D = PUNY_HERO_ATLAS
const HERO_DEATH_ATLAS: Texture2D = PUNY_HERO_ATLAS
const ACTORS_V3_ATLAS: Texture2D = PUNY_ORC_ATLAS
const RESOURCES_V3_ATLAS: Texture2D = preload("res://assets/original/emberwood/emberwood_resources_v3_atlas.png")
const STRUCTURES_V3_ATLAS: Texture2D = preload("res://assets/original/emberwood/emberwood_structures_v3_atlas.png")
const VFX_V3_ATLAS: Texture2D = preload("res://assets/original/emberwood/emberwood_vfx_v3_atlas.png")
const TERRAIN_V3_ATLAS: Texture2D = preload("res://assets/original/emberwood/emberwood_terrain_v3.png")
const LIVING_WORLD_V1_ATLAS: Texture2D = preload("res://assets/original/emberwood/emberwood_living_world_v1_atlas.png")
const HANDDRAWN_TERRAIN_ATLAS: Texture2D = PUNY_WORLD_ATLAS
const HANDDRAWN_DECO_ATLAS: Texture2D = PUNY_WORLD_ATLAS
const CELL_SIZE: int = 64
const ACTOR_CELL_SIZE: int = 32
const PUNY_TILE_SIZE: int = 16
const PUNY_WORLD_COLUMNS: int = 27
const PUNY_DIRECTION_ROWS: Dictionary = {
	"south": 0,
	"south_east": 1,
	"east": 2,
	"north_east": 3,
	"north": 4,
	"north_west": 5,
	"west": 6,
	"south_west": 7,
}
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
	var cells: Dictionary = {
		"grass": Vector2i(0, 0), "grass_b": Vector2i(1, 0), "grass_c": Vector2i(2, 0), "clover": Vector2i(3, 0),
		"dirt": Vector2i(0, 1), "path_horizontal": Vector2i(1, 1), "path_vertical": Vector2i(2, 1), "path_cross": Vector2i(3, 1),
		"path_north": Vector2i(0, 2), "path_south": Vector2i(1, 2), "path_west": Vector2i(2, 2), "path_east": Vector2i(3, 2),
		"roots": Vector2i(0, 3), "moss_stone": Vector2i(1, 3), "water": Vector2i(2, 3), "rift_ground": Vector2i(3, 3),
	}
	var cell: Vector2i = cells.get(asset_id, Vector2i.ZERO)
	return Rect2(Vector2(cell * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))

static func handdrawn_terrain_region(asset_id: String) -> Rect2:
	return puny_terrain_region(asset_id if asset_id.begins_with("path_") or asset_id in ["grass_b", "grass_c"] else "grass")

static func puny_terrain_region(asset_id: String) -> Rect2:
	var tile_id := int({
		"grass": 0, "grass_b": 1, "grass_c": 2,
		"path_vertical": 30, "path_horizontal": 86, "path_cross": 32,
		"path": 32, "water": 270,
	}.get(asset_id, 0))
	return _puny_world_region(tile_id)

static func handdrawn_deco_texture(index: int) -> Texture2D:
	match posmod(index, 8):
		0, 3, 6: return PUNY_FLORA_1_TEXTURE
		1, 4, 7: return PUNY_FLORA_2_TEXTURE
		2: return _puny_world_texture(756)
		_: return _puny_world_texture(757)

static func world_object_texture(asset_id: String) -> AtlasTexture:
	if asset_id == "forest_tree":
		return _texture_region(PUNY_TREE_TEXTURE, Rect2(0, 0, 16, 16))
	if asset_id == "boulder":
		return _texture_region(PUNY_BOULDER_TEXTURE, Rect2(0, 0, 16, 16))
	if asset_id == "shrub":
		return _texture_region(PUNY_FLORA_1_TEXTURE, Rect2(0, 0, 16, 16))
	var tile_ids: Dictionary = {"flower": 756, "mushroom": 757, "stump": 784}
	return _puny_world_texture(int(tile_ids.get(asset_id, 756)))

static func sprite(asset_id: String, scale_value: float = 1.0) -> Sprite2D:
	var result := Sprite2D.new()
	result.texture = texture(asset_id)
	result.scale = Vector2.ONE * scale_value
	result.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	result.name = "EmberwoodSprite"
	return result

static func animation_texture(actor_id: String, state_name: String, facing: String = "south", frame: int = 0, elite: bool = false) -> AtlasTexture:
	var cell := animation_cell(actor_id, state_name, facing, frame, elite)
	if actor_id.begins_with("hero") or actor_id in ["slime", "ranger", "boss"]:
		return _actor_atlas_texture(_puny_actor_atlas(actor_id, elite), cell)
	return _atlas_texture(ANIMATION_ATLAS, cell)

static func hero_actor_id_for_weapon(base_type: String) -> String:
	match base_type.to_lower():
		"melee", "sword": return "hero_sword"
		"ranged", "bow": return "hero_bow"
		"magic", "wand": return "hero_wand"
		_: return "hero_unarmed"

static func animation_cell(actor_id: String, state_name: String, facing: String = "south", frame: int = 0, elite: bool = false) -> Vector2i:
	var cells := _animation_cells(actor_id, state_name, facing, elite)
	return cells[posmod(frame, cells.size())]

static func animation_frame_count(actor_id: String, state_name: String, facing: String = "south", elite: bool = false) -> int:
	return _animation_cells(actor_id, state_name, facing, elite).size()

static func puny_direction_row(facing: String) -> int:
	return int(PUNY_DIRECTION_ROWS.get(facing, PUNY_DIRECTION_ROWS.south))

static func resource_texture(kind: String, frame: int = 0, depleted: bool = false) -> AtlasTexture:
	if kind == "tree":
		return world_object_texture("stump" if depleted else "forest_tree")
	if kind == "stone":
		return world_object_texture("boulder")
	return world_object_texture("mushroom" if depleted else "flower")

static func resource_pickup_texture(kind: String) -> AtlasTexture:
	var column := {"wood": 0, "stone": 1, "moonleaf": 2, "plank": 3}.get(kind, 0) as int
	return _atlas_texture(RESOURCES_V3_ATLAS, Vector2i(column, 3))

static func structure_texture(structure_id: String, active: bool = false) -> AtlasTexture:
	var cells: Dictionary = {
		"workbench": [Vector2i(0, 0), Vector2i(1, 0)], "lumber_mill": [Vector2i(2, 0), Vector2i(3, 0)],
		"collector": [Vector2i(0, 1), Vector2i(1, 1)], "shared_storage": [Vector2i(2, 1), Vector2i(3, 1)],
		"tidecatcher": [Vector2i(0, 2), Vector2i(1, 2)], "island_pedestal": [Vector2i(2, 2), Vector2i(3, 2)],
		"rift_portal": [Vector2i(0, 3), Vector2i(1, 3)], "island_event": [Vector2i(2, 3), Vector2i(2, 3)],
		"reward_chest": [Vector2i(3, 3), Vector2i(3, 3)],
	}
	var variants: Array = cells.get(structure_id, cells["workbench"]) as Array
	return _atlas_texture(STRUCTURES_V3_ATLAS, variants[1 if active else 0] as Vector2i)

static func living_world_texture(prop_id: String, state_frame: int = 0) -> AtlasTexture:
	var row := {"moonleaf_thicket": 0, "tidewell": 1, "whispering_shrine": 2, "firefly_hollow": 3}.get(prop_id, 0) as int
	return _atlas_texture(LIVING_WORLD_V1_ATLAS, Vector2i(clampi(state_frame, 0, 3), row))

static func vfx_texture(effect_id: String, frame: int) -> AtlasTexture:
	var row := {"hit": 0, "critical": 1, "gather": 2, "death": 3, "pickup": 4, "legendary": 5, "materialize": 6, "rift": 7}.get(effect_id, 0) as int
	return _atlas_texture(VFX_V3_ATLAS, Vector2i(clampi(frame, 0, 6), row))

static func vfx_frame_count() -> int:
	return 7

static func _animation_cells(actor_id: String, state_name: String, facing: String, elite: bool) -> Array[Vector2i]:
	if actor_id.begins_with("hero") or actor_id in ["slime", "ranger", "boss"]:
		var direction_index := puny_direction_row(facing)
		var columns: Array[int]
		match state_name:
			"idle": columns = [0, 1]
			"move": columns = [2, 3]
			"hit": columns = [18]
			"death": columns = [19, 20, 21, 22, 23]
			"attack":
				if actor_id in ["hero_bow", "ranger"]:
					columns = [8, 9, 10, 11]
				elif actor_id in ["hero_wand", "boss"]:
					columns = [12, 13, 14, 15]
				elif actor_id == "hero_unarmed":
					columns = [16, 17]
				else:
					columns = [4, 5, 6, 7]
			_:
				columns = [0]
		var result: Array[Vector2i] = []
		for column: int in columns:
			result.append(Vector2i(column, direction_index))
		return result
	# Retained v2 fallback for presentation-only objects that have not migrated.
	var fallback_columns: Array = {"idle": [0, 1], "move": [2, 3], "attack": [4, 5], "hit": [6], "death": [7], "tree": [0, 1], "stone": [2, 3], "workbench": [4, 5], "lumber_mill": [6, 7]}.get(state_name, [0]) as Array
	return _row_cells(7, fallback_columns)

static func _row_cells(row: int, columns: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for column: Variant in columns:
		result.append(Vector2i(int(column), row))
	return result

static func _offset_row_cells(row: int, column_offset: int, columns: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for column: Variant in columns:
		result.append(Vector2i(column_offset + int(column), row))
	return result

static func _atlas_texture(atlas: Texture2D, cell: Vector2i) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = Rect2(Vector2(cell * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
	result.filter_clip = true
	return result

static func _actor_atlas_texture(atlas: Texture2D, cell: Vector2i) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = Rect2(Vector2(cell * ACTOR_CELL_SIZE), Vector2(ACTOR_CELL_SIZE, ACTOR_CELL_SIZE))
	result.filter_clip = true
	return result

static func _puny_actor_atlas(actor_id: String, elite: bool = false) -> Texture2D:
	if actor_id.begins_with("hero"):
		return PUNY_HERO_ATLAS
	if actor_id == "ranger":
		return PUNY_MAGE_ATLAS if elite else PUNY_ARCHER_ATLAS
	if actor_id == "boss":
		return PUNY_MAGE_ATLAS
	return PUNY_ORC_ATLAS

static func _puny_world_region(tile_id: int) -> Rect2:
	var cell := Vector2i(posmod(tile_id, PUNY_WORLD_COLUMNS), tile_id / PUNY_WORLD_COLUMNS)
	return Rect2(Vector2(cell * PUNY_TILE_SIZE), Vector2(PUNY_TILE_SIZE, PUNY_TILE_SIZE))

static func _puny_world_texture(tile_id: int) -> AtlasTexture:
	return _texture_region(PUNY_WORLD_ATLAS, _puny_world_region(tile_id))

static func _texture_region(atlas: Texture2D, region_value: Rect2) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = region_value
	result.filter_clip = true
	return result

static func validate_cohesive_family() -> Array[String]:
	var errors: Array[String] = []
	for atlas: Texture2D in [PUNY_HERO_ATLAS, PUNY_ORC_ATLAS, PUNY_ARCHER_ATLAS, PUNY_MAGE_ATLAS]:
		if atlas.get_size() != Vector2(768, 256):
			errors.append("Puny actor sheet must be 24x8 cells: %s" % atlas.resource_path)
	if PUNY_WORLD_ATLAS.get_size() != Vector2(432, 1040):
		errors.append("Puny World atlas must be 27x65 cells")
	for texture_value: Texture2D in [PUNY_TREE_TEXTURE, PUNY_FLORA_1_TEXTURE, PUNY_FLORA_2_TEXTURE, PUNY_BOULDER_TEXTURE]:
		if texture_value.get_size() != Vector2(16, 16):
			errors.append("Puny world-object texture must be one 16px cell: %s" % texture_value.resource_path)
	return errors

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
	if ANIMATION_ATLAS.get_width() != CELL_SIZE * 8 or ANIMATION_ATLAS.get_height() != CELL_SIZE * 8:
		errors.append("Emberwood animation atlas must be 512x512")
	errors.append_array(validate_cohesive_family())
	if RESOURCES_V3_ATLAS.get_width() != 256 or RESOURCES_V3_ATLAS.get_height() != 256 or STRUCTURES_V3_ATLAS.get_width() != 256 or STRUCTURES_V3_ATLAS.get_height() != 256:
		errors.append("Emberwood v3 resource and structure atlases must be 256x256")
	if VFX_V3_ATLAS.get_width() != 448 or VFX_V3_ATLAS.get_height() != 512:
		errors.append("Emberwood v3 VFX atlas must be 448x512")
	if TERRAIN_V3_ATLAS.get_width() != 256 or TERRAIN_V3_ATLAS.get_height() != 256:
		errors.append("Emberwood v3 terrain atlas must be 256x256")
	if LIVING_WORLD_V1_ATLAS.get_width() != 256 or LIVING_WORLD_V1_ATLAS.get_height() != 256:
		errors.append("Emberwood living-world atlas must be 256x256")
	return errors
