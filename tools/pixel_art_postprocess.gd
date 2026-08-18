extends SceneTree

const PATHS: Array[String] = [
	"res://assets/original/emberwood/emberwood_bootstrap_atlas.png",
	"res://assets/original/emberwood/forest_tiles.png",
	"res://assets/original/emberwood/emberwood_animation_atlas.png",
	"res://assets/original/emberwood/emberwood_item_icons.png",
	"res://assets/original/emberwood/emberwood_hero_v3_atlas.png",
	"res://assets/original/emberwood/emberwood_actors_v3_atlas.png",
	"res://assets/original/emberwood/emberwood_resources_v3_atlas.png",
	"res://assets/original/emberwood/emberwood_structures_v3_atlas.png",
	"res://assets/original/emberwood/emberwood_item_icons_v3.png",
	"res://assets/original/emberwood/emberwood_vfx_v3_atlas.png",
	"res://assets/original/emberwood/emberwood_terrain_v3.png",
	"res://assets/original/emberwood/emberwood_living_world_v1_atlas.png",
	"res://assets/third_party/pixel_frog/tiny_swords_cc0/terrain_deco_atlas.png",
]
const THIRD_PARTY_DECO_SOURCES: Array[String] = ["01.png", "02.png", "04.png", "05.png", "07.png", "08.png", "10.png", "11.png"]
const ACTOR_SOURCE_ROOT: String = "res://assets/third_party/pixel_frog/tiny_swords_cc0/source"
const ACTOR_CELL_SIZE: int = 128
const GENERATED_ATLASES: Array[Dictionary] = [
	{"source": "res://assets/original/emberwood/source/emberwood_animation_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_animation_atlas.png", "columns": 8, "rows": 8},
	{"source": "res://assets/original/emberwood/source/emberwood_item_icons_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_item_icons.png", "columns": 4, "rows": 4},
	{"source": "res://assets/original/emberwood/source/emberwood_hero_v3_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_hero_v3_atlas.png", "columns": 8, "rows": 8, "clear_cell_top": 6, "clear_cell_top_overrides": {"0:5": 16, "1:5": 16, "2:5": 16, "3:5": 16, "3:6": 16, "4:6": 16, "5:6": 16, "6:6": 16}},
	{"source": "res://assets/original/emberwood/source/emberwood_actors_v3_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_actors_v3_atlas.png", "columns": 8, "rows": 8, "clear_cell_top": 6, "clear_cell_top_rows": [2, 4]},
	{"source": "res://assets/original/emberwood/source/emberwood_resources_v3_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_resources_v3_atlas.png", "columns": 4, "rows": 4, "clear_cell_top": 6, "clear_cell_top_rows": [1]},
	{"source": "res://assets/original/emberwood/source/emberwood_structures_v3_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_structures_v3_atlas.png", "columns": 4, "rows": 4},
	{"source": "res://assets/original/emberwood/source/emberwood_item_icons_v3_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_item_icons_v3.png", "columns": 8, "rows": 8},
	{"source": "res://assets/original/emberwood/source/emberwood_vfx_v3_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_vfx_v3_atlas.png", "columns": 7, "rows": 8},
	{"source": "res://assets/original/emberwood/source/emberwood_terrain_v3_master.png", "output": "res://assets/original/emberwood/emberwood_terrain_v3.png", "columns": 4, "rows": 4},
	{"source": "res://assets/original/emberwood/source/emberwood_living_world_v1_master_alpha.png", "output": "res://assets/original/emberwood/emberwood_living_world_v1_atlas.png", "columns": 4, "rows": 4},
]
const PALETTE: Array[Color] = [
	Color("0e151d"), Color("172331"), Color("26394a"), Color("214e46"),
	Color("4d7a4a"), Color("76a85b"), Color("8b5a35"), Color("596273"),
	Color("e8d8a8"), Color("ffffff"), Color("e5a84b"), Color("e9674c"),
	Color("4db7b3"), Color("8fe7ff"), Color("6c8ac4"), Color("b96cff"),
]

