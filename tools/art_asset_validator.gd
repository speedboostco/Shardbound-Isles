class_name ArtAssetValidator
extends RefCounted

const RUNTIME_ATLAS: String = "res://assets/original/emberwood/emberwood_bootstrap_atlas.png"
const RUNTIME_RASTERS: Array[String] = [
	RUNTIME_ATLAS,
	"res://assets/original/emberwood/forest_tiles.png",
	"res://assets/original/emberwood/emberwood_animation_atlas.png",
	"res://assets/original/emberwood/emberwood_item_icons.png",
	"res://assets/third_party/pixel_frog/tiny_swords_cc0/hero_animation_atlas.png",
	"res://assets/third_party/hormelz/knight_cc0/hero_idle_atlas.png",
	"res://assets/third_party/hormelz/knight_cc0/hero_move_atlas.png",
	"res://assets/third_party/hormelz/knight_cc0/hero_unarmed_atlas.png",
	"res://assets/third_party/hormelz/knight_cc0/hero_melee_atlas.png",
	"res://assets/third_party/hormelz/knight_cc0/hero_ranged_atlas.png",
	"res://assets/third_party/hormelz/knight_cc0/hero_magic_atlas.png",
	"res://assets/third_party/hormelz/knight_cc0/hero_hit_atlas.png",
	"res://assets/third_party/hormelz/knight_cc0/hero_death_atlas.png",
	"res://assets/third_party/pixel_frog/tiny_swords_cc0/enemy_animation_atlas.png",
	"res://assets/original/emberwood/emberwood_resources_v3_atlas.png",
	"res://assets/original/emberwood/emberwood_structures_v3_atlas.png",
	"res://assets/original/emberwood/emberwood_item_icons_v3.png",
	"res://assets/original/emberwood/emberwood_vfx_v3_atlas.png",
	"res://assets/original/emberwood/emberwood_terrain_v3.png",
	"res://assets/original/emberwood/emberwood_living_world_v1_atlas.png",
	"res://assets/original/emberwood/emberwood_starting_island_v4.png",
	"res://assets/original/emberwood/emberwood_forest_warden_v1_atlas.png",
	"res://assets/third_party/pixel_frog/tiny_swords_cc0/tilemap_flat.png",
	"res://assets/third_party/pixel_frog/tiny_swords_cc0/terrain_deco_atlas.png",
	"res://assets/third_party/shade/puny_cc0/puny_hero.png",
	"res://assets/third_party/shade/puny_cc0/puny_orc.png",
	"res://assets/third_party/shade/puny_cc0/puny_archer.png",
	"res://assets/third_party/shade/puny_cc0/puny_mage.png",
	"res://assets/third_party/shade/puny_cc0/puny_tree.png",
	"res://assets/third_party/shade/puny_cc0/puny_flora_1.png",
	"res://assets/third_party/shade/puny_cc0/puny_flora_2.png",
	"res://assets/third_party/shade/puny_cc0/puny_boulder.png",
	"res://assets/third_party/shade/puny_cc0/puny_world.png",
]
const SOURCE_ARCHIVE_EXTENSIONS: Array[String] = ["zip", "7z", "rar", "psd", "aseprite"]

static func validate_repository() -> Array[String]:
	var errors: Array[String] = []
	for path: String in RUNTIME_RASTERS:
		if not FileAccess.file_exists(path):
			errors.append("registered Emberwood runtime raster is missing: %s" % path)
			continue
		var texture_value: Variant = load(path)
		if texture_value == null or not texture_value is Texture2D:
			errors.append("registered raster cannot be imported as Texture2D: %s" % path)
			continue
		var image := (texture_value as Texture2D).get_image()
		var import_options := _read_import_options(path + ".import")
		var is_production_hero := path.contains("/hormelz/knight_cc0/")
		var is_puny_actor := path.contains("/shade/puny_cc0/puny_") and path.get_file() in ["puny_hero.png", "puny_orc.png", "puny_archer.png", "puny_mage.png"]
		var is_puny_world := path.contains("/shade/puny_cc0/") and not is_puny_actor
		var is_starting_island := path.ends_with("emberwood_starting_island_v4.png")
		var cell_size := 32 if is_puny_actor else (16 if is_puny_world else (128 if is_production_hero else 64))
		var maximum_colors := 128 if is_production_hero or is_starting_island else 16
		errors.append_array(validate_metadata(path.get_file(), image.get_width(), image.get_height(), image.detect_alpha(), import_options, cell_size))
		errors.append_array(validate_pixel_content(path.get_file(), image, cell_size, maximum_colors))
	if int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", -1)) != 0:
		errors.append("canvas texture default filter must be nearest (0)")
	if bool(ProjectSettings.get_setting("rendering/textures/default_filters/use_nearest_mipmap_filter", true)):
		errors.append("nearest mipmap fallback must stay disabled")
	errors.append_array(VisualAssetLibrary.validate_contract())
	errors.append_array(ItemIconLibrary.validate_contract())
	if not FileAccess.file_exists("res://assets/original/emberwood/source/.gdignore"):
		errors.append("asset source directory must contain .gdignore")
	_scan_for_archives("res://assets", errors)
	return errors

