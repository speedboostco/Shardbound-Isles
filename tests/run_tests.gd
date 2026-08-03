extends SceneTree

var support := TestSupport.new()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var suite := _requested_suite()
	if suite in ["all", "unit"]:
		for path: String in [
			"res://tests/unit/equipment_generator_test.gd",
			"res://tests/unit/equipment_inventory_test.gd",
			"res://tests/unit/crafting_service_test.gd",
			"res://tests/unit/wood_production_test.gd",
			"res://tests/unit/save_service_test.gd",
			"res://tests/unit/island_shard_generator_test.gd",
			"res://tests/unit/ranged_attack_pattern_test.gd",
			"res://tests/unit/boss_attack_pattern_test.gd",
			"res://tests/unit/rift_rules_test.gd",
			"res://tests/unit/legendary_pulse_targeting_test.gd",
		]:
			var test: Variant = _instantiate_test(path)
			if test != null:
				test.run(support)
	if suite in ["all", "integration"]:
		for path: String in [
			"res://tests/integration/gameplay_flow_test.gd",
			"res://tests/integration/equipment_ui_flow_test.gd",
			"res://tests/integration/workbench_flow_test.gd",
			"res://tests/integration/tidecatcher_flow_test.gd",
			"res://tests/integration/save_load_flow_test.gd",
			"res://tests/integration/island_shard_flow_test.gd",
			"res://tests/integration/ranged_combat_flow_test.gd",
			"res://tests/integration/boss_encounter_flow_test.gd",
			"res://tests/integration/rift_flow_test.gd",
			"res://tests/integration/legendary_pulse_flow_test.gd",
		]:
			var test: Variant = _instantiate_test(path)
			if test != null:
				await test.run(support, self)
	if suite in ["all", "simulation"]:
		var simulation_test: Variant = _instantiate_test("res://tests/simulation/first_playable_smoke_test.gd")
		if simulation_test != null:
			var metrics: Dictionary = await simulation_test.run(support, self)
			print("SMOKE_METRICS %s" % JSON.stringify(metrics))
		var rift_simulation: Variant = _instantiate_test("res://tests/simulation/rift_repeat_simulation_test.gd")
		if rift_simulation != null:
			var rift_metrics: Dictionary = await rift_simulation.run(support, self)
			print("RIFT_METRICS %s" % JSON.stringify(rift_metrics))
	print("TEST_RESULT suite=%s assertions=%d failures=%d" % [suite, support.assertions, support.failures.size()])
	quit(0 if support.failures.is_empty() else 1)

func _instantiate_test(path: String) -> Variant:
	var resource: Variant = load(path)
	if resource == null or not resource is Script:
		support.expect(false, "test script must load: %s" % path)
		return null
	var script := resource as Script
	if not script.can_instantiate():
		support.expect(false, "test script must compile: %s" % path)
		return null
	var instance: Variant = script.new()
	if instance == null:
		support.expect(false, "test script must instantiate: %s" % path)
	return instance

func _requested_suite() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--suite="):
			return argument.trim_prefix("--suite=")
	return "all"
