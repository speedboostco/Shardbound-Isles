class_name TestReport
extends RefCounted

func build_xml(suite: String, records: Array[Dictionary], assertion_count: int) -> String:
	var failure_count := 0
	for record: Dictionary in records:
		if not (record.get("failures", []) as Array).is_empty():
			failure_count += 1
	var lines: Array[String] = [
		"<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
		"<testsuite name=\"%s\" tests=\"%d\" failures=\"%d\" assertions=\"%d\">" % [_escape(suite), records.size(), failure_count, assertion_count],
	]
	for record: Dictionary in records:
		var name := _escape(String(record.get("name", "unnamed")))
		var classname := _escape(String(record.get("classname", suite)))
		var assertions := int(record.get("assertions", 0))
		var failures := record.get("failures", []) as Array
		if failures.is_empty():
			lines.append("  <testcase classname=\"%s\" name=\"%s\" assertions=\"%d\" />" % [classname, name, assertions])
			continue
		lines.append("  <testcase classname=\"%s\" name=\"%s\" assertions=\"%d\">" % [classname, name, assertions])
		for failure: Variant in failures:
			var escaped_failure := _escape(String(failure))
			lines.append("    <failure message=\"%s\">%s</failure>" % [escaped_failure, escaped_failure])
		lines.append("  </testcase>")
	lines.append("</testsuite>")
	return "\n".join(lines) + "\n"

func write(path: String, suite: String, records: Array[Dictionary], assertion_count: int) -> int:
	var absolute_path := ProjectSettings.globalize_path(path)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	if directory_error not in [OK, ERR_ALREADY_EXISTS]:
		return directory_error
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(build_xml(suite, records, assertion_count))
	file.close()
	return OK

func _escape(value: String) -> String:
	return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&apos;")
