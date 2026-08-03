class_name SeededRngStreams
extends RefCounted

const HASH_OFFSET: int = 2166136261
const HASH_PRIME: int = 16777619
const SEED_MASK: int = 0x7fffffff

var root_seed: int
var _streams: Dictionary = {}

func _init(root_seed_value: int) -> void:
	root_seed = root_seed_value

static func from_seed(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng

static func derive_seed(root_seed_value: int, stream_id: String) -> int:
	var stream_hash := HASH_OFFSET
	for byte: int in stream_id.to_utf8_buffer():
		stream_hash = ((stream_hash ^ byte) * HASH_PRIME) & SEED_MASK
	return (stream_hash ^ (root_seed_value & SEED_MASK)) & SEED_MASK

func stream(stream_id: String) -> RandomNumberGenerator:
	if not _streams.has(stream_id):
		_streams[stream_id] = from_seed(derive_seed(root_seed, stream_id))
	return _streams[stream_id] as RandomNumberGenerator
