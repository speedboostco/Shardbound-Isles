extends RefCounted

const RecipeRegistryScript := preload("res://game/core/recipe_registry.gd")
const CraftingScript := preload("res://game/core/crafting_service.gd")
const PlacementScript := preload("res://game/core/base_placement_model.gd")

func run(support: TestSupport) -> void:
	support.expect(RecipeRegistryScript.validate().is_empty(), "authored M4 recipes must validate")
	var invalid: Array[Dictionary] = RecipeRegistryScript.all()
	invalid[0].inputs = {"unknown_dust": 1}
	support.expect(RecipeRegistryScript.validate(invalid).any(func(error: String) -> bool: return error.contains("unknown or invalid input")), "recipe validation must detect unknown input IDs")
	invalid = RecipeRegistryScript.all()
	invalid[0].output = {"id": "unknown_output", "amount": 1}
	support.expect(RecipeRegistryScript.validate(invalid).any(func(error: String) -> bool: return error.contains("unknown or invalid output")), "recipe validation must detect unknown output IDs")
	invalid = RecipeRegistryScript.all()
	invalid[0].station = "future_forge"
	support.expect(RecipeRegistryScript.validate(invalid).any(func(error: String) -> bool: return error.contains("unknown station")), "recipe validation must detect unknown station IDs")
	var crafting: RefCounted = CraftingScript.new()
	var poor: Dictionary = crafting.evaluate("reinforced_heart", {"wood": 2, "scrap": 1})
	support.expect(not bool(poor.success) and poor.missing == {"wood": 1, "scrap": 1}, "recipe evaluation must explain every missing resource")
	var before := {"wood": 3, "scrap": 2}
	var blocked: Dictionary = crafting.evaluate("reinforced_heart", before, {}, {}, 0)
	support.expect(not bool(blocked.success) and blocked.reason == "output_blocked" and before == {"wood": 3, "scrap": 2}, "blocked output must leave all recipe inputs untouched")
	var crafted: Dictionary = crafting.evaluate("reinforced_heart", before)
	support.expect(bool(crafted.success) and crafted.resources_after == {"wood": 0, "scrap": 0}, "successful recipe plan must atomically describe exact deductions")
	support.expect(crafting.evaluate("lumber_mill_kit", {"wood": 9, "stone": 9}, {}).reason == "locked", "building recipe must enforce unlock requirements")
	support.expect(bool(crafting.evaluate("lumber_mill_kit", {"wood": 4, "stone": 2}, {"reinforced_heart": true}).success), "unlocked building recipe must be craftable")
	support.expect(crafting.evaluate("missing_recipe", {}).reason == "unknown_recipe", "unknown recipe IDs must be rejected")

	var placement: RefCounted = PlacementScript.new()
	support.expect(placement.begin_preview("lumber_mill", "west") and placement.preview.rotation == 0, "placement must create a temporary preview")
	support.expect(placement.rotate_preview() == 90 and placement.rotate_preview() == 180, "preview must rotate in deterministic ninety-degree steps")
	support.expect(not bool(placement.validate_preview(Vector2i(-2, -1)).valid) and placement.validate_preview(Vector2i(-2, -1)).reason == "player_overlap", "placement must reject overlap with the player")
	support.expect(bool(placement.validate_preview(Vector2i.ZERO).valid), "free authored socket must be a valid placement zone")
	var committed: Dictionary = placement.commit(Vector2i.ZERO)
	support.expect(bool(committed.valid) and placement.buildings.has("west") and placement.preview.is_empty(), "valid placement must commit the building and clear preview")
	support.expect(not placement.begin_preview("collector", "missing"), "unknown build sockets must be rejected")
	placement.begin_preview("collector", "west")
	support.expect(placement.validate_preview(Vector2i.ZERO).reason == "occupied", "placement must reject another building in the same socket")
	var saved: Dictionary = placement.to_dictionary()
	support.expect(not saved.has("preview") and PlacementScript.from_dictionary(saved) != null, "serialized placement must contain committed buildings but never preview state")
