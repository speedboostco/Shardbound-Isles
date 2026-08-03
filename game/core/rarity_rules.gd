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

static func roll(rng: RandomNumberGenerator) -> String:
	var total := 0.0
	for rarity: String in ORDER:
		total += float(WEIGHTS[rarity])
	var cursor := rng.randf_range(0.0, total)
	for rarity: String in ORDER:
		cursor -= float(WEIGHTS[rarity])
		if cursor <= 0.0:
			return rarity
	return "common"

static func affix_range(rarity: String) -> Vector2i:
	return AFFIX_RANGES.get(rarity, Vector2i.ZERO) as Vector2i

static func affix_count(rarity: String, rng: RandomNumberGenerator) -> int:
	var limits := affix_range(rarity)
	return rng.randi_range(limits.x, limits.y)

static func color(rarity: String) -> String:
	return String(COLORS.get(rarity, COLORS.common))

static func rank(rarity: String) -> int:
	return ORDER.find(rarity)

