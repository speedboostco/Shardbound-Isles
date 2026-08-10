extends SceneTree

const PATHS: Array[String] = [
	"res://assets/original/emberwood/emberwood_bootstrap_atlas.png",
	"res://assets/original/emberwood/forest_tiles.png",
]
const PALETTE: Array[Color] = [
	Color("0e151d"), Color("172331"), Color("26394a"), Color("214e46"),
	Color("4d7a4a"), Color("76a85b"), Color("8b5a35"), Color("596273"),
	Color("e8d8a8"), Color("ffffff"), Color("e5a84b"), Color("e9674c"),
	Color("4db7b3"), Color("8fe7ff"), Color("6c8ac4"), Color("b96cff"),
]

func _initialize() -> void:
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
