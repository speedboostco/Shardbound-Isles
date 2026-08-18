class_name WeatherPresentation
extends CanvasLayer

class WeatherOverlay:
	extends Control

	var weather_id: String = "clear"
	var visual_seed: int = 0
	var elapsed: float = 0.0

	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _process(delta: float) -> void:
		elapsed += maxf(0.0, delta)
		queue_redraw()

	func _draw() -> void:
		var viewport_size := get_viewport_rect().size
		match weather_id:
			"rain": _draw_rain(viewport_size)
			"fog": _draw_fog(viewport_size)
			"gale": _draw_gale(viewport_size)
			_: _draw_clear_motes(viewport_size)

	func _draw_rain(viewport_size: Vector2) -> void:
		for index: int in 64:
			var x := fposmod(float(index * 83 + visual_seed % 97) + elapsed * 105.0, viewport_size.x + 80.0) - 40.0
			var y := fposmod(float(index * 47 + visual_seed % 131) + elapsed * 520.0, viewport_size.y + 100.0) - 50.0
			draw_line(Vector2(x, y), Vector2(x - 7.0, y + 24.0), Color(0.55, 0.78, 0.95, 0.35), 2.0)

	func _draw_fog(viewport_size: Vector2) -> void:
		for index: int in 5:
			var y := fposmod(float(index) * 185.0 + sin(elapsed * 0.35 + index) * 42.0, viewport_size.y + 180.0) - 90.0
			var offset := sin(elapsed * 0.22 + index * 1.7) * 90.0
			draw_rect(Rect2(-120.0 + offset, y, viewport_size.x + 240.0, 76.0), Color(0.68, 0.79, 0.78, 0.075), true)

	func _draw_gale(viewport_size: Vector2) -> void:
		for index: int in 34:
			var x := fposmod(float(index * 119 + visual_seed % 89) + elapsed * 360.0, viewport_size.x + 140.0) - 70.0
			var y := fposmod(float(index * 67 + visual_seed % 151) + sin(elapsed * 2.0 + index) * 22.0, viewport_size.y)
			var points := PackedVector2Array([Vector2(x, y), Vector2(x + 14, y - 5), Vector2(x + 27, y)])
			draw_polyline(points, Color(0.83, 0.73, 0.37, 0.35), 2.0)

	func _draw_clear_motes(viewport_size: Vector2) -> void:
		for index: int in 16:
			var x := fposmod(float(index * 151 + visual_seed % 73) + elapsed * 12.0, viewport_size.x)
			var y := fposmod(float(index * 89 + visual_seed % 127) - elapsed * 18.0, viewport_size.y)
			var alpha := 0.16 + sin(elapsed * 1.8 + index) * 0.06
			draw_colored_polygon(PackedVector2Array([Vector2(x, y - 3), Vector2(x + 2, y), Vector2(x, y + 3), Vector2(x - 2, y)]), Color(1.0, 0.88, 0.48, alpha))

var overlay: WeatherOverlay
var ambience: AudioStreamPlayer
var _configured_weather: String = ""
var _configured_seed: int = 0

func _ready() -> void:
	layer = 5
	overlay = WeatherOverlay.new()
	add_child(overlay)
	ambience = AudioStreamPlayer.new()
	ambience.name = "WeatherAmbience"
	ambience.volume_db = -24.0
	add_child(ambience)

func _exit_tree() -> void:
	if is_instance_valid(ambience):
		ambience.stop()
		ambience.stream = null

func configure(weather_id: String, seed_value: int) -> void:
	if not is_instance_valid(overlay):
		return
	overlay.weather_id = weather_id if weather_id in ExpeditionCycle.WEATHER_TYPES else "clear"
	overlay.visual_seed = seed_value
	overlay.queue_redraw()
	if _configured_weather != overlay.weather_id or _configured_seed != seed_value:
		_configured_weather = overlay.weather_id
		_configured_seed = seed_value
		ambience.stream = _build_ambient_loop(_configured_weather, _configured_seed)
		if DisplayServer.get_name() != "headless":
			ambience.play()

func weather_kind() -> String:
	return overlay.weather_id if is_instance_valid(overlay) else "clear"

func visual_element_count() -> int:
	match weather_kind():
		"rain": return 64
		"fog": return 5
		"gale": return 34
		_: return 16

func has_audio_layer() -> bool:
	return is_instance_valid(ambience) and ambience.stream is AudioStreamWAV

func audio_profile() -> String:
	return _configured_weather

func _build_ambient_loop(weather_id: String, seed_value: int) -> AudioStreamWAV:
	const MIX_RATE: int = 22050
	const DURATION_SECONDS: int = 2
	var frame_count := MIX_RATE * DURATION_SECONDS
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 4)
	for frame: int in frame_count:
		var time := float(frame) / float(MIX_RATE)
		var hash_value := ((frame + seed_value) * 1103515245 + 12345) & 0x7fffffff
		var noise := float(hash_value % 65536) / 32767.5 - 1.0
		var sample := 0.0
		match weather_id:
			"rain": sample = noise * 0.075 + sin(TAU * 96.0 * time) * 0.008
			"gale": sample = noise * (0.025 + 0.035 * (0.5 + 0.5 * sin(TAU * 0.35 * time))) + sin(TAU * 64.0 * time) * 0.014
			"fog": sample = sin(TAU * 82.0 * time) * 0.025 + sin(TAU * 123.0 * time) * 0.012
			_: sample = sin(TAU * 196.0 * time) * pow(maxf(0.0, sin(TAU * 0.5 * time)), 10.0) * 0.025 + noise * 0.004
		var left := clampi(roundi(sample * 32767.0), -32768, 32767)
		var right_sample := sample * 0.92 + sin(TAU * 0.17 * time) * 0.003
		var right := clampi(roundi(right_sample * 32767.0), -32768, 32767)
		bytes.encode_s16(frame * 4, left)
		bytes.encode_s16(frame * 4 + 2, right)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = true
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = frame_count
	stream.data = bytes
	return stream
