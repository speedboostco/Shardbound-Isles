class_name TechnologyTreeView
extends Control

const NODE_SIZE := Vector2(160.0, 62.0)
const NODE_MARGIN := Vector2(86.0, 38.0)

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
			_draw_connection(source, destination, Color(0.015, 0.035, 0.04, 0.95), 8.0)
			_draw_connection(source, destination, connection_color, 3.0)
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
	var icon_rect := Rect2(rect.position + Vector2(8.0, 11.0), Vector2(40.0, 40.0))
	draw_texture_rect(ItemIconLibrary.texture(String(entry.get("icon_id", "fallback"))), icon_rect, false, Color.WHITE if state != "locked" else Color(0.44, 0.5, 0.52, 0.85))
	var font := ThemeDB.fallback_font
	var text_color := Color("f4fbeb") if state != "locked" else Color("7f9091")
	draw_string(font, rect.position + Vector2(54.0, 24.0), String(entry.get("graph_label", entry.get("name", "Technology"))).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 98.0, 9, text_color)
	draw_string(font, rect.position + Vector2(54.0, 46.0), state.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 94.0, 10, accent)
	if state == "learned":
		draw_circle(rect.position + Vector2(148.0, 10.0), 6.0, Color("59d6a5"))
		draw_line(rect.position + Vector2(145.0, 10.0), rect.position + Vector2(148.0, 13.0), Color("082d27"), 2.0)
		draw_line(rect.position + Vector2(148.0, 13.0), rect.position + Vector2(152.0, 7.0), Color("082d27"), 2.0)

func _node_center(entry: Dictionary) -> Vector2:
	var available_width := maxf(1.0, size.x - NODE_MARGIN.x * 2.0)
	var available_height := maxf(1.0, size.y - NODE_MARGIN.y * 2.0)
	var maximum_column := maxi(1, _maximum_coordinate("column"))
	var maximum_row := maxi(1, _maximum_coordinate("row"))
	return Vector2(
		NODE_MARGIN.x + available_width * (float(int(entry.get("column", 0))) / float(maximum_column)),
		NODE_MARGIN.y + available_height * (float(int(entry.get("row", 0))) / float(maximum_row))
	)

func _draw_connection(source: Vector2, destination: Vector2, color: Color, width: float) -> void:
	var source_edge := source + Vector2(NODE_SIZE.x * 0.5, 0.0)
	var destination_edge := destination - Vector2(NODE_SIZE.x * 0.5, 0.0)
	var middle_x := (source_edge.x + destination_edge.x) * 0.5
	var points := PackedVector2Array([
		source_edge,
		Vector2(middle_x, source_edge.y),
		Vector2(middle_x, destination_edge.y),
		destination_edge,
	])
	draw_polyline(points, color, width, true)

func _maximum_coordinate(key: String) -> int:
	var result := 0
	for entry: Dictionary in _entries:
		result = maxi(result, int(entry.get(key, 0)))
	return result

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
