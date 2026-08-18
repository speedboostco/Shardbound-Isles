extends RefCounted

const SURVIVAL_PATH := "res://game/core/survival_preparation.gd"
const JOURNEY_PATH := "res://game/core/journey_journal.gd"

func run(support: TestSupport) -> void:
	var Survival: Variant = load(SURVIVAL_PATH)
	var Journey: Variant = load(JOURNEY_PATH)
	support.expect(Survival != null, "survival preparation rules must load")
	support.expect(Journey != null, "journey journal rules must load")
	if Survival == null or Journey == null:
		return
	var survival: Variant = Survival.new()
	support.expect(survival.rations == 0 and survival.prepared_harvests == 0 and survival.ration_capacity() == 3, "a new expedition starts unprepared without a draining survival meter")
	support.expect(survival.add_ration(3) and survival.rations == 3 and survival.ration_capacity() == 0, "ration storage accepts exactly its bounded capacity")
	support.expect(not survival.add_ration() and survival.rations == 3, "ration storage rejects overflow without mutation")
	var rest: Dictionary = survival.consume_for_rest()
	support.expect(bool(rest.success) and rest.health == 4 and is_equal_approx(float(rest.mana), 24.0), "one ration produces bounded recovery")
	support.expect(survival.rations == 2 and survival.prepared_harvests == 6, "rest consumes exactly one ration and prepares six harvests")
	support.expect(survival.resolve_gather_yield(2) == 3 and survival.prepared_harvests == 5, "prepared gathering grants one visible bonus yield and consumes one charge")
	for index: int in 5:
		survival.resolve_gather_yield(1)
	support.expect(survival.resolve_gather_yield(2) == 2 and survival.prepared_harvests == 0, "gathering returns to base yield after prepared charges are spent")
	var saved_survival: Dictionary = survival.to_dictionary()
	var restored_survival: Variant = Survival.new()
	support.expect(restored_survival.restore(saved_survival) and restored_survival.to_dictionary() == saved_survival, "survival preparation round-trips through stable primitive data")
	support.expect(not restored_survival.restore({"rations": 4, "prepared_harvests": 0}), "invalid ration capacity is rejected")

	var journal: Variant = Journey.new()
	support.expect(Journey.validate().is_empty(), "journey milestone definitions validate")
	support.expect(journal.entries().size() == 11 and String(journal.next_entry().id) == "gather_wood", "the first-hour journey exposes eleven ordered milestones")
	var partial: Dictionary = journal.record("gather_wood", 2, true)
	support.expect(bool(partial.valid) and not bool(partial.completed_now) and int(journal.entry("gather_wood").progress) == 2, "absolute event progress updates without premature completion")
	var completed: Dictionary = journal.record("gather_wood")
	support.expect(bool(completed.completed_now) and completed.reward == {"fiber": 1}, "milestone completion returns its authored reward exactly once")
	var duplicate: Dictionary = journal.record("gather_wood", 20)
	support.expect(not bool(duplicate.completed_now) and (duplicate.reward as Dictionary).is_empty(), "repeated events cannot duplicate a milestone reward")
	support.expect(String(journal.next_entry().id) == "gather_stone", "the next incomplete journey step advances in authored order")
	support.expect(not bool(journal.record("unknown_step").valid), "unknown journey events are rejected")
	var saved_journal: Dictionary = journal.to_dictionary()
	var restored_journal: Variant = Journey.new()
	support.expect(restored_journal.restore(saved_journal) and restored_journal.to_dictionary() == saved_journal, "journey progress and claimed rewards round-trip")
	support.expect(not restored_journal.restore({"progress": {}, "completed": [], "rewarded": ["gather_wood"]}), "rewarded milestones cannot restore without completion")
	var ration_recipe := RecipeRegistry.get_definition("trail_ration")
	support.expect(not ration_recipe.is_empty() and not bool(ration_recipe.unique) and ration_recipe.inputs == {"fiber": 2, "emberberry": 2}, "Trail Ration is repeatable and consumes both gathered survival resources")
	support.expect(RecipeRegistry.all().size() == 19 and RecipeRegistry.validate().is_empty(), "the expanded nineteen-recipe workbench registry validates")
	var plan := CraftingService.new().evaluate("trail_ration", {"fiber": 2, "emberberry": 2}, {}, {}, 1)
	support.expect(bool(plan.success) and plan.resources_after == {"fiber": 0, "emberberry": 0}, "ration crafting remains an atomic resource transaction")
	support.expect(String(CraftingService.new().evaluate("trail_ration", {"fiber": 2, "emberberry": 2}, {}, {}, 0).reason) == "output_blocked", "ration crafting respects survival inventory capacity")
