class_name IslandShardDefinition
extends Resource

const REQUIRED_FIELDS: Array[String] = ["shard_id", "seed", "biome", "level", "size", "positive_modifiers", "negative_modifiers", "encounter", "reward_tags", "rarity"]
const VALID_SIZES: Array[String] = ["small", "medium", "large"]

static func validate_dictionary(definition: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for field: String in REQUIRED_FIELDS:
		if not definition.has(field):
			errors.append("missing required shard field: %s" % field)
	if not errors.is_empty():
		return errors
	if String(definition.shard_id).is_empty():
		errors.append("shard_id must be non-empty")
	if not (definition.seed is int or definition.seed is float) or int(definition.level) < 1:
		errors.append("seed and positive level are required")
	if String(definition.biome) not in IslandShardGenerator.BIOMES:
		errors.append("unsupported shard biome: %s" % String(definition.biome))
	if String(definition.size) not in VALID_SIZES:
		errors.append("unsupported shard size: %s" % String(definition.size))
	if not definition.positive_modifiers is Array or not definition.negative_modifiers is Array:
		errors.append("modifier lists must be arrays")
		return errors
	if (definition.positive_modifiers as Array).is_empty() or (definition.positive_modifiers as Array).size() != (definition.negative_modifiers as Array).size():
		errors.append("positive modifiers must have paired negative risks")
	var seen: Dictionary = {}
	for modifier_value: Variant in (definition.positive_modifiers as Array) + (definition.negative_modifiers as Array):
		var modifier_id := String(modifier_value)
		if seen.has(modifier_id):
			errors.append("duplicate or conflicting shard modifier: %s" % modifier_id)
		seen[modifier_id] = true
		if IslandModifierRegistry.definition(modifier_id).is_empty():
			errors.append("unknown shard modifier: %s" % modifier_id)
	if not definition.reward_tags is Array or (definition.reward_tags as Array).is_empty():
		errors.append("reward_tags must be a non-empty array")
	if String(definition.rarity) not in RarityRules.ORDER:
		errors.append("unsupported shard rarity")
	for preview_field: String in ["resources", "enemies", "expected_rewards"]:
		if not definition.get(preview_field) is Array or (definition.get(preview_field) as Array).is_empty():
			errors.append("shard preview requires %s" % preview_field)
	return errors
