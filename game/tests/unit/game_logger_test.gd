extends RefCounted

const SCRIPT_PATH: String = "res://game/core/game_logger.gd"

var captured_lines: Array[String] = []

func run(support: TestSupport) -> void:
	var logger_script: Variant = load(SCRIPT_PATH)
	support.expect(logger_script != null, "game logger implementation must load")
	if logger_script == null:
		return
	support.expect(logger_script.CATEGORIES == ["GAMEPLAY", "LOOT", "WORLD", "SAVE", "PERFORMANCE", "ERROR"], "logger must expose the agreed categories")

	var logger: Variant = logger_script.new(false, Callable(self, "_capture"))
	logger.debug("GAMEPLAY", "run started", {"event": "start"})
	support.expect(captured_lines.is_empty(), "disabled debug logging must emit nothing")
	logger.error("SAVE", "write failed", {"path": "user://slot.json", "reason": "denied"})
	support.expect(captured_lines.size() == 1, "errors must emit even when debug logging is disabled")
	support.expect(captured_lines[0].contains("[ERROR][SAVE]"), "error output must include severity and category")
	support.expect(captured_lines[0].contains("\"path\":\"user://slot.json\""), "error output must include structured context")

	logger.debug_enabled = true
	logger.debug("GAMEPLAY", "run started", {"event": "start"})
	support.expect(captured_lines.size() == 2, "debug logging must be switchable at runtime")
	support.expect(captured_lines[1].contains("[DEBUG][GAMEPLAY]"), "debug output must include its category")
	support.expect(captured_lines[1].contains("\"event\":\"start\""), "debug output must include structured context")
	logger.error("UNKNOWN", "bad category", {"operation": "test"})
	support.expect(captured_lines[2].contains("[ERROR][ERROR]"), "unknown categories must be normalized to ERROR")

func _capture(line: String) -> void:
	captured_lines.append(line)
