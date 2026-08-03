extends RefCounted

const InventoryScript := preload("res://src/domain/equipment_inventory.gd")

func run(support: TestSupport) -> void:
	var inventory: Variant = InventoryScript.new()
	var bow := EquipmentGenerator.generate(424242)
	inventory.collect(bow)
	support.expect(inventory.items.size() == 1, "collected equipment must enter inventory")
	support.expect(inventory.comparison_delta(0) == int(bow.power), "comparison must use unarmed power as baseline")
	support.expect(inventory.equip(0), "an owned item must be equippable")
	support.expect(inventory.attack_damage() == 1 + int(bow.power), "equipped power must increase attack damage")
	support.expect(inventory.comparison_delta(0) == 0, "equipped item comparison must be neutral")
	support.expect(inventory.salvage(0) == 0, "equipped item must be protected from salvage")
	support.expect(inventory.unequip(), "equipped item must be removable")
	var reward: int = inventory.salvage(0)
	support.expect(reward == 2, "uncommon starter equipment must salvage for two scrap")
	support.expect(inventory.scrap == 2 and inventory.items.is_empty(), "salvage must remove item and grant scrap")
