extends SceneTree

var support := TestSupport.new()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var suite := _requested_suite()
	if suite in ["all", "unit"]:
		var unit_test: Variant = load("res://tests/unit/equipment_generator_test.gd").new()
		unit_test.run(support)
		var inventory_test: Variant = load("res://tests/unit/equipment_inventory_test.gd").new()
		inventory_test.run(support)
		var crafting_test: Variant = load("res://tests/unit/crafting_service_test.gd").new()
		crafting_test.run(support)
		var production_test: Variant = load("res://tests/unit/wood_production_test.gd").new()
		production_test.run(support)
		var save_test: Variant = load("res://tests/unit/save_service_test.gd").new()
		save_test.run(support)
	if suite in ["all", "integration"]:
		var integration_test: Variant = load("res://tests/integration/gameplay_flow_test.gd").new()
		await integration_test.run(support, self)
		var equipment_ui_test: Variant = load("res://tests/integration/equipment_ui_flow_test.gd").new()
		await equipment_ui_test.run(support, self)
		var workbench_test: Variant = load("res://tests/integration/workbench_flow_test.gd").new()
		await workbench_test.run(support, self)
		var tidecatcher_test: Variant = load("res://tests/integration/tidecatcher_flow_test.gd").new()
		await tidecatcher_test.run(support, self)
		var save_load_test: Variant = load("res://tests/integration/save_load_flow_test.gd").new()
		await save_load_test.run(support, self)
	if suite in ["all", "simulation"]:
		var simulation_test: Variant = load("res://tests/simulation/first_playable_smoke_test.gd").new()
		var metrics: Dictionary = await simulation_test.run(support, self)
		print("SMOKE_METRICS %s" % JSON.stringify(metrics))
	print("TEST_RESULT suite=%s assertions=%d failures=%d" % [suite, support.assertions, support.failures.size()])
	quit(0 if support.failures.is_empty() else 1)

func _requested_suite() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--suite="):
			return argument.trim_prefix("--suite=")
	return "all"
