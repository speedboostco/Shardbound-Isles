extends RefCounted

const MANA_PATH := "res://game/core/mana_pool.gd"
const TECHNOLOGY_PATH := "res://game/core/technology_tree.gd"
const CRAFTING_PATH := "res://game/core/crafting_service.gd"

func run(support: TestSupport) -> void:
	var Mana: Variant = load(MANA_PATH)
	var Technology: Variant = load(TECHNOLOGY_PATH)
	var Crafting: Variant = load(CRAFTING_PATH)
	support.expect(Mana != null, "mana pool must load")
	support.expect(Technology != null, "technology tree must load")
	support.expect(Crafting != null, "expanded crafting service must load")
	if Mana == null or Technology == null:
		return
	var mana: Variant = Mana.new(60.0, 6.0)
	support.expect(is_equal_approx(mana.current, 60.0), "mana begins full")
	support.expect(mana.spend(18.0), "mana can fund a spell")
	support.expect(is_equal_approx(mana.current, 42.0), "spell cost is deducted exactly")
	support.expect(not mana.spend(50.0), "mana rejects unaffordable spells")
	mana.regenerate(2.0)
	support.expect(is_equal_approx(mana.current, 54.0), "mana regeneration is time based")
	mana.regenerate(20.0)
	support.expect(is_equal_approx(mana.current, 60.0), "mana regeneration is capped")
	mana.set_maximum(80.0)
	support.expect(is_equal_approx(mana.current, 80.0), "maximum-mana unlock refills only its new capacity")
	support.expect(not mana.restore(90.0, 80.0, 6.0), "invalid saved mana is rejected")
	support.expect(mana.restore(31.5, 80.0, 9.0), "valid saved mana restores")

	var tree: Variant = Technology.new()
	support.expect(Technology.validate().is_empty(), "technology definitions validate")
	var definitions: Array[Dictionary] = tree.all_definitions()
	support.expect(definitions.size() == 12, "the visual technology tree exposes twelve authored nodes across deeper tiers")
	support.expect(definitions.all(func(entry: Dictionary) -> bool: return not String(entry.get("icon_id", "")).is_empty() and entry.has("column") and entry.has("row") and entry.get("unlocks_recipes", []) is Array), "every technology carries visual graph and recipe-unlock metadata")
	support.expect((tree.definition("ranger_instinct").unlocks_recipes as Array).has("precision_quiver"), "Ranger Instinct explicitly unlocks its craftable recipe")
	support.expect((tree.definition("efficient_harvest").unlocks_recipes as Array).has("foresters_toolkit"), "Efficient Harvest explicitly unlocks its craftable recipe")
	support.expect((tree.definition("island_cartography").unlocks_recipes as Array).has("surveyors_lens"), "Island Cartography explicitly unlocks its craftable recipe")
	support.expect((tree.definition("weapon_mastery").unlocks_recipes as Array).has("duelist_grip"), "Weapon Mastery explicitly unlocks its craftable recipe")
	support.expect((tree.definition("master_foraging").unlocks_recipes as Array).has("reinforced_axe"), "Master Foraging explicitly unlocks its craftable recipe")
	support.expect((tree.definition("island_industry").unlocks_recipes as Array).has("precision_gearbox"), "Island Industry explicitly unlocks its craftable recipe")
	support.expect((tree.definition("shard_attunement").unlocks_recipes as Array).has("shard_prism"), "Shard Attunement explicitly unlocks its craftable recipe")
	support.expect((tree.definition("ley_resonance").unlocks_recipes as Array).has("ley_capacitor"), "Ley Resonance explicitly unlocks its craftable recipe")
	var complete_tree: Variant = Technology.new()
	support.expect(complete_tree.restore(["fieldcraft", "combat_training", "efficient_harvest", "mana_channeling", "ranger_instinct", "master_foraging", "island_cartography", "arcane_mastery", "weapon_mastery", "island_industry", "shard_attunement", "ley_resonance"]), "the complete four-tier technology graph restores with all prerequisite chains intact")
	support.expect(tree.available().size() == 1 and String(tree.available()[0].id) == "fieldcraft", "only fieldcraft is initially available")
	var resources := {"wood": 5, "stone": 3, "moonleaf": 0, "plank": 0}
	var locked: Dictionary = tree.evaluate("combat_training", resources)
	support.expect(String(locked.reason) == "missing_prerequisite", "combat cannot be learned before fieldcraft")
	var fieldcraft: Dictionary = tree.learn("fieldcraft", resources)
	support.expect(bool(fieldcraft.success), "fieldcraft can be learned after opening gathering")
	resources = fieldcraft.resources_after
	support.expect(resources == {"wood": 3, "stone": 2, "moonleaf": 0, "plank": 0}, "technology costs are deducted exactly")
	var combat: Dictionary = tree.learn("combat_training", resources)
	support.expect(bool(combat.success) and tree.is_learned("combat_training"), "second unlock deliberately awakens combat")
	support.expect(not bool(tree.learn("combat_training", combat.resources_after).success), "technology cannot be learned twice")
	var replay: Variant = Technology.new()
	support.expect(replay.restore(["fieldcraft", "combat_training"]), "learned technology state restores")
	support.expect(replay.learned == tree.learned, "restored technology order is stable")
	support.expect(not Technology.new().restore(["combat_training"]), "invalid prerequisite state is rejected")
	var crafting: Variant = Crafting.new()
	var upgrade_resources := {"wood": 0, "stone": 2, "moonleaf": 3, "scrap": 0, "plank": 0}
	support.expect(String(crafting.evaluate("mana_vessel", upgrade_resources).reason) == "locked", "mana vessel recipe must honor its technology requirement")
	var vessel: Dictionary = crafting.evaluate("mana_vessel", upgrade_resources, {"mana_channeling": true})
	support.expect(bool(vessel.success) and String(vessel.output.id) == "mana_vessel", "unlocked mana vessel recipe must produce its authored upgrade")
	support.expect(vessel.resources_after.stone == 0 and vessel.resources_after.moonleaf == 0, "expanded recipe deductions must remain atomic and exact")
	support.expect(RecipeRegistry.all().size() == 18 and RecipeRegistry.validate().is_empty(), "all eighteen production recipes must validate")
	support.expect(bool(crafting.evaluate("precision_quiver", {"wood": 4, "stone": 0, "moonleaf": 3, "scrap": 0, "plank": 0}, {"ranger_instinct": true}).success), "an advanced technology unlocks its named craftable item")
