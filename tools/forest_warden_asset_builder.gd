extends SceneTree

const SOURCE_PATH := "res://assets/original/emberwood/source/emberwood_forest_warden_v1_master_alpha.png"
const OUTPUT_PATH := "res://assets/original/emberwood/emberwood_forest_warden_v1_atlas.png"
const COLUMNS := 4
const ROWS := 4
const CELL_SIZE := 64
const PALETTE: Array[Color] = [
	Color("0e151d"), Color("172331"), Color("26394a"), Color("214e46"),
	Color("4d7a4a"), Color("76a85b"), Color("8b5a35"), Color("596273"),
	Color("e8d8a8"), Color("ffffff"), Color("e5a84b"), Color("e9674c"),
	Color("4db7b3"), Color("8fe7ff"), Color("6c8ac4"), Color("b96cff"),
]

func _initialize() -> void:
	var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE_PATH))
	if source == null or source.is_empty():
		push_error("Could not load Forest Warden source atlas")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	var output := Image.create(COLUMNS * CELL_SIZE, ROWS * CELL_SIZE, false, Image.FORMAT_RGBA8)
	output.fill(Color(0, 0, 0, 0))
	for row: int in ROWS:
		for column: int in COLUMNS:
			var left := floori(float(column * source.get_width()) / float(COLUMNS))
			var top := floori(float(row * source.get_height()) / float(ROWS))
			var right := floori(float((column + 1) * source.get_width()) / float(COLUMNS))
			var bottom := floori(float((row + 1) * source.get_height()) / float(ROWS))
			var cell := source.get_region(Rect2i(left, top, right - left, bottom - top))
			cell.resize(CELL_SIZE, CELL_SIZE, Image.INTERPOLATE_NEAREST)
			_quantize_binary_alpha(cell)
			output.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(column * CELL_SIZE, row * CELL_SIZE))
	var error := output.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if error != OK:
		push_error("Could not save Forest Warden runtime atlas: %s" % error_string(error))
		quit(1)
		return
	print("FOREST_WARDEN_ATLAS_PREPARED %s %dx%d palette=%d" % [OUTPUT_PATH, output.get_width(), output.get_height(), PALETTE.size()])
	quit(0)

func _quantize_binary_alpha(image: Image) -> void:
	var cache: Dictionary = {}
	for y: int in image.get_height():
		for x: int in image.get_width():
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.32:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var key := pixel.to_html(false)
			var nearest: Color = cache.get(key, Color(-1, -1, -1, 1)) as Color
			if nearest.r < 0.0:
				nearest = _nearest_color(pixel)
				cache[key] = nearest
			image.set_pixel(x, y, Color(nearest.r, nearest.g, nearest.b, 1.0))

func _nearest_color(source: Color) -> Color:
	var result := PALETTE[0]
	var best_distance := INF
	for candidate: Color in PALETTE:
		var delta := Vector3(source.r - candidate.r, source.g - candidate.g, source.b - candidate.b)
		var distance := delta.length_squared()
		if distance < best_distance:
			best_distance = distance
			result = candidate
	return result
