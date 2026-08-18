class_name TechnologyTreeView
extends Control

const NODE_SIZE := Vector2(190.0, 72.0)
const NODE_MARGIN := Vector2(104.0, 52.0)

var _entries: Array[Dictionary] = []
var _learned: Array[String] = []
var _selected_id: String = ""
var _resources: Dictionary = {}

func configure(entries: Array[Dictionary], learned_ids: Array[String], selected_id: String, resources: Dictionary) -> void:
	_entries = entries.duplicate(true)
	_learned = learned_ids.duplicate()
	_selected_id = selected_id
	_resources = resources.duplicate(true)
	queue_redraw()

func node_count() -> int:
	return _entries.size()

func _draw() -> void:
	if _entries.is_empty():
		return
	for entry: Dictionary in _entries:
		var destination := _node_center(entry)
		for prerequisite_value: Variant in entry.get("prerequisites", []):
			var source_entry := _definition(String(prerequisite_value))
			if source_entry.is_empty():
				continue
			var source := _node_center(source_entry)
			var connection_color := Color("59d6a5") if String(prerequisite_value) in _learned else Color("334a50")
			draw_line(source, destination, Color(0.015, 0.035, 0.04, 0.95), 8.0, true)
			draw_line(source, destination, connection_color, 3.0, true)
	for entry: Dictionary in _entries:
		_draw_node(entry)

func _draw_node(entry: Dictionary) -> void:
	var technology_id := String(entry.get("id", ""))
	var center := _node_center(entry)
	var rect := Rect2(center - NODE_SIZE * 0.5, NODE_SIZE)
	var state := _node_state(entry)
	var accent := _state_color(state, String(entry.get("category", "exploration")))
	var selected := technology_id == _selected_id
	draw_rect(rect.grow(5.0 if selected else 3.0), Color(0.02, 0.045, 0.055, 0.96), true)
	draw_rect(rect, Color(0.045, 0.09, 0.105, 0.98), true)
	draw_rect(rect, Color("fff09b") if selected else accent, false, 4.0 if selected else 2.0)
	var icon_rect := Rect2(rect.position + Vector2(10.0, 12.0), Vector2(48.0, 48.0))
	draw_texture_rect(ItemIconLibrary.texture(String(entry.get("icon_id", "fallback"))), icon_rect, false, Color.WHITE if state != "locked" else Color(0.44, 0.5, 0.52, 0.85))
	var font := ThemeDB.fallback_font
	var text_color := Color("f4fbeb") if state != "locked" else Color("7f9091")
	draw_string(font, rect.position + Vector2(66.0, 28.0), String(entry.get("name", "Technology")).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 116.0, 11, text_color)
	draw_string(font, rect.position + Vector2(66.0, 52.0), state.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 112.0, 11, accent)
	if state == "learned":
		draw_circle(rect.position + Vector2(177.0, 12.0), 7.0, Color("59d6a5"))
		draw_line(rect.position + Vector2(173.0, 12.0), rect.position + Vector2(176.0, 15.0), Color("082d27"), 2.0)
		draw_line(rect.position + Vector2(176.0, 15.0), rect.position + Vector2(181.0, 8.0), Color("082d27"), 2.0)

func _node_center(entry: Dictionary) -> Vector2:
	var available_width := maxf(1.0, size.x - NODE_MARGIN.x * 2.0)
	var available_height := maxf(1.0, size.y - NODE_MARGIN.y * 2.0)
	return Vector2(
		NODE_MARGIN.x + available_width * (float(int(entry.get("column", 0))) / 2.0),
		NODE_MARGIN.y + available_height * (float(int(entry.get("row", 0))) / 2.0)
	)

func _definition(technology_id: String) -> Dictionary:
	for entry: Dictionary in _entries:
		if String(entry.get("id", "")) == technology_id:
			return entry
	return {}

func _node_state(entry: Dictionary) -> String:
	var technology_id := String(entry.get("id", ""))
	if technology_id in _learned:
		return "learned"
	for prerequisite_value: Variant in entry.get("prerequisites", []):
		if String(prerequisite_value) not in _learned:
			return "locked"
	for resource_value: Variant in entry.get("cost", {}):
		if int(_resources.get(String(resource_value), 0)) < int(entry.cost[resource_value]):
			return "gather"
	return "ready"

func _state_color(state: String, category: String) -> Color:
	match state:
		"learned": return Color("59d6a5")
		"locked": return Color("526468")
		"gather": return Color("e5ad55")
		_:
			match category:
				"combat": return Color("ff795f")
				"arcane": return Color("b98cff")
				"world": return Color("63d9e6")
				_: return Color("9ad46f")
