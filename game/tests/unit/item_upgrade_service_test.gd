extends RefCounted

const UpgradeScript := preload("res://game/core/item_upgrade_service.gd")

func run(support: TestSupport) -> void:
	var affixes: Array[Dictionary] = [{"id": "swift", "stat": "attack_speed", "operation": "add", "value": 0.1}]
	var item := {"id": "blade", "power": 10, "damage": 10, "upgrade_level": 0, "affixes": affixes, "legendary_effects": ["chain_mining"]}
	support.expect(UpgradeScript.cost_for_next(0) == {"scrap": 2, "moonleaf": 0}, "first upgrade must have predictable low cost")
	support.expect(UpgradeScript.cost_for_next(6) == {"scrap": 14, "moonleaf": 1}, "upgrade to +7 must introduce the rare resource")
	support.expect(UpgradeScript.cost_for_next(10).is_empty(), "+10 must be the hard upgrade cap")
	support.expect(UpgradeScript.power_bonus(0) == 0 and UpgradeScript.power_bonus(10) == 5, "upgrade power must be bounded to five points")
	var preview: Dictionary = UpgradeScript.preview(item, {"scrap": 2, "moonleaf": 0})
	support.expect(bool(preview.ok) and preview.from_level == 0 and preview.to_level == 1 and preview.power_after == 11, "preview must show exact before/after result")
	var protected: Dictionary = UpgradeScript.apply(item, {"scrap": 2, "moonleaf": 0}, false)
	support.expect(not bool(protected.success) and protected.reason == "confirmation_required" and protected.item == item, "upgrade must require explicit confirmation and preserve the original")
	var upgraded: Dictionary = UpgradeScript.apply(item, {"scrap": 2, "moonleaf": 0}, true)
	support.expect(bool(upgraded.success) and upgraded.item.upgrade_level == 1 and upgraded.item.power == 11 and upgraded.resources.scrap == 0, "confirmed upgrade must apply level, power, and exact cost")
	support.expect(upgraded.item.affixes == affixes and upgraded.item.legendary_effects == ["chain_mining"], "upgrade must preserve affixes and legendary behavior")
	var poor: Dictionary = UpgradeScript.preview(item, {"scrap": 0, "moonleaf": 0})
	support.expect(not bool(poor.ok) and poor.missing == {"scrap": 2}, "upgrade preview must explain missing resources")
	var current := item
	var resources := {"scrap": 200, "moonleaf": 10}
	for _level: int in range(10):
		var result: Dictionary = UpgradeScript.apply(current, resources, true)
		current = result.item
		resources = result.resources
	support.expect(current.upgrade_level == 10 and current.power == 15 and current.affixes == affixes, "ten upgrades must reach the predictable cap without destroying item identity")
	var capped: Dictionary = UpgradeScript.apply(current, resources, true)
	support.expect(not bool(capped.success) and capped.reason == "maximum_level" and capped.item == current, "attempt beyond +10 must be safe and non-destructive")
	support.expect(UpgradeScript.power_bonus(10) < int(item.power), "sharpening must remain a bounded secondary source of power")
