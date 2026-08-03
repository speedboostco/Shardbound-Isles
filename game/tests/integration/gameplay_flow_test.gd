extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame

	world.tree.receive_attack(1)
	world.tree.receive_attack(1)
	await scene_tree.process_frame
	var wood_pickup := _find_pickup(world, "wood")
	support.expect(wood_pickup != null, "depleted tree must create a wood pickup")
	wood_pickup.collect_immediately()
	await scene_tree.process_frame
	support.expect(world.wood == 3, "wood pickup must update authoritative world inventory")

	world.stone_node.receive_attack(1)
	support.expect(world.stone_node.damage_stage() == 1 and world.stone_node.remaining_hits == 2, "first stone hit must create distinct crack feedback")
	world.stone_node.receive_attack(1)
	world.stone_node.receive_attack(1)
	await scene_tree.process_frame
	var stone_pickup := _find_pickup(world, "stone")
	support.expect(stone_pickup != null and stone_pickup.payload == 2, "depleted outcrop must create a distinct two-stone pickup")
	stone_pickup.collect_immediately()
	await scene_tree.process_frame
	support.expect(world.stone == 2 and world.hud.get_displayed_stone() == 2 and world.wood == 3, "stone pickup must update its own authoritative HUD resource")

	world.enemy.receive_attack(3)
	await scene_tree.process_frame
	var item_pickup := _find_pickup(world, "equipment")
	support.expect(item_pickup != null, "defeated enemy must create equipment pickup")
	var shard_pickup := _find_pickup(world, "island_shard")
	support.expect(shard_pickup != null, "defeated enemy must create island shard world loot")
	item_pickup.collect_immediately()
	await scene_tree.process_frame
	support.expect(world.enemies_defeated == 1, "enemy defeat must be counted")
	support.expect(world.equipment.size() == 1, "equipment pickup must enter world inventory")
	support.expect(world.equipment[0] == EquipmentGenerator.generate(424242), "enemy loot must use the fixed explicit seed")
	world.queue_free()
	await scene_tree.process_frame

func _find_pickup(world: Node, kind: String) -> WorldPickup:
	for child: Node in world.get_children():
		if child is WorldPickup and (child as WorldPickup).kind == kind:
			return child as WorldPickup
	return null
