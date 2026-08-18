extends SceneTree

const SOURCE_ROOT: String = "res://assets/third_party/hormelz/knight_cc0/source"
const OUTPUT_ROOT: String = "res://assets/third_party/hormelz/knight_cc0"
const SOURCE_CELL_SIZE: int = 256
const RUNTIME_CELL_SIZE: int = 128
const ATLAS_COLUMNS: int = 16
const CROP_RECT: Rect2i = Rect2i(64, 24, RUNTIME_CELL_SIZE, RUNTIME_CELL_SIZE)
const DIRECTIONS: Array[Dictionary] = [
	{"name": "south", "source": 8},
	{"name": "south_west", "source": 1},
	{"name": "west", "source": 2},
	{"name": "north_west", "source": 3},
	{"name": "north", "source": 4},
	{"name": "north_east", "source": 5},
	{"name": "east", "source": 6},
	{"name": "south_east", "source": 7},
]
const CLIPS: Array[Dictionary] = [
	{"folder": "Idle", "stem": "Idle", "output": "hero_idle_atlas.png", "frames": 17},
	{"folder": "Run", "stem": "Run", "output": "hero_move_atlas.png", "frames": 8},
	{"folder": "Attack", "stem": "Attack", "output": "hero_unarmed_atlas.png", "frames": 15},
	{"folder": "SpinAttack", "stem": "SpinAttack", "output": "hero_melee_atlas.png", "frames": 17},
	{"folder": "Draw", "stem": "Draw", "output": "hero_ranged_atlas.png", "frames": 7},
	{"folder": "Cast", "stem": "Cast", "output": "hero_magic_atlas.png", "frames": 10},
	{"folder": "Impact", "stem": "Impact", "output": "hero_hit_atlas.png", "frames": 9},
	{"folder": "Die", "stem": "Die", "output": "hero_death_atlas.png", "frames": 27, "crop": Rect2i(48, 16, 160, 160)},
]

func _init() -> void:
	var errors: Array[String] = []
	for clip: Dictionary in CLIPS:
		errors.append_array(_build_clip(clip))
	if errors.is_empty():
		print("Built %d production hero atlases from the retained CC0 source." % CLIPS.size())
		quit(0)
		return
	for message: String in errors:
		push_error(message)
	quit(1)

func _build_clip(clip: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var expected_frames := int(clip.frames)
	var crop: Rect2i = clip.get("crop", CROP_RECT) as Rect2i
	var total_frames := expected_frames * DIRECTIONS.size()
	var rows := ceili(float(total_frames) / float(ATLAS_COLUMNS))
	var atlas := Image.create(ATLAS_COLUMNS * RUNTIME_CELL_SIZE, rows * RUNTIME_CELL_SIZE, false, Image.FORMAT_RGBA8)
	atlas.fill(Color(0, 0, 0, 0))
	for direction_index: int in DIRECTIONS.size():
		var source_direction := int(DIRECTIONS[direction_index].source)
		var base_path := "%s/%s/Knight_%s_dir%d" % [SOURCE_ROOT, String(clip.folder), String(clip.stem), source_direction]
		var source := Image.load_from_file(base_path + ".png")
		if source == null or source.is_empty():
			errors.append("missing hero source sheet: %s.png" % base_path)
			continue
		var metadata_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(base_path + ".json"))
		if not metadata_value is Dictionary:
			errors.append("invalid hero frame metadata: %s.json" % base_path)
			continue
		var frames: Array = (metadata_value as Dictionary).get("frames", []) as Array
		if frames.size() != expected_frames:
			errors.append("unexpected frame count for %s: expected %d, got %d" % [base_path, expected_frames, frames.size()])
			continue
		for frame_index: int in frames.size():
			var frame_data := (frames[frame_index] as Dictionary).get("frame", {}) as Dictionary
			var source_rect := Rect2i(int(frame_data.get("x", 0)), int(frame_data.get("y", 0)), int(frame_data.get("w", 0)), int(frame_data.get("h", 0)))
			if source_rect.size != Vector2i(SOURCE_CELL_SIZE, SOURCE_CELL_SIZE):
				errors.append("unexpected source cell for %s frame %d: %s" % [base_path, frame_index, source_rect])
				continue
			var source_cell := source.get_region(source_rect)
			var used := source_cell.get_used_rect()
			if used.has_area() and not crop.encloses(used):
				errors.append("hero crop would clip %s frame %d used=%s crop=%s" % [base_path, frame_index, used, crop])
				continue
			var packed_index := direction_index * expected_frames + frame_index
			var destination := Vector2i(posmod(packed_index, ATLAS_COLUMNS), packed_index / ATLAS_COLUMNS) * RUNTIME_CELL_SIZE
			var runtime_frame := source_cell.get_region(crop)
			if runtime_frame.get_size() != Vector2i(RUNTIME_CELL_SIZE, RUNTIME_CELL_SIZE):
				runtime_frame.resize(RUNTIME_CELL_SIZE, RUNTIME_CELL_SIZE, Image.INTERPOLATE_NEAREST)
			atlas.blit_rect(runtime_frame, Rect2i(Vector2i.ZERO, runtime_frame.get_size()), destination)
	var output_path := OUTPUT_ROOT.path_join(String(clip.output))
	if errors.is_empty():
		var result := atlas.save_png(output_path)
		if result != OK:
			errors.append("could not save hero runtime atlas %s: %s" % [output_path, error_string(result)])
	return errors
