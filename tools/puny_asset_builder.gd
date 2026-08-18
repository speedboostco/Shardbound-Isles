extends SceneTree

const ROOT := "res://assets/third_party/shade/puny_cc0/"
const SOURCE := ROOT + "source/Puny-Characters/"
const WORLD_SOURCE := ROOT + "source/Puny-World/PUNY_WORLD_v1/PUNY_WORLD_v1/punyworld-overworld-tileset.png"
const OUTPUTS: Array[Dictionary] = [
	{"source": SOURCE + "Warrior-Blue.png", "output": ROOT + "puny_hero.png"},
	{"source": SOURCE + "Orc-Grunt.png", "output": ROOT + "puny_orc.png"},
	{"source": SOURCE + "Archer-Purple.png", "output": ROOT + "puny_archer.png"},
	{"source": SOURCE + "Mage-Red.png", "output": ROOT + "puny_mage.png"},
	{"source": SOURCE + "Environment/Tree.png", "output": ROOT + "puny_tree.png"},
	{"source": WORLD_SOURCE, "output": ROOT + "puny_world.png"},
]
const PALETTE_HEX: Array[String] = [
	"0b1218", "172331", "2a3e46", "3c5960",
	"214e46", "4d7a4a", "76a85b", "a4c46c",
	"6b4937", "a26845", "e5a84b", "e8d8a8",
	"f6edcf", "e9674c", "8f66b3", "4db7b3",
]

func _initialize() -> void:
	var palette: Array[Color] = []
	for value: String in PALETTE_HEX:
		palette.append(Color(value))
	var failed := false
	for definition: Dictionary in OUTPUTS:
		var image := Image.load_from_file(ProjectSettings.globalize_path(String(definition.source)))
		if image == null or image.is_empty():
			push_error("Could not load Puny source: %s" % definition.source)
			failed = true
			continue
		for y: int in image.get_height():
			for x: int in image.get_width():
				var pixel := image.get_pixel(x, y)
				if pixel.a < 0.5:
					image.set_pixel(x, y, Color(0, 0, 0, 0))
				else:
					image.set_pixel(x, y, _nearest_color(pixel, palette))
		var error := image.save_png(ProjectSettings.globalize_path(String(definition.output)))
		if error != OK:
			push_error("Could not save Puny runtime asset: %s" % definition.output)
			failed = true
	var boulder_error := _build_boulder().save_png(ProjectSettings.globalize_path(ROOT + "puny_boulder.png"))
	if boulder_error != OK:
		push_error("Could not save cohesive Puny-palette boulder")
		failed = true
	for flora_definition: Dictionary in [
		{"image": _build_flora_1(), "path": ROOT + "puny_flora_1.png"},
		{"image": _build_flora_2(), "path": ROOT + "puny_flora_2.png"},
	]:
		var flora_error := (flora_definition.image as Image).save_png(ProjectSettings.globalize_path(String(flora_definition.path)))
		if flora_error != OK:
			push_error("Could not save cohesive Puny-palette flora")
			failed = true
	quit(1 if failed else 0)

func _build_boulder() -> Image:
	var pixels: Array[String] = [
		"................", "................", "......xxxx......", "....xxddddxx....",
		"...xddmmmmddx...", "..xddmllllmddx..", "..xdmllllllmdx..", ".xdmlllhhlllmdx.",
		".xdmllllllllmdx.", ".xdmllllllllmdx.", "..xdmlllllmddx..", "..xxddmmmddxx...",
		"...xxddddxx.....", "...gggggggggg...", "..gggggggggggg..", "................",
	]
	return _pixel_object(pixels, {
		"x": Color("0b1218"), "d": Color("2a3e46"), "m": Color("3c5960"),
		"l": Color("4d7a4a"), "h": Color("76a85b"), "g": Color("214e46"),
	})

func _build_flora_1() -> Image:
	return _pixel_object([
		"................", "................", "................", "................",
		".......l........", "....g..l..g.....", ".....g.l.g......", "......lll.......",
		"...g..lll..g....", "....ggllllg.....", "......lll.......", ".....g.l.g......",
		"....g..l..g.....", "......dbd.......", ".....ddbdd......", "................",
	], {"g": Color("4d7a4a"), "l": Color("76a85b"), "d": Color("6b4937"), "b": Color("a26845")})

func _build_flora_2() -> Image:
	return _pixel_object([
		"................", "................", "................", "................",
		".....p....p.....", "....ppp..ppp....", ".....p....p.....", "......g..g......",
		"...h..g..g..h...", "....h.gggg.h....", ".....gg..gg.....", "......g..g......",
		"....g.g..g.g....", ".....d....d.....", "....ddb..bdd....", "................",
	], {"g": Color("4d7a4a"), "h": Color("a4c46c"), "p": Color("8f66b3"), "d": Color("6b4937"), "b": Color("a26845")})

func _pixel_object(pixels: Array[String], colors: Dictionary) -> Image:
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y: int in pixels.size():
		for x: int in pixels[y].length():
			var token := pixels[y].substr(x, 1)
			if colors.has(token):
				image.set_pixel(x, y, colors[token] as Color)
	return image

func _nearest_color(source_color: Color, palette: Array[Color]) -> Color:
	var nearest := palette[0]
	var nearest_distance := INF
	for candidate: Color in palette:
		var red := source_color.r - candidate.r
		var green := source_color.g - candidate.g
		var blue := source_color.b - candidate.b
		var distance := red * red * 0.30 + green * green * 0.59 + blue * blue * 0.11
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return Color(nearest.r, nearest.g, nearest.b, 1.0)
