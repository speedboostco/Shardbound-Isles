class_name ForestWardenAudio
extends Node

signal cue_played(cue_id: String)

const SAMPLE_RATE := 16000
const CUE_DURATIONS: Dictionary = {
	"windup": 0.30,
	"impact": 0.24,
	"phase": 0.42,
	"hit": 0.11,
	"defeat": 0.52,
}

var player: AudioStreamPlayer
var streams: Dictionary = {}
var last_cue: String = ""
var played_cues: Array[String] = []

func _ready() -> void:
	for cue_id: String in CUE_DURATIONS:
		streams[cue_id] = _build_cue(cue_id, float(CUE_DURATIONS[cue_id]))
	player = AudioStreamPlayer.new()
	player.name = "CuePlayer"
	player.volume_db = -9.0
	add_child(player)

func play_cue(cue_id: String) -> bool:
	if not streams.has(cue_id) or not is_instance_valid(player):
		return false
	last_cue = cue_id
	played_cues.append(cue_id)
	player.stream = streams[cue_id] as AudioStreamWAV
	player.play()
	cue_played.emit(cue_id)
	return true

func has_audio_layer() -> bool:
	return is_instance_valid(player) and streams.size() == CUE_DURATIONS.size()

func audio_profile() -> String:
	return "forest_warden_wood_rune_v1"

func stream_for(cue_id: String) -> AudioStreamWAV:
	return streams.get(cue_id) as AudioStreamWAV

func _build_cue(cue_id: String, duration: float) -> AudioStreamWAV:
	var sample_count := maxi(1, roundi(duration * SAMPLE_RATE))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index: int in sample_count:
		var progress := float(sample_index) / float(sample_count)
		var seconds := float(sample_index) / float(SAMPLE_RATE)
		var envelope := pow(1.0 - progress, 1.55)
		var value := _sample_value(cue_id, seconds, progress) * envelope
		data.encode_s16(sample_index * 2, clampi(roundi(value * 32767.0), -32767, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = data
	return stream

func _sample_value(cue_id: String, seconds: float, progress: float) -> float:
	match cue_id:
		"windup":
			var frequency := lerpf(74.0, 146.0, progress)
			return sin(TAU * frequency * seconds) * 0.36 + sin(TAU * frequency * 2.01 * seconds) * 0.14
		"impact":
			return sin(TAU * 58.0 * seconds) * 0.48 + signf(sin(TAU * 173.0 * seconds)) * 0.17
		"phase":
			var frequency := lerpf(96.0, 410.0, progress)
			return sin(TAU * frequency * seconds) * 0.31 + sin(TAU * frequency * 1.5 * seconds) * 0.12
		"hit":
			return signf(sin(TAU * 212.0 * seconds)) * 0.22 + sin(TAU * 73.0 * seconds) * 0.20
		"defeat":
			var frequency := lerpf(190.0, 43.0, progress)
			return sin(TAU * frequency * seconds) * 0.33 + sin(TAU * 51.0 * seconds) * 0.13
		_:
			return 0.0
