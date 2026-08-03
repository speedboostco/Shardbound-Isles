extends RefCounted

const ProductionScript := preload("res://src/domain/wood_production.gd")

func run(support: TestSupport) -> void:
	var production: Variant = ProductionScript.new()
	production.advance(1.9)
	support.expect(production.stored_wood == 0, "production must not complete before its interval")
	production.advance(0.1)
	support.expect(production.stored_wood == 1, "one exact interval must produce one wood")
	var chunked: Variant = ProductionScript.new()
	for _step: int in range(12):
		chunked.advance(0.5)
	var single_step: Variant = ProductionScript.new()
	single_step.advance(6.0)
	support.expect(chunked.stored_wood == single_step.stored_wood and chunked.stored_wood == 3, "production must be independent of update chunk size")
	single_step.advance(100.0)
	support.expect(single_step.stored_wood == 6, "production storage must respect its cap")
	var collected: int = single_step.collect()
	support.expect(collected == 6 and single_step.stored_wood == 0, "collection must transfer and clear all stored wood")
