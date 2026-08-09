extends SceneTree

const TestReportScript := preload("res://game/tests/test_report.gd")

var support := TestSupport.new()
var records: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var suite := _requested_suite()
	if suite not in ["all", "unit", "integration", "simulation"]:
		var assertions_before := support.assertions
		var failures_before := support.failures.size()
		support.expect(false, "unknown test suite: %s" % suite)
		_record_result("infrastructure", "suite-selection", assertions_before, failures_before)
		_finish(suite)
		return
	if suite in ["all", "unit"]:
		for definition: Dictionary in [
			{"path": "res://game/tests/unit/tasks_16_30_conformance_test.gd", "assertions": 33},
			{"path": "res://game/tests/unit/m4_recipe_placement_test.gd", "assertions": 18},
			{"path": "res://game/tests/unit/m4_automation_test.gd", "assertions": 14},
			{"path": "res://game/tests/unit/item_upgrade_service_test.gd", "assertions": 12},
			{"path": "res://game/tests/unit/archipelago_model_test.gd", "assertions": 20},
			{"path": "res://game/tests/unit/island_generation_m3_test.gd", "assertions": 24},
			{"path": "res://game/tests/unit/island_modifier_adjacency_test.gd", "assertions": 20},
			{"path": "res://game/tests/unit/island_persistence_test.gd", "assertions": 12},
			{"path": "res://game/tests/unit/loot_generation_test.gd", "assertions": 21},
			{"path": "res://game/tests/unit/equipment_stats_test.gd", "assertions": 19},
			{"path": "res://game/tests/unit/legendary_framework_test.gd", "assertions": 18},
			{"path": "res://game/tests/unit/weapon_combat_rules_test.gd", "assertions": 8},
			{"path": "res://game/tests/unit/loot_policy_test.gd", "assertions": 8},
			{"path": "res://game/tests/unit/movement_rules_test.gd", "assertions": 7},
			{"path": "res://game/tests/unit/interaction_selector_test.gd", "assertions": 6},
			{"path": "res://game/tests/unit/resource_inventory_test.gd", "assertions": 12},
			{"path": "res://game/tests/unit/health_component_test.gd", "assertions": 14},
			{"path": "res://game/tests/unit/weapon_model_test.gd", "assertions": 10},
			{"path": "res://game/tests/unit/seeded_rng_streams_test.gd", "assertions": 9},
			{"path": "res://game/tests/unit/game_logger_test.gd", "assertions": 10},
			{"path": "res://game/tests/unit/test_report_test.gd", "assertions": 11},
			{"path": "res://game/tests/unit/equipment_generator_test.gd", "assertions": 5},
			{"path": "res://game/tests/unit/equipment_inventory_test.gd", "assertions": 15},
			{"path": "res://game/tests/unit/crafting_service_test.gd", "assertions": 18},
			{"path": "res://game/tests/unit/wood_production_test.gd", "assertions": 7},
			{"path": "res://game/tests/unit/save_service_test.gd", "assertions": 16},
			{"path": "res://game/tests/unit/island_shard_generator_test.gd", "assertions": 10},
			{"path": "res://game/tests/unit/ranged_attack_pattern_test.gd", "assertions": 5},
			{"path": "res://game/tests/unit/boss_attack_pattern_test.gd", "assertions": 6},
			{"path": "res://game/tests/unit/rift_rules_test.gd", "assertions": 5},
			{"path": "res://game/tests/unit/legendary_pulse_targeting_test.gd", "assertions": 4},
		]:
			var path := String(definition.path)
			var assertions_before := support.assertions
			var failures_before := support.failures.size()
			var test: Variant = _instantiate_test(path)
			if test != null:
				test.run(support)
				if not support.require_assertion_count(support.assertions - assertions_before, int(definition.assertions), path):
					_record_result("unit", path, assertions_before, failures_before)
					_finish(suite)
					return
			_record_result("unit", path, assertions_before, failures_before)
	if suite in ["all", "integration"]:
		for definition: Dictionary in [
			{"path": "res://game/tests/integration/tasks_16_30_conformance_flow_test.gd", "assertions": 12},
			{"path": "res://game/tests/integration/m4_base_flow_test.gd", "assertions": 28},
			{"path": "res://game/tests/integration/m3_world_loot_flow_test.gd", "assertions": 40},
			{"path": "res://game/tests/integration/m2_loot_flow_test.gd", "assertions": 31},
			{"path": "res://game/tests/integration/m1_scene_contract_test.gd", "assertions": 26},
			{"path": "res://game/tests/integration/slime_obstacle_flow_test.gd", "assertions": 4},
			{"path": "res://game/tests/integration/gameplay_flow_test.gd", "assertions": 10},
			{"path": "res://game/tests/integration/equipment_ui_flow_test.gd", "assertions": 19},
			{"path": "res://game/tests/integration/workbench_flow_test.gd", "assertions": 17},
			{"path": "res://game/tests/integration/tidecatcher_flow_test.gd", "assertions": 8},
			{"path": "res://game/tests/integration/save_load_flow_test.gd", "assertions": 13},
			{"path": "res://game/tests/integration/island_shard_flow_test.gd", "assertions": 26},
			{"path": "res://game/tests/integration/ranged_combat_flow_test.gd", "assertions": 12},
			{"path": "res://game/tests/integration/boss_encounter_flow_test.gd", "assertions": 11},
			{"path": "res://game/tests/integration/rift_flow_test.gd", "assertions": 13},
			{"path": "res://game/tests/integration/legendary_pulse_flow_test.gd", "assertions": 10},
		]:
			var path := String(definition.path)
			var assertions_before := support.assertions
			var failures_before := support.failures.size()
			var test: Variant = _instantiate_test(path)
			if test != null:
				await test.run(support, self)
				if not support.require_assertion_count(support.assertions - assertions_before, int(definition.assertions), path):
					_record_result("integration", path, assertions_before, failures_before)
					_finish(suite)
					return
			_record_result("integration", path, assertions_before, failures_before)
	if suite in ["all", "simulation"]:
		var conformance_path := "res://game/tests/simulation/tasks_16_30_invariant_simulation_test.gd"
		var conformance_before := support.assertions
		var conformance_failures_before := support.failures.size()
		var conformance_simulation: Variant = _instantiate_test(conformance_path)
		if conformance_simulation != null:
			var conformance_metrics: Dictionary = await conformance_simulation.run(support, self)
			if not support.require_assertion_count(support.assertions - conformance_before, 6, conformance_path):
				_record_result("simulation", conformance_path, conformance_before, conformance_failures_before)
				_finish(suite)
				return
			print("TASKS_16_30_METRICS %s" % JSON.stringify(conformance_metrics))
		_record_result("simulation", conformance_path, conformance_before, conformance_failures_before)
		var smoke_path := "res://game/tests/simulation/first_playable_smoke_test.gd"
		var smoke_before := support.assertions
		var smoke_failures_before := support.failures.size()
		var simulation_test: Variant = _instantiate_test(smoke_path)
		if simulation_test != null:
			var metrics: Dictionary = await simulation_test.run(support, self)
			if not support.require_assertion_count(support.assertions - smoke_before, 12, smoke_path):
				_record_result("simulation", smoke_path, smoke_before, smoke_failures_before)
				_finish(suite)
				return
			print("SMOKE_METRICS %s" % JSON.stringify(metrics))
		_record_result("simulation", smoke_path, smoke_before, smoke_failures_before)
		var rift_path := "res://game/tests/simulation/rift_repeat_simulation_test.gd"
		var rift_before := support.assertions
		var rift_failures_before := support.failures.size()
		var rift_simulation: Variant = _instantiate_test(rift_path)
		if rift_simulation != null:
			var rift_metrics: Dictionary = await rift_simulation.run(support, self)
			if not support.require_assertion_count(support.assertions - rift_before, 5, rift_path):
				_record_result("simulation", rift_path, rift_before, rift_failures_before)
				_finish(suite)
				return
			print("RIFT_METRICS %s" % JSON.stringify(rift_metrics))
		_record_result("simulation", rift_path, rift_before, rift_failures_before)
		var m2_path := "res://game/tests/simulation/m2_loot_simulation_test.gd"
		var m2_before := support.assertions
		var m2_failures_before := support.failures.size()
		var m2_simulation: Variant = _instantiate_test(m2_path)
		if m2_simulation != null:
			var m2_metrics: Dictionary = await m2_simulation.run(support, self)
			if not support.require_assertion_count(support.assertions - m2_before, 10, m2_path):
				_record_result("simulation", m2_path, m2_before, m2_failures_before)
				_finish(suite)
				return
			print("M2_METRICS %s" % JSON.stringify(m2_metrics))
		_record_result("simulation", m2_path, m2_before, m2_failures_before)
		var m3_path := "res://game/tests/simulation/m3_world_loot_simulation_test.gd"
		var m3_before := support.assertions
		var m3_failures_before := support.failures.size()
		var m3_simulation: Variant = _instantiate_test(m3_path)
		if m3_simulation != null:
			var m3_metrics: Dictionary = await m3_simulation.run(support, self)
			if not support.require_assertion_count(support.assertions - m3_before, 12, m3_path):
				_record_result("simulation", m3_path, m3_before, m3_failures_before)
				_finish(suite)
				return
			print("M3_METRICS %s" % JSON.stringify(m3_metrics))
		_record_result("simulation", m3_path, m3_before, m3_failures_before)
		var m4_path := "res://game/tests/simulation/m4_automation_simulation_test.gd"
		var m4_before := support.assertions
		var m4_failures_before := support.failures.size()
		var m4_simulation: Variant = _instantiate_test(m4_path)
		if m4_simulation != null:
			var m4_metrics: Dictionary = await m4_simulation.run(support, self)
			if not support.require_assertion_count(support.assertions - m4_before, 10, m4_path):
				_record_result("simulation", m4_path, m4_before, m4_failures_before)
				_finish(suite)
				return
			print("M4_METRICS %s" % JSON.stringify(m4_metrics))
		_record_result("simulation", m4_path, m4_before, m4_failures_before)
	_finish(suite)

func _finish(suite: String) -> void:
	var report_path := _requested_junit_path()
	if not report_path.is_empty():
		var report_error: int = TestReportScript.new().write(report_path, suite, records, support.assertions)
		if report_error != OK:
			support.expect(false, "could not write JUnit report %s: %s" % [report_path, error_string(report_error)])
		else:
			print("JUNIT_REPORT %s" % report_path)
	print("TEST_RESULT suite=%s assertions=%d failures=%d" % [suite, support.assertions, support.failures.size()])
	quit(0 if support.failures.is_empty() else 1)

func _record_result(classname: String, path: String, assertions_before: int, failures_before: int) -> void:
	var result_failures: Array[String] = []
	for index: int in range(failures_before, support.failures.size()):
		result_failures.append(support.failures[index])
	records.append({
		"name": path.get_file().get_basename(),
		"classname": classname,
		"assertions": support.assertions - assertions_before,
		"failures": result_failures,
	})

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

func _requested_junit_path() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--junit="):
			return argument.trim_prefix("--junit=")
	return ""
