extends RefCounted

const CraftingScript := preload("res://src/domain/crafting_service.gd")

func run(support: TestSupport) -> void:
	var crafting: Variant = CraftingScript.new()
	support.expect(not crafting.can_craft(2, 2, false), "recipe must reject insufficient wood")
	support.expect(not crafting.can_craft(3, 1, false), "recipe must reject insufficient scrap")
	support.expect(crafting.can_craft(3, 2, false), "recipe must accept its exact costs")
	var result: Dictionary = crafting.craft(3, 2, false)
	support.expect(result.get("success") == true, "affordable recipe must craft successfully")
	support.expect(result.get("wood_spent") == 3 and result.get("scrap_spent") == 2, "craft result must state exact deductions")
	support.expect(result.get("maximum_health_bonus") == 2, "Reinforced Heart must grant two maximum health")
	var repeated: Dictionary = crafting.craft(10, 10, true)
	support.expect(repeated.get("success") == false and repeated.get("reason") == "already_crafted", "unique recipe must reject duplicate crafting")
	var poor: Dictionary = crafting.craft(0, 0, false)
	support.expect(poor.get("success") == false and poor.get("reason") == "insufficient_resources", "failed craft must explain insufficient resources")
