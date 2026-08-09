extends RefCounted

const MillScript := preload("res://game/core/lumber_mill_simulation.gd")
const CollectorScript := preload("res://game/core/collector_simulation.gd")
const StorageScript := preload("res://game/core/shared_storage.gd")
const OfflineScript := preload("res://game/core/offline_automation.gd")

func run(support: TestSupport) -> void:
	var mill: RefCounted = MillScript.new()
	support.expect(mill.add_input(6) == 0 and mill.input_wood == 6 and mill.output_planks == 0, "lumber mill must keep separate bounded input and output inventories")
	mill.advance(2.9)
	support.expect(mill.output_planks == 0 and mill.progress_ratio() > 0.9, "mill must expose progress before a completed cycle")
	var completed: Dictionary = mill.advance(0.1)
	support.expect(completed.cycles == 1 and mill.input_wood == 4 and mill.output_planks == 1, "one cycle must atomically convert two wood into one plank")
	var chunked: RefCounted = MillScript.new()
	chunked.add_input(12)
	for _step: int in range(12):
		chunked.advance(0.5)
	var single: RefCounted = MillScript.new()
	single.add_input(12)
	single.advance(6.0)
	support.expect(chunked.to_dictionary() == single.to_dictionary(), "production must be independent of frame/update chunk size")
	single.output_planks = MillScript.OUTPUT_CAPACITY
	var wood_before: int = single.input_wood
	single.advance(100.0)
	support.expect(single.blocked_output and single.input_wood == wood_before, "full output must enter a safe blocked state without consuming input")
	var restored: RefCounted = MillScript.new()
	support.expect(restored.restore(mill.to_dictionary()) and is_equal_approx(restored.progress_seconds, mill.progress_seconds), "mill progress and both inventories must restore exactly")

	var collector: RefCounted = CollectorScript.new()
	var candidates: Array[Dictionary] = [
		{"id": "ordinary", "resource_id": "wood", "amount": 3, "position": Vector2(10, 0), "rarity": "ordinary", "owner": "world"},
		{"id": "rare", "resource_id": "moonleaf", "amount": 1, "position": Vector2(20, 0), "rarity": "rare", "owner": "world"},
		{"id": "player", "resource_id": "stone", "amount": 2, "position": Vector2(20, 0), "rarity": "ordinary", "owner": "player"},
		{"id": "encounter", "resource_id": "wood", "amount": 1, "position": Vector2(20, 0), "rarity": "ordinary", "owner": "world", "encounter_reward": true},
		{"id": "distant", "resource_id": "wood", "amount": 1, "position": Vector2(1000, 0), "rarity": "ordinary", "owner": "world"},
	]
	var collection: Dictionary = collector.collect_batch(candidates, Vector2.ZERO)
	support.expect(collection.collected_ids == ["ordinary"] and collector.stored.wood == 3, "collector must gather only ordinary unowned resources inside its radius")
	var many: Array[Dictionary] = []
	for index: int in range(20):
		many.append({"id": "%02d" % index, "resource_id": "stone", "amount": 1, "position": Vector2.ZERO, "rarity": "ordinary", "owner": "world"})
	var bounded: Dictionary = CollectorScript.new().collect_batch(many, Vector2.ZERO)
	support.expect((bounded.collected_ids as Array).size() == CollectorScript.BATCH_LIMIT, "collector work must be bounded per batch")
	var storage: RefCounted = StorageScript.new(5)
	var transfer: Dictionary = collector.flush_to(storage)
	support.expect(transfer == {"wood": 3} and storage.amount("wood") == 3 and collector.total_stored() == 0, "collector must transfer resources into shared storage without loss")
	var overflow: Dictionary = storage.add("stone", 5)
	support.expect(overflow.accepted == 2 and overflow.remainder == 3 and storage.total() == 5, "shared storage must return overflow instead of deleting resources")

	var route_storage: RefCounted = StorageScript.new(24)
	route_storage.add("wood", 12)
	var route_mill: RefCounted = MillScript.new()
	var route: Dictionary = OfflineScript.simulate_mill(route_mill, route_storage, 18.0)
	support.expect(route.cycles == 6 and route.planks_routed == 6 and route_storage.amount("wood") == 0 and route_storage.amount("plank") == 6, "offscreen simulation must route storage through the mill in one deterministic batch")
	support.expect(OfflineScript.safe_elapsed(1000, 900) == 0.0, "clock rollback must never grant production")
	support.expect(OfflineScript.safe_elapsed(0, 999999) == OfflineScript.MAX_CATCH_UP_SECONDS, "offline production must be capped")
	var first_storage: RefCounted = StorageScript.new(24)
	first_storage.add("wood", 8)
	var first_mill: RefCounted = MillScript.new()
	OfflineScript.simulate_mill(first_mill, first_storage, 12.0)
	var second_storage: RefCounted = StorageScript.new(24)
	second_storage.add("wood", 8)
	var second_mill: RefCounted = MillScript.new()
	OfflineScript.simulate_mill(second_mill, second_storage, 6.0)
	OfflineScript.simulate_mill(second_mill, second_storage, 6.0)
	support.expect(first_storage.to_dictionary() == second_storage.to_dictionary() and first_mill.to_dictionary() == second_mill.to_dictionary(), "fixed elapsed automation must be deterministic across batch sizes")
