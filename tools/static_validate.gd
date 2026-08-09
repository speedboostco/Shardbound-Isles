extends SceneTree

const REQUIRED_DIRECTORIES: Array[String] = [
	"res://game/core",
	"res://game/features",
	"res://game/ui",
	"res://game/content",
	"res://game/tests",
	"res://docs",
	"res://tools",
	"res://build",
]
const REQUIRED_DOCUMENTS: Array[String] = [
	"res://AGENTS.md",
	"res://docs/product/vision.md",
	"res://docs/product/core-loop.md",
	"res://docs/product/product-pillars.md",
	"res://docs/product/non-goals.md",
	"res://docs/product/vertical-slice.md",
	"res://docs/engineering/architecture.md",
	"res://docs/engineering/testing-strategy.md",
]
const GLOBAL_RANDOM_PATTERN: String = "(^|[^A-Za-z0-9_\\.])(randf|randf_range|randfn|randi|randi_range|randomize|seed)\\s*\\("

var failures: Array[String] = []
var random_call_pattern := RegEx.new()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if random_call_pattern.compile(GLOBAL_RANDOM_PATTERN) != OK:
		failures.append("could not compile global-random validation pattern")
	for path: String in REQUIRED_DIRECTORIES:
		if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
			failures.append("required directory is missing: %s" % path)
	for path: String in REQUIRED_DOCUMENTS:
		if not FileAccess.file_exists(path):
			failures.append("required onboarding document is missing: %s" % path)
	var main_scene := String(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene.is_empty() or load(main_scene) == null:
		failures.append("application/run/main_scene must reference a loadable scene")
	_scan_core_directory("res://game/core")
	_validate_m2_definitions()
	_validate_m3_definitions()
	for failure: String in failures:
		push_error("STATIC VALIDATION: %s" % failure)
	print("STATIC_RESULT checks=%d failures=%d" % [REQUIRED_DIRECTORIES.size() + REQUIRED_DOCUMENTS.size() + 9, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _scan_core_directory(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry not in [".", ".."]:
			var child_path := path.path_join(entry)
			if directory.current_is_dir():
				_scan_core_directory(child_path)
			elif entry.ends_with(".gd"):
				_scan_core_script(child_path)
		entry = directory.get_next()
	directory.list_dir_end()

func _scan_core_script(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures.append("could not read domain script: %s" % path)
		return
	var line_number := 0
	while not file.eof_reached():
		line_number += 1
		var line := file.get_line()
		if random_call_pattern.search(line) != null:
			failures.append("global random call in %s:%d" % [path, line_number])

func _validate_m2_definitions() -> void:
	var registries: Array[Dictionary] = [
		{"name": "item base", "path": "res://game/core/item_base_registry.gd"},
		{"name": "rarity", "path": "res://game/core/rarity_rules.gd"},
		{"name": "affix", "path": "res://game/core/affix_registry.gd"},
		{"name": "legendary behavior", "path": "res://game/core/legendary_behavior_registry.gd"},
	]
	for registry: Dictionary in registries:
		var script_value: Variant = load(String(registry.path))
		if script_value == null or not script_value is Script or not (script_value as Script).can_instantiate():
			failures.append("%s registry must load" % String(registry.name))
			continue
		var instance: Variant = (script_value as Script).new()
		for error_value: Variant in instance.validate():
			failures.append("%s definition: %s" % [String(registry.name), String(error_value)])

func _validate_m3_definitions() -> void:
	for registry: Dictionary in [
		{"name": "island modifier", "path": "res://game/core/island_modifier_registry.gd"},
		{"name": "adjacency synergy", "path": "res://game/core/adjacency_synergy_registry.gd"},
	]:
		var script_value: Variant = load(String(registry.path))
		if script_value == null or not script_value is Script or not (script_value as Script).can_instantiate():
			failures.append("%s registry must load" % String(registry.name))
			continue
		var instance: Variant = (script_value as Script).new()
		for error_value: Variant in instance.validate():
			failures.append("%s definition: %s" % [String(registry.name), String(error_value)])
	for seed_value: int in range(9001, 9007):
		for error_value: Variant in IslandShardDefinition.validate_dictionary(IslandShardGenerator.generate(seed_value, 12)):
			failures.append("island shard definition: %s" % String(error_value))
