extends RefCounted

func run(support: TestSupport) -> void:
	var event_bus := LegendaryEventBus.new()
	var manager := LegendaryBehaviorManager.new(event_bus)
	var effects: Array[Dictionary] = []
	event_bus.effect_triggered.connect(func(effect_id: String, payload: Dictionary) -> void: effects.append({"id": effect_id, "payload": payload.duplicate(true)}))
	support.expect(LegendaryBehaviorRegistry.validate().is_empty() and LegendaryBehaviorRegistry.ids().size() >= 4, "legendary registry must map IDs to separate valid behavior components")
	support.expect(manager.sync(["chain_mining"]) and manager.active_ids() == ["chain_mining"], "manager must activate selected legendary behavior")
	var nearby: Array[Dictionary] = []
	for index: int in 12:
		nearby.append({"id": "target_%02d" % index, "kind": "resource" if index % 2 == 0 else "enemy", "distance": float(index + 1)})
	event_bus.emit_resource_hit({"tick": 10, "chain_depth": 0, "source_damage": 8, "targets": nearby})
	support.expect(effects.size() == 1 and String(effects[0].id) == "chain_mining", "resource hit event must reach active Chain Mining behavior")
	support.expect((effects[0].payload.targets as Array).size() <= 4 and int(effects[0].payload.damage) == 4, "Chain Mining must cap targets and apply fractional damage")
	event_bus.emit_resource_hit({"tick": 10, "chain_depth": 0, "source_damage": 8, "targets": nearby})
	support.expect(effects.size() == 1, "Chain Mining cooldown must reject repeated events in the same window")
	event_bus.emit_resource_hit({"tick": 30, "chain_depth": 1, "source_damage": 8, "targets": nearby})
	support.expect(effects.size() == 1, "Chain Mining must reject recursive chain events")
	event_bus.emit_resource_hit({"tick": 30, "chain_depth": 0, "source_damage": 8, "targets": nearby})
	support.expect(effects.size() == 2, "Chain Mining must become available after deterministic cooldown")
	var stress_start := Time.get_ticks_usec()
	for index: int in 1000:
		event_bus.emit_resource_hit({"tick": 100 + index * 20, "chain_depth": index % 7, "source_damage": 3, "targets": nearby})
	var stress_usec := Time.get_ticks_usec() - stress_start
	print("M2_CHAIN_METRICS %s" % JSON.stringify({"events": 1000, "elapsed_usec": stress_usec, "effects": effects.size()}))
	support.expect(effects.size() <= 1002, "Chain Mining stress run must remain bounded without recursion explosion")
	var chain_connections := event_bus.resource_hit.get_connections().size()
	support.expect(manager.sync(["burning_smelter"]) and event_bus.resource_hit.get_connections().size() < chain_connections + 1, "replacing equipment must disconnect prior legendary signals")
	var effects_before_smelter := effects.size()
	event_bus.emit_enemy_killed({"enemy_id": "burned_1", "burning": true, "nearby_ores": []})
	support.expect(effects.size() == effects_before_smelter + 1 and int(effects.back().payload.get("smelting_charges", 0)) == 1, "Burning Smelter must safely create a charge without nearby ore")
	event_bus.emit_enemy_killed({"enemy_id": "plain", "burning": false, "nearby_ores": []})
	support.expect(effects.size() == effects_before_smelter + 1, "Burning Smelter must ignore non-burning deaths")
	event_bus.emit_enemy_killed({"enemy_id": "burned_1", "burning": true, "nearby_ores": []})
	support.expect(effects.size() == effects_before_smelter + 1, "Burning Smelter must not duplicate one enemy-death reward")
	support.expect(manager.sync(["living_arrows"]), "Living Arrows behavior must activate through the same registry")
	var living_start := effects.size()
	for index: int in 100:
		event_bus.emit_attack({"weapon_type": "bow", "seed": 71000, "attack_index": index})
	var living_effects := effects.slice(living_start)
	support.expect(living_effects.size() <= 3 and not living_effects.is_empty(), "Living Arrows must deterministically spawn up to its active-plant limit")
	var expired_id := String((living_effects[0].payload as Dictionary).get("plant_id", ""))
	event_bus.emit_temporary_expired(expired_id)
	for index: int in 100:
		event_bus.emit_attack({"weapon_type": "bow", "seed": 72000, "attack_index": index})
	support.expect(effects.size() > living_start + living_effects.size(), "expired plants must release capacity for later Living Arrows")
	var attack_connections := event_bus.attack.get_connections().size()
	manager.clear()
	support.expect(manager.active_ids().is_empty() and event_bus.attack.get_connections().size() < attack_connections, "unequipping must disconnect legendary behavior without signal leaks")
	event_bus.emit_attack({"weapon_type": "bow", "seed": 1, "attack_index": 1})
	support.expect(manager.active_ids().is_empty(), "cleared manager must remain inert after later events")
	support.expect(LegendaryBehaviorRegistry.ids().has("riftwake_pulse") and LegendaryBehaviorRegistry.ids().has("chain_mining") and LegendaryBehaviorRegistry.ids().has("burning_smelter") and LegendaryBehaviorRegistry.ids().has("living_arrows"), "framework must expose existing and three M2 legendary properties")