static func validate_pixel_content(filename: String, image: Image, cell_size: int, maximum_opaque_colors: int) -> Array[String]:
	var errors: Array[String] = []
	if image == null or image.is_empty() or cell_size <= 0 or maximum_opaque_colors <= 0:
		return ["pixel-content validation arguments are invalid: %s" % filename]
	var row_count := floori(float(image.get_height()) / float(cell_size))
	var column_count := floori(float(image.get_width()) / float(cell_size))
	for cell_y: int in row_count:
		for cell_x: int in column_count:
			var colors: Dictionary = {}
			var has_partial_alpha := false
			for y: int in cell_size:
				for x: int in cell_size:
					var pixel := image.get_pixel(cell_x * cell_size + x, cell_y * cell_size + y)
					if pixel.a > 0.0 and pixel.a < 1.0:
						has_partial_alpha = true
					if pixel.a >= 1.0:
						colors[pixel.to_html(false)] = true
			if has_partial_alpha:
				errors.append("pixel-art cell must use binary alpha: %s cell=%d,%d" % [filename, cell_x, cell_y])
			if colors.size() > maximum_opaque_colors:
				errors.append("pixel-art cell exceeds %d opaque colors: %s cell=%d,%d colors=%d" % [maximum_opaque_colors, filename, cell_x, cell_y, colors.size()])
	return errors

static func validate_metadata(filename: String, width: int, height: int, has_alpha: bool, import_options: Dictionary, cell_size: int = 0) -> Array[String]:
	var errors: Array[String] = []
	var naming := RegEx.new()
	if naming.compile("^[a-z0-9_]+\\.png$") != OK or naming.search(filename) == null:
		errors.append("runtime raster filename must be lowercase snake_case PNG: %s" % filename)
	if width <= 0 or height <= 0 or width > 2048 or height > 2048:
		errors.append("runtime raster dimensions must be 1..2048: %dx%d" % [width, height])
	if cell_size > 0 and (width % cell_size != 0 or height % cell_size != 0):
		errors.append("atlas dimensions must be divisible by %d: %dx%d" % [cell_size, width, height])
	if "atlas" in filename.to_lower() and not has_alpha:
		errors.append("runtime sprite atlas must retain alpha")
	if import_options.is_empty():
		errors.append("runtime raster import metadata is missing")
	else:
		if int(import_options.get("compress/mode", -1)) != 0:
			errors.append("runtime raster must use lossless import compression mode 0")
		if bool(import_options.get("mipmaps/generate", true)):
			errors.append("runtime raster must disable mipmaps")
		if bool(import_options.get("process/hdr_as_srgb", true)):
			errors.append("runtime raster must not use HDR-as-sRGB processing")
	return errors

static func _read_import_options(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return {}
	var result: Dictionary = {}
	for key: String in config.get_section_keys("params"):
		result[key] = config.get_value("params", key)
	return result

static func _scan_for_archives(path: String, errors: Array[String]) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry not in [".", ".."]:
			var child := path.path_join(entry)
			if directory.current_is_dir():
				_scan_for_archives(child, errors)
			elif entry.get_extension().to_lower() in SOURCE_ARCHIVE_EXTENSIONS:
				errors.append("raw source archive must not live in runtime asset tree: %s" % child)
		entry = directory.get_next()
	directory.list_dir_end()
