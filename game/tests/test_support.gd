class_name TestSupport
extends RefCounted

var failures: Array[String] = []
var assertions: int = 0

func expect(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
		push_error("TEST FAILURE: %s" % message)

func require_assertion_count(actual: int, expected: int, test_path: String) -> bool:
	if actual == expected:
		return true
	var message := "%s completed %d of %d expected assertions" % [test_path, actual, expected]
	failures.append(message)
	push_error("TEST INCOMPLETE: %s" % message)
	return false
