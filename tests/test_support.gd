class_name TestSupport
extends RefCounted

var failures: Array[String] = []
var assertions: int = 0

func expect(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
		push_error("TEST FAILURE: %s" % message)

