extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> Dictionary:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var metrics := world.run_scripted_smoke()
	await scene_tree.process_frame
	support.expect(metrics.get("seed") == 424242, "smoke scenario must record the fixed seed")
	support.expect(int(metrics.get("wood", 0)) >= 3, "smoke scenario must gather a resource")
	support.expect(metrics.get("enemies_defeated") == 1, "smoke scenario must defeat one enemy")
	support.expect(metrics.get("items_collected") == 1, "smoke scenario must collect equipment")
	support.expect(not Dictionary(metrics.get("item", {})).is_empty(), "smoke scenario must report generated equipment")
	world.queue_free()
	await scene_tree.process_frame
	return metrics

