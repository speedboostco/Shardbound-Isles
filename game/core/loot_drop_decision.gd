class_name LootDropDecision
extends RefCounted

static func decide(seed_value: int, context: String, probability: float) -> bool:
	if probability <= 0.0:
		return false
	if probability >= 1.0:
		return true
	var stream_seed := SeededRngStreams.derive_seed(seed_value, "equipment_drop:%s" % context)
	return SeededRngStreams.from_seed(stream_seed).randf() < probability
