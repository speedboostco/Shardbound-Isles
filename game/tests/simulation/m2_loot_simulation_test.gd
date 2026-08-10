extends RefCounted

func run(support: TestSupport, _scene_tree: SceneTree) -> Dictionary:
	var first := _run_scenario()
	var repeated := _run_scenario()
	support.expect(first == repeated, "M2 loot simulation must repeat exactly for fixed seeds")
	support.expect(int(first.generated_items) == 7 and int(first.equipped_slots) == 6, "scenario must generate a mixed loadout and fill every equipment slot")
	support.expect(int(first.derived_max_health) > 10 and float(first.derived_movement_speed) > 240.0, "mixed loadout must produce derived defensive and utility stats")
	support.expect(int(first.salvage_reward) > 0 and int(first.remaining_items) == 6, "scenario must successfully salvage one unprotected item")
	support.expect((first.triggered_effects as Array).has("chain_mining") and (first.triggered_effects as Array).has("burning_smelter") and (first.triggered_effects as Array).has("living_arrows"), "scenario must trigger all three M2 legendary behaviors")
	support.expect(int(first.chain_targets) <= 4 and int(first.chain_targets) > 0, "simulated Chain Mining must remain bounded")
	support.expect(int(first.smelting_charges) == 1, "simulated Burning Smelter must produce exactly one safe fallback charge")
	support.expect(int(first.living_plants) > 0 and int(first.living_plants) <= 3, "simulated Living Arrows must enforce its plant cap")
	support.expect(bool(first.items_valid), "every ordinary generated scenario item must pass item validation")
	support.expect(int(first.weapon_styles) == 3, "simulation must exercise three distinct weapon behavior profiles")
	return first

func _run_scenario() -> Dictionary:
	var inventory := EquipmentInventory.new()
	var definitions := [
		[100001, "sword", "rare"],
		[100002, "iron_helmet", "rare"],
		[100003, "tide_body", "epic"],
		[100004, "swift_boots", "magic"],
		[100005, "coral_ring", "rare"],
		[100006, "storm_amulet", "legendary"],
	]
	var valid := true
	for index: int in definitions.size():
		var definition: Array = definitions[index]
		var item := LootGenerator.generate(int(definition[0]), "m2_sim", 10 + index * 4, String(definition[1]), String(definition[2]))
		valid = LootGenerator.validate_item(item) and valid
		inventory.collect(item)
		inventory.equip(index)
	var spare := LootGenerator.generate(100007, "m2_sim", 16, "bow", "magic")
	valid = LootGenerator.validate_item(spare) and valid
	inventory.collect(spare)
	var salvage_reward := inventory.salvage(6)
	var stats := inventory.derived_stats(StatBlock.default_base_stats())

	var bus := LegendaryEventBus.new()
	var manager := LegendaryBehaviorManager.new(bus)
	var effects: Array[Dictionary] = []
	bus.effect_triggered.connect(func(effect_id: String, payload: Dictionary) -> void: effects.append({"id": effect_id, "payload": payload.duplicate(true)}))
	manager.sync(["chain_mining", "burning_smelter", "living_arrows"])
	var nearby: Array[Dictionary] = []
	for index: int in 10:
		nearby.append({"id": "sim_target_%d" % index, "kind": "enemy", "distance": float(index + 1)})
	bus.emit_resource_hit({"tick": 100, "chain_depth": 0, "source_damage": 8, "targets": nearby})
	bus.emit_enemy_killed({"enemy_id": "sim_burning", "burning": true, "nearby_ores": []})
	for index: int in 100:
		bus.emit_hit({"weapon_type": "bow", "seed": 100008, "attack_index": index, "position": Vector2.ZERO})
	var triggered: Array[String] = []
	var chain_targets := 0
	var smelting_charges := 0
	var living_plants := 0
	for effect: Dictionary in effects:
		var effect_id := String(effect.id)
		if effect_id not in triggered:
			triggered.append(effect_id)
		if effect_id == "chain_mining":
			chain_targets = (effect.payload.targets as Array).size()
		elif effect_id == "burning_smelter":
			smelting_charges = int(effect.payload.get("smelting_charges", 0))
		elif effect_id == "living_arrows":
			living_plants += 1
	var styles: Dictionary = {}
	for base_id: String in ["sword", "bow", "wand"]:
		styles[String((ItemBaseRegistry.get_definition(base_id).attack_profile as Dictionary).style)] = true
	return {
		"seed": 100001,
		"generated_items": 7,
		"remaining_items": inventory.items.size(),
		"equipped_slots": inventory.equipped_slots.size(),
		"derived_max_health": snappedf(float(stats.max_health), 0.001),
		"derived_movement_speed": snappedf(float(stats.movement_speed), 0.001),
		"salvage_reward": salvage_reward,
		"triggered_effects": triggered,
		"chain_targets": chain_targets,
		"smelting_charges": smelting_charges,
		"living_plants": living_plants,
		"items_valid": valid,
		"weapon_styles": styles.size(),
	}
