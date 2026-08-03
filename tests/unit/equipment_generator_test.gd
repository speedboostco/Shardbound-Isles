extends RefCounted

func run(support: TestSupport) -> void:
	var first := EquipmentGenerator.generate(424242)
	var repeated := EquipmentGenerator.generate(424242)
	support.expect(first == repeated, "same equipment seed must repeat exactly")
	support.expect(first.get("seed") == 424242, "generated equipment records its seed")
	support.expect(first.get("archetype") in ["melee", "ranged", "magic"], "archetype must be supported")
	support.expect(int(first.get("power", 0)) >= 4, "equipment power must meet the starter floor")
	support.expect(not String(first.get("id", "")).is_empty(), "equipment must have a stable ID")

