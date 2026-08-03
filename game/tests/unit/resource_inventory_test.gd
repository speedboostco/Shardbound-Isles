extends RefCounted

const SCRIPT_PATH: String = "res://game/core/resource_inventory.gd"

var changes: Array[Dictionary] = []

func run(support: TestSupport) -> void:
	var inventory_script: Variant = load(SCRIPT_PATH)
	support.expect(inventory_script != null, "resource inventory must load")
	if inventory_script == null:
		return
	var inventory: Variant = inventory_script.new()
	inventory.changed.connect(_on_changed)
	support.expect(inventory.add("wood", 3), "positive resource additions must succeed atomically")
	support.expect(inventory.amount("wood") == 3, "added amount must be queryable by resource ID")
	support.expect(changes.size() == 1 and changes[0].delta == 3 and changes[0].amount == 3, "successful addition must emit one exact change")
	support.expect(not inventory.add("wood", -1) and inventory.amount("wood") == 3, "negative additions must be rejected without mutation")
	support.expect(inventory.remove("wood", 2) and inventory.amount("wood") == 1, "available resources must be removed atomically")
	support.expect(not inventory.remove("wood", 2) and inventory.amount("wood") == 1, "insufficient removal must leave state unchanged")
	support.expect(not inventory.remove("wood", -1), "negative removals must be rejected")
	support.expect(inventory.set_amount("stone", 4) and inventory.amount("stone") == 4, "explicit nonnegative restoration must succeed")
	support.expect(not inventory.set_amount("stone", -1) and inventory.amount("stone") == 4, "restoration must never create negative inventory")
	support.expect(inventory.amount("missing") == 0, "unknown resource IDs must read as zero")
	support.expect(inventory.entries() == {"stone": 4, "wood": 1}, "serialized entries must contain stable resource IDs and quantities")

func _on_changed(resource_id: String, amount: int, delta: int) -> void:
	changes.append({"resource_id": resource_id, "amount": amount, "delta": delta})