func _initialize() -> void:
	if not _prepare_third_party_deco_atlas():
		quit(1)
		return
	if not _prepare_third_party_actor_atlases():
		quit(1)
		return
	for definition: Dictionary in GENERATED_ATLASES:
		if not _prepare_generated_atlas(definition):
			quit(1)
			return
	for path: String in PATHS:
		var absolute_path := ProjectSettings.globalize_path(path)
		var image := Image.load_from_file(absolute_path)
		if image == null or image.is_empty():
			push_error("Could not load pixel-art raster: %s" % path)
			quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		var data := image.get_data()
		var cache: Dictionary = {}
		for byte_index: int in range(0, data.size(), 4):
			if data[byte_index + 3] < 128:
				data[byte_index] = 0
				data[byte_index + 1] = 0
				data[byte_index + 2] = 0
				data[byte_index + 3] = 0
				continue
			var key := (int(data[byte_index]) << 16) | (int(data[byte_index + 1]) << 8) | int(data[byte_index + 2])
			var nearest: Color = cache.get(key, Color(-1, -1, -1, 1)) as Color
			if nearest.r < 0.0:
				nearest = _nearest_palette_color(Color8(data[byte_index], data[byte_index + 1], data[byte_index + 2]))
				cache[key] = nearest
			data[byte_index] = roundi(nearest.r * 255.0)
			data[byte_index + 1] = roundi(nearest.g * 255.0)
			data[byte_index + 2] = roundi(nearest.b * 255.0)
			data[byte_index + 3] = 255
		image = Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)
		var error := image.save_png(absolute_path)
		if error != OK:
			push_error("Could not save processed pixel-art raster %s: %s" % [path, error_string(error)])
			quit(1)
			return
		print("PIXEL_ART_PROCESSED %s %dx%d palette=%d" % [path, image.get_width(), image.get_height(), PALETTE.size()])
	quit(0)

func _prepare_third_party_actor_atlases() -> bool:
	var hero := Image.create(ACTOR_CELL_SIZE * 12, ACTOR_CELL_SIZE * 10, false, Image.FORMAT_RGBA8)
	hero.fill(Color(0, 0, 0, 0))
	var hero_definitions: Array[Dictionary] = [
		{"file": "pawn_blue.png", "source_columns": 6, "column": 0, "row": 0, "clips": [[0, 1, 2, 3, 4, 5], [6, 7, 8, 9, 10, 11], [0, 1, 2, 3, 4, 5], [0, 1, 0, 1, 0, 1], [17, 17, 17, 17, 17, 17]]},
		{"file": "warrior_blue.png", "source_columns": 6, "column": 6, "row": 0, "clips": [[0, 1, 2, 3, 4, 5], [6, 7, 8, 9, 10, 11], [12, 13, 14, 15, 16, 17], [0, 1, 0, 1, 0, 1], [17, 17, 17, 17, 17, 17]]},
		{"file": "archer_blue.png", "source_columns": 8, "column": 0, "row": 5, "clips": [[0, 1, 2, 3, 4, 5], [8, 9, 10, 11, 12, 13], [16, 17, 18, 19, 20, 21], [0, 1, 0, 1, 0, 1], [21, 21, 21, 21, 21, 21]]},
		{"file": "pawn_purple.png", "source_columns": 6, "column": 6, "row": 5, "clips": [[0, 1, 2, 3, 4, 5], [6, 7, 8, 9, 10, 11], [0, 1, 2, 3, 4, 5], [0, 1, 0, 1, 0, 1], [23, 23, 23, 23, 23, 23]]},
	]
	for definition: Dictionary in hero_definitions:
		var source := _load_actor_source(String(definition.file))
		if source == null:
			return false
		var clips := definition.clips as Array
		for row_offset: int in clips.size():
			_blit_actor_clip(source, int(definition.source_columns), clips[row_offset] as Array, hero, int(definition.column), int(definition.row) + row_offset)
	if not _save_actor_atlas(hero, "res://assets/third_party/pixel_frog/tiny_swords_cc0/hero_animation_atlas.png"):
		return false

	var actors := Image.create(ACTOR_CELL_SIZE * 12, ACTOR_CELL_SIZE * 10, false, Image.FORMAT_RGBA8)
	actors.fill(Color(0, 0, 0, 0))
	var definitions: Array[Dictionary] = [
		{"file": "tnt_red.png", "source_columns": 7, "column": 0, "row": 0, "clips": [[0, 1, 2, 3, 4, 5], [7, 8, 9, 10, 11, 12], [14, 15, 16, 17, 18, 19], [0, 1, 0, 1, 0, 1], [19, 19, 19, 19, 19, 19]]},
		{"file": "archer_red.png", "source_columns": 8, "column": 6, "row": 0, "clips": [[0, 1, 2, 3, 4, 5], [8, 9, 10, 11, 12, 13], [16, 17, 18, 19, 20, 21], [0, 1, 0, 1, 0, 1], [21, 21, 21, 21, 21, 21]]},
		{"file": "archer_purple.png", "source_columns": 8, "column": 0, "row": 5, "clips": [[0, 1, 2, 3, 4, 5], [8, 9, 10, 11, 12, 13], [16, 17, 18, 19, 20, 21], [0, 1, 0, 1, 0, 1], [21, 21, 21, 21, 21, 21]]},
		{"file": "torch_purple.png", "source_columns": 7, "column": 6, "row": 5, "clips": [[0, 1, 2, 3, 4, 5], [7, 8, 9, 10, 11, 12], [14, 15, 16, 17, 18, 19], [0, 1, 0, 1, 0, 1], [19, 19, 19, 19, 19, 19]]},
	]
	for definition: Dictionary in definitions:
		var source := _load_actor_source(String(definition.file))
		if source == null:
			return false
		var clips := definition.clips as Array
		for row_offset: int in clips.size():
			_blit_actor_clip(source, int(definition.source_columns), clips[row_offset] as Array, actors, int(definition.column), int(definition.row) + row_offset)
	if not _save_actor_atlas(actors, "res://assets/third_party/pixel_frog/tiny_swords_cc0/enemy_animation_atlas.png"):
		return false
	return true

