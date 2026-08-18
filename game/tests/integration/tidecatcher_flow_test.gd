extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var world := (load("res://game/content/world.tscn") as PackedScene).instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(world)
	await scene_tree.process_frame
	support.expect(not world.build_tidecatcher(), "Tidecatcher must remain locked before the heart is crafted")
	world.reinforced_heart_crafted = true
	world.refresh_all_ui()
	support.expect(world.build_tidecatcher(), "crafted heart must unlock Tidecatcher construction")
	support.expect(world.tidecatcher.active and world.hud.is_tidecatcher_visible(), "construction must activate visible building and HUD status")
	var collision := world.tidecatcher.get_node_or_null("CollisionShape2D") as CollisionShape2D
	support.expect(collision != null and not collision.disabled, "active Tidecatcher must be a solid world object")
	support.expect(not world.build_tidecatcher(), "Tidecatcher construction must reject duplicates")
	world.tidecatcher.advance_production(6.0)
	support.expect(world.tidecatcher.stored_wood() == 3, "six seconds must deterministically produce three wood")
	world.player.global_position = world.tidecatcher.global_position
	world.tidecatcher.collect_if_near(world.player.global_position)
	support.expect(world.wood == 3, "nearby collection must update authoritative wood inventory")
	support.expect(world.tidecatcher.stored_wood() == 0, "nearby collection must empty building storage")
	support.expect(world.hud.get_automation_feedback().contains("+3 WOOD"), "automatic collection must provide visible feedback")
	world.queue_free()
	await scene_tree.process_frame
