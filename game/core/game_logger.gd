class_name GameLogger
extends RefCounted

const GAMEPLAY: String = "GAMEPLAY"
const LOOT: String = "LOOT"
const WORLD: String = "WORLD"
const SAVE: String = "SAVE"
const PERFORMANCE: String = "PERFORMANCE"
const ERROR: String = "ERROR"
const CATEGORIES: Array[String] = [GAMEPLAY, LOOT, WORLD, SAVE, PERFORMANCE, ERROR]

var debug_enabled: bool
var _sink: Callable

func _init(debug_enabled_value: bool = false, sink: Callable = Callable()) -> void:
	debug_enabled = debug_enabled_value
	_sink = sink

func debug(category: String, message: String, context: Dictionary = {}) -> void:
	if not debug_enabled:
		return
	_write("DEBUG", _normalized_category(category), message, context)

func error(category: String, message: String, context: Dictionary) -> void:
	_write("ERROR", _normalized_category(category), message, context)

func _normalized_category(category: String) -> String:
	return category if category in CATEGORIES else ERROR

func _write(level: String, category: String, message: String, context: Dictionary) -> void:
	var line := "[%s][%s] %s context=%s" % [level, category, message, JSON.stringify(context)]
	if _sink.is_valid():
		_sink.call(line)
	elif level == "ERROR":
		push_error(line)
	else:
		print(line)