func _load_actor_source(filename: String) -> Image:
	var path := ACTOR_SOURCE_ROOT.path_join(filename)
	var source := Image.load_from_file(ProjectSettings.globalize_path(path))
	if source == null or source.is_empty():
		push_error("Could not load Tiny Swords actor source: %s" % path)
		return null
	source.convert(Image.FORMAT_RGBA8)
	return source

func _blit_actor_clip(source: Image, source_columns: int, frame_indices: Array, output: Image, destination_column: int, destination_row: int) -> void:
	for clip_frame: int in 6:
		var source_index := int(frame_indices[clip_frame])
		var source_cell := Vector2i(source_index % source_columns, source_index / source_columns)
		var frame := source.get_region(Rect2i(source_cell * 192, Vector2i(192, 192)))
		frame.resize(ACTOR_CELL_SIZE, ACTOR_CELL_SIZE, Image.INTERPOLATE_NEAREST)
		frame.convert(Image.FORMAT_RGBA8)
		for y: int in ACTOR_CELL_SIZE:
			for x: int in ACTOR_CELL_SIZE:
				var pixel := frame.get_pixel(x, y)
				frame.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, 1.0 if pixel.a >= 0.5 else 0.0))
		output.blit_rect(frame, Rect2i(Vector2i.ZERO, Vector2i(ACTOR_CELL_SIZE, ACTOR_CELL_SIZE)), Vector2i((destination_column + clip_frame) * ACTOR_CELL_SIZE, destination_row * ACTOR_CELL_SIZE))

func _save_actor_atlas(image: Image, path: String) -> bool:
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Could not save Tiny Swords actor atlas %s: %s" % [path, error_string(error)])
		return false
	print("THIRD_PARTY_ACTOR_ATLAS_PREPARED %s %dx%d" % [path, image.get_width(), image.get_height()])
	return true

