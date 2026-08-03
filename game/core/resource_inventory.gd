class_name ResourceInventory
extends RefCounted

signal changed(resource_id: String, amount: int, delta: int)

var _amounts: Dictionary = {}

func amount(resource_id: String) -> int:
	return int(_amounts.get(resource_id, 0))

func add(resource_id: String, quantity: int) -> bool:
	if resource_id.is_empty() or quantity <= 0:
		return false
	var updated := amount(resource_id) + quantity
	_amounts[resource_id] = updated
	changed.emit(resource_id, updated, quantity)
	return true

func remove(resource_id: String, quantity: int) -> bool:
	if resource_id.is_empty() or quantity <= 0 or amount(resource_id) < quantity:
		return false
	var updated := amount(resource_id) - quantity
	if updated == 0:
		_amounts.erase(resource_id)
	else:
		_amounts[resource_id] = updated
	changed.emit(resource_id, updated, -quantity)
	return true

func set_amount(resource_id: String, quantity: int) -> bool:
	if resource_id.is_empty() or quantity < 0:
		return false
	var previous := amount(resource_id)
	if quantity == 0:
		_amounts.erase(resource_id)
	else:
		_amounts[resource_id] = quantity
	if quantity != previous:
		changed.emit(resource_id, quantity, quantity - previous)
	return true

func entries() -> Dictionary:
	return _amounts.duplicate(true)
