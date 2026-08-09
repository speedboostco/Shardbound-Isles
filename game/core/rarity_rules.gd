class_name RarityRules
extends RefCounted

const ORDER: Array[String] = ["common", "magic", "rare", "epic", "legendary"]
const WEIGHTS: Dictionary = {"common": 55.0, "magic": 25.0, "rare": 12.0, "epic": 6.0, "legendary": 2.0}
const AFFIX_RANGES: Dictionary = {
	"common": Vector2i(0, 0),
	"magic": Vector2i(1, 1),
	"rare": Vector2i(2, 2),
	"epic": Vector2i(3, 3),
	"legendary": Vector2i(3, 3),
}
const COLORS: Dictionary = {
	"common": "d5dde5",
	"magic": "6ca8ff",
	"rare": "f3d35c",
	"epic": "c080ff",
	"legendary": "ff914d",
}

static func definitions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for rarity: String in ORDER:
		var limits := affix_range(rarity)
		result.append({"id": rarity, "weight": float(WEIGHTS[rarity]), "minimum_affixes": limits.x, "maximum_affixes": limits.y, "color": String(COLORS[rarity])})
	return result

static func roll(rng: RandomNumberGenerator) -> String:
	return roll_from_definitions(rng, definitions())

static func roll_from_definitions(rng: RandomNumberGenerator, rarity_definitions: Array) -> String:
	var total := 0.0
	var eligible: Array[Dictionary] = []
	for value: Variant in rarity_definitions:
		if value is Dictionary and float((value as Dictionary).get("weight", 0.0)) > 0.0:
			eligible.append((value as Dictionary).duplicate(true))
			total += float((value as Dictionary).weight)
	if eligible.is_empty():
		return "common"
	var cursor := rng.randf_range(0.0, total)
	for definition: Dictionary in eligible:
		cursor -= float(definition.weight)
		if cursor <= 0.0:
			return String(definition.id)
	return String(eligible.back().id)

static func validate(rarity_definitions: Array = []) -> Array[String]:
	var values: Array = definitions() if rarity_definitions.is_empty() else rarity_definitions
	var errors: Array[String] = []
	var ids: Dictionary = {}
	var positive_weight := false
	for value: Variant in values:
		if not value is Dictionary:
			errors.append("rarity definition must be a dictionary")
			continue
		var definition := value as Dictionary
		var rarity_id := String(definition.get("id", ""))
		if rarity_id.is_empty() or ids.has(rarity_id):
			errors.append("rarity ID must be non-empty and unique: %s" % rarity_id)
		ids[rarity_id] = true
		var weight := float(definition.get("weight", -1.0))
		if not is_finite(weight) or weight < 0.0:
			errors.append("rarity weight must be finite and non-negative: %s" % rarity_id)
		positive_weight = positive_weight or weight > 0.0
		var minimum := int(definition.get("minimum_affixes", -1))
		var maximum := int(definition.get("maximum_affixes", -1))
		if minimum < 0 or maximum < minimum:
			errors.append("rarity affix range is invalid: %s" % rarity_id)
		if not Color.html_is_valid(String(definition.get("color", ""))):
			errors.append("rarity color is invalid: %s" % rarity_id)
	if not positive_weight:
		errors.append("rarity configuration requires at least one positive weight")
	return errors

static func affix_range(rarity: String) -> Vector2i:
	return AFFIX_RANGES.get(rarity, Vector2i.ZERO) as Vector2i

static func affix_count(rarity: String, rng: RandomNumberGenerator) -> int:
	var limits := affix_range(rarity)
	return rng.randi_range(limits.x, limits.y)

static func color(rarity: String) -> String:
	return String(COLORS.get(rarity, COLORS.common))

static func rank(rarity: String) -> int:
	return ORDER.find(rarity)
