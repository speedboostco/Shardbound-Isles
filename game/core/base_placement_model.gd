class_name BasePlacementModel
extends RefCounted

const SOCKETS: Dictionary = {
	"west": Vector2i(-2, -1),
	"north": Vector2i(0, -2),
	"east": Vector2i(2, -1),
	"south": Vector2i(0, 2),
}

var buildings: Dictionary = {}
var preview: Dictionary = {}

func begin_preview(building_id: String, socket_id: String = "west") -> bool:
	if building_id.is_empty() or socket_id not in SOCKETS:
		return false
	preview = {"building_id": building_id, "socket_id": socket_id, "rotation": 0}
	return true

func rotate_preview() -> int:
	if preview.is_empty():
		return 0
	preview["rotation"] = posmod(int(preview.get("rotation", 0)) + 90, 360)
	return int(preview.rotation)

func select_socket(socket_id: String) -> bool:
	if preview.is_empty() or socket_id not in SOCKETS:
		return false
	preview["socket_id"] = socket_id
	return true

func validate_preview(player_cell: Vector2i, blocked_cells: Array[Vector2i] = []) -> Dictionary:
	if preview.is_empty():
		return {"valid": false, "reason": "no_preview"}
	var socket_id := String(preview.socket_id)
	var cell := SOCKETS[socket_id] as Vector2i
	if buildings.has(socket_id):
		return {"valid": false, "reason": "occupied"}
	if cell == player_cell:
		return {"valid": false, "reason": "player_overlap"}
	if cell in blocked_cells:
		return {"valid": false, "reason": "blocked"}
	return {"valid": true, "reason": "ready"}

func commit(player_cell: Vector2i, blocked_cells: Array[Vector2i] = []) -> Dictionary:
	var validation := validate_preview(player_cell, blocked_cells)
	if not bool(validation.valid):
		return validation
	var committed := preview.duplicate(true)
	committed["cell"] = {"x": (SOCKETS[String(preview.socket_id)] as Vector2i).x, "y": (SOCKETS[String(preview.socket_id)] as Vector2i).y}
	buildings[String(preview.socket_id)] = committed
	preview.clear()
	return {"valid": true, "building": committed}

func cancel_preview() -> void:
	preview.clear()

func to_dictionary() -> Dictionary:
	return {"buildings": buildings.duplicate(true)}

static func from_dictionary(data: Dictionary) -> BasePlacementModel:
	if not data.get("buildings", {}) is Dictionary:
		return null
	var model := BasePlacementModel.new()
	for socket_value: Variant in (data.get("buildings") as Dictionary):
		var socket_id := String(socket_value)
		var building_value: Variant = data.buildings[socket_value]
		if socket_id not in SOCKETS or not building_value is Dictionary:
			return null
		var building := building_value as Dictionary
		if String(building.get("building_id", "")) not in ["lumber_mill", "collector", "shared_storage"] or posmod(int(building.get("rotation", -1)), 90) != 0:
			return null
		model.buildings[socket_id] = building.duplicate(true)
	return model