func _prepare_third_party_deco_atlas() -> bool:
	var output := Image.create(256, 128, false, Image.FORMAT_RGBA8)
	output.fill(Color(0, 0, 0, 0))
	for index: int in THIRD_PARTY_DECO_SOURCES.size():
		var source_path := "res://assets/third_party/pixel_frog/tiny_swords_cc0/source/%s" % THIRD_PARTY_DECO_SOURCES[index]
		var source := Image.load_from_file(ProjectSettings.globalize_path(source_path))
		if source == null or source.is_empty():
			push_error("Could not load Tiny Swords decoration source: %s" % source_path)
			return false
		source.convert(Image.FORMAT_RGBA8)
		if source.get_width() > 64 or source.get_height() > 64:
			var scale_factor := minf(64.0 / float(source.get_width()), 64.0 / float(source.get_height()))
			source.resize(maxi(1, roundi(source.get_width() * scale_factor)), maxi(1, roundi(source.get_height() * scale_factor)), Image.INTERPOLATE_NEAREST)
		var destination := Vector2i((index % 4) * 64 + (64 - source.get_width()) / 2, (index / 4) * 64 + (64 - source.get_height()) / 2)
		output.blit_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), destination)
	var output_path := "res://assets/third_party/pixel_frog/tiny_swords_cc0/terrain_deco_atlas.png"
	var error := output.save_png(ProjectSettings.globalize_path(output_path))
	if error != OK:
		push_error("Could not save Tiny Swords decoration atlas: %s" % error_string(error))
		return false
	print("THIRD_PARTY_DECO_ATLAS_PREPARED %s 256x128" % output_path)
	return true

func _prepare_generated_atlas(definition: Dictionary) -> bool:
	var source_path := String(definition.source)
	var source := Image.load_from_file(ProjectSettings.globalize_path(source_path))
	if source == null or source.is_empty():
		push_error("Could not load generated atlas source: %s" % source_path)
		return false
	source.convert(Image.FORMAT_RGBA8)
	var columns := int(definition.columns)
	var rows := int(definition.rows)
	var output := Image.create(columns * 64, rows * 64, false, Image.FORMAT_RGBA8)
	output.fill(Color(0, 0, 0, 0))
	for row: int in rows:
		for column: int in columns:
			var left := floori(float(column * source.get_width()) / float(columns))
			var top := floori(float(row * source.get_height()) / float(rows))
			var right := floori(float((column + 1) * source.get_width()) / float(columns))
			var bottom := floori(float((row + 1) * source.get_height()) / float(rows))
			var cell := source.get_region(Rect2i(left, top, right - left, bottom - top))
			cell.resize(64, 64, Image.INTERPOLATE_NEAREST)
			var selected_rows: Array = definition.get("clear_cell_top_rows", []) as Array
			var clear_cell_top := clampi(int(definition.get("clear_cell_top", 0)), 0, 16) if selected_rows.is_empty() or row in selected_rows else 0
			var clear_overrides: Dictionary = definition.get("clear_cell_top_overrides", {}) as Dictionary
			clear_cell_top = clampi(int(clear_overrides.get("%d:%d" % [column, row], clear_cell_top)), 0, 16)
			for clear_y: int in clear_cell_top:
				for clear_x: int in 64:
					cell.set_pixel(clear_x, clear_y, Color(0, 0, 0, 0))
			output.blit_rect(cell, Rect2i(0, 0, 64, 64), Vector2i(column * 64, row * 64))
	var output_path := String(definition.output)
	var error := output.save_png(ProjectSettings.globalize_path(output_path))
	if error != OK:
		push_error("Could not save generated runtime atlas %s: %s" % [output_path, error_string(error)])
		return false
	print("GENERATED_ATLAS_PREPARED %s %dx%d" % [output_path, output.get_width(), output.get_height()])
	return true

func _nearest_palette_color(source: Color) -> Color:
	var result := PALETTE[0]
	var best_distance := INF
	for candidate: Color in PALETTE:
		var delta := Vector3(source.r - candidate.r, source.g - candidate.g, source.b - candidate.b)
		var distance := delta.length_squared()
		if distance < best_distance:
			best_distance = distance
			result = candidate
	return result
