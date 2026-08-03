extends RefCounted

func run(support: TestSupport, scene_tree: SceneTree) -> void:
	var scene := load("res://game/content/world.tscn") as PackedScene
	var source := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(source)
	await scene_tree.process_frame
	var item := EquipmentGenerator.generate(424242)
	source._on_pickup_collected("equipment", item)
	source.equip_selected_item(0)
	source.wood = 5
	source.stone = 2
	source.equipment_inventory.scrap = 2
	source.reinforced_heart_crafted = true
	source.runed_whetstone_crafted = true
	source.player.maximum_health = 12
	source.player.health = 9
	source.player.global_position = Vector2(44.0, -77.0)
	source.build_tidecatcher()
	source.tidecatcher.restore_state(true, 4, source.player)
	var path := "user://save-load-integration.json"
	support.expect(source.save_game(path), "world must save scoped state to disk")
	var restored := scene.instantiate() as FirstPlayableWorld
	scene_tree.root.add_child(restored)
	await scene_tree.process_frame
	support.expect(restored.load_game(path), "fresh world must load valid save")
	support.expect(restored.player.health == 9 and restored.player.maximum_health == 12, "load must restore player health")
	support.expect(restored.player.global_position.is_equal_approx(Vector2(44.0, -77.0)), "load must restore player position")
	support.expect(restored.wood == 5 and restored.stone == 2 and restored.equipment_inventory.scrap == 2, "load must restore wood, stone, and scrap")
	support.expect(restored.equipment.size() == 1 and restored.equipment[0].get("seed") == 424242, "load must restore deterministic equipment data")
	support.expect(restored.equipment_inventory.equipped_id == String(item.id) and restored.player.attack_damage == 7, "load must restore equipped ID and Whetstone-derived damage")
	support.expect(restored.reinforced_heart_crafted and restored.runed_whetstone_crafted and restored.tidecatcher_built, "load must restore progression and construction")
	support.expect(restored.tidecatcher.stored_wood() == 4, "load must restore production storage")
	restored.open_system_menu()
	await scene_tree.process_frame
	support.expect(restored.hud.is_system_menu_open() and restored.hud.has_valid_action_focus(), "system menu must open with controller focus")
	support.expect(restored.hud.get_system_feedback().contains("LOADED"), "successful load must provide visible feedback")
	var before := restored.snapshot_state()
	support.expect(not restored.apply_save_payload("{bad"), "malformed payload must be rejected")
	support.expect(restored.snapshot_state() == before, "rejected load must not mutate live state")
	source.queue_free()
	restored.queue_free()
	await scene_tree.process_frame
