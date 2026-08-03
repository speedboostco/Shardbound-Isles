extends RefCounted

const SCRIPT_PATH: String = "res://game/tests/test_report.gd"

func run(support: TestSupport) -> void:
	var report_script: Variant = load(SCRIPT_PATH)
	support.expect(report_script != null, "JUnit report implementation must load")
	if report_script == null:
		return
	var report: Variant = report_script.new()
	var records: Array[Dictionary] = [
		{"name": "passes <&\"", "classname": "unit", "assertions": 2, "failures": []},
		{"name": "fails", "classname": "unit", "assertions": 1, "failures": ["broken <&>"]},
	]
	var xml: String = report.build_xml("unit & smoke", records, 3)
	support.expect(xml.begins_with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"), "JUnit output must declare UTF-8 XML")
	support.expect(xml.contains("name=\"unit &amp; smoke\""), "suite names must be XML escaped")
	support.expect(xml.contains("tests=\"2\""), "JUnit output must include the test count")
	support.expect(xml.contains("failures=\"1\""), "JUnit output must include the failure count")
	support.expect(xml.contains("passes &lt;&amp;&quot;"), "test names must be XML escaped")
	support.expect(xml.contains("broken &lt;&amp;&gt;"), "failure messages must be XML escaped")
	support.expect(xml.contains("<testcase classname=\"unit\" name=\"passes &lt;&amp;&quot;\" assertions=\"2\" />"), "passing cases must be represented without a failure node")

	var path := "user://test-results/test-report-contract.xml"
	var write_error: int = report.write(path, "unit & smoke", records, 3)
	support.expect(write_error == OK, "JUnit reports must be writable from CLI tests")
	support.expect(FileAccess.file_exists(path), "JUnit report writer must create the requested file")
	var file := FileAccess.open(path, FileAccess.READ)
	support.expect(file != null and file.get_as_text() == xml, "written JUnit content must match serialized output")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
