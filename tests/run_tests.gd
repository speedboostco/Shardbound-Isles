extends SceneTree

var support := TestSupport.new()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var suite := _requested_suite()
	if suite in ["all", "unit"]:
		for definition: Dictionary in [
			{"path": "res://tests/unit/equipment_generator_test.gd", "assertions": 5},
			{"path": "res://tests/unit/equipment_inventory_test.gd", "assertions": 9},
			{"path": "res://tests/unit/crafting_service_test.gd", "assertions": 8},
			{"path": "res://tests/unit/wood_production_test.gd", "assertions": 7},
			{"path": "res://tests/unit/save_service_test.gd", "assertions": 11},
			{"path": "res://tests/unit/island_shard_generator_test.gd", "assertions": 10},
			{"path": "res://tests/unit/ranged_attack_pattern_test.gd", "assertions": 5},
			{"path": "res://tests/unit/boss_attack_pattern_test.gd", "assertions": 6},
			{"path": "res://tests/unit/rift_rules_test.gd", "assertions": 5},
			{"path": "res://tests/unit/legendary_pulse_targeting_test.gd", "assertions": 4},
		]:
			var path := String(definition.path)
			var test: Variant = _instantiate_test(path)
			if test != null:
				var before := support.assertions
				test.run(support)
				support.require_assertion_count(support.assertions - before, int(definition.assertions), path)
	if suite in ["all", "integration"]:
		for definition: Dictionary in [
			{"path": "res://tests/integration/gameplay_flow_test.gd", "assertions": 7},
			{"path": "res://tests/integration/equipment_ui_flow_test.gd", "assertions": 11},
			{"path": "res://tests/integration/workbench_flow_test.gd", "assertions": 12},
			{"path": "res://tests/integration/tidecatcher_flow_test.gd", "assertions": 8},
			{"path": "res://tests/integration/save_load_flow_test.gd", "assertions": 13},
			{"path": "res://tests/integration/island_shard_flow_test.gd", "assertions": 26},
			{"path": "res://tests/integration/ranged_combat_flow_test.gd", "assertions": 12},
			{"path": "res://tests/integration/boss_encounter_flow_test.gd", "assertions": 11},
			{"path": "res://tests/integration/rift_flow_test.gd", "assertions": 13},
			{"path": "res://tests/integration/legendary_pulse_flow_test.gd", "assertions": 10},
		]:
			var path := String(definition.path)
			var test: Variant = _instantiate_test(path)
			if test != null:
				var before := support.assertions
				await test.run(support, self)
				support.require_assertion_count(support.assertions - before, int(definition.assertions), path)
	if suite in ["all", "simulation"]:
		var simulation_test: Variant = _instantiate_test("res://tests/simulation/first_playable_smoke_test.gd")
		if simulation_test != null:
			var smoke_before := support.assertions
			var metrics: Dictionary = await simulation_test.run(support, self)
			support.require_assertion_count(support.assertions - smoke_before, 5, "res://tests/simulation/first_playable_smoke_test.gd")
			print("SMOKE_METRICS %s" % JSON.stringify(metrics))
		var rift_simulation: Variant = _instantiate_test("res://tests/simulation/rift_repeat_simulation_test.gd")
		if rift_simulation != null:
			var rift_before := support.assertions
			var rift_metrics: Dictionary = await rift_simulation.run(support, self)
			support.require_assertion_count(support.assertions - rift_before, 5, "res://tests/simulation/rift_repeat_simulation_test.gd")
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
