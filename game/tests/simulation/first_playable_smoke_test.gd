extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> Dictionary:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	var metrics := world.run_scripted_smoke()
	var repeated_world := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(repeated_world)
	await scene_tree.process_frame
	var repeated_metrics := repeated_world.run_scripted_smoke()
	support.expect(metrics.get("seed") == 424242, "smoke scenario must record the fixed seed")
	support.expect(int(metrics.get("movement_steps", 0)) > 0, "smoke scenario must move between gameplay targets")
	support.expect(metrics.get("wood") == 3, "smoke scenario must gather exact deterministic wood")
	support.expect(metrics.get("stone") == 2, "smoke scenario must gather exact deterministic stone")
	support.expect(metrics.get("enemies_defeated") == 2, "smoke scenario must defeat both Slimes")
	support.expect(metrics.get("items_collected") == 1, "smoke scenario must collect equipment")
	var item := Dictionary(metrics.get("item", {}))
	support.expect(item.has("item_id") and item.has("damage") and item.has("attack_speed"), "smoke scenario must report canonical deterministic weapon data")
	support.expect(metrics.get("equipped_id") == item.get("item_id"), "smoke scenario must equip the collected weapon")
	support.expect(int(metrics.get("equipped_damage", 0)) > int(metrics.get("unarmed_damage", 0)), "equipped weapon must increase real attack damage")
	support.expect(float(metrics.get("equipped_attack_speed", 0.0)) > 1.0, "equipped Tideglass Bow must increase real attack speed")
	support.expect(int(metrics.get("equipped_hits", 99)) < int(metrics.get("unarmed_hits", 0)), "equipped weapon must kill the second Slime in fewer hits")
	support.expect(repeated_metrics == metrics, "fixed-seed M1 scenario must repeat exactly")
	world.queue_free()
	repeated_world.queue_free()
	await scene_tree.process_frame
	return metrics
