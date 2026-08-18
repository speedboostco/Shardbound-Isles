class_name ArtValidationScene
extends Node2D

const THEME: Theme = preload("res://game/ui/shardbound_theme.tres")
var _samples: Array[Sprite2D] = []

func _ready() -> void:
	for definition: Dictionary in [
		{"id": "hero_south", "position": Vector2(245, 275), "scale": 1.35},
		{"id": "slime_attack", "position": Vector2(430, 280), "scale": 1.2},
		{"id": "ranger_attack", "position": Vector2(600, 270), "scale": 1.25},
		{"id": "tree", "position": Vector2(790, 265), "scale": 1.55},
		{"id": "stone", "position": Vector2(965, 285), "scale": 1.35},
		{"id": "resource_drop", "position": Vector2(1085, 300), "scale": 0.9},
	]:
		var sprite := VisualAssetLibrary.sprite(String(definition.id), float(definition.scale))
		sprite.position = definition.position
		add_child(sprite)
		_samples.append(sprite)
	_add_ui_sample()
	var normal := GameplayVfx.new()
	normal.configure("normal_hit")
	normal.position = Vector2(160, 500)
	add_child(normal)
	normal.set_process(false)
	var critical := GameplayVfx.new()
	critical.configure("critical_hit")
	critical.position = Vector2(570, 500)
	add_child(critical)
	critical.set_process(false)
	queue_redraw()

func sample_count() -> int:
	return _samples.size()

func _add_ui_sample() -> void:
	var panel := PanelContainer.new()
	panel.theme = THEME
	panel.position = Vector2(700, 430)
	panel.size = Vector2(460, 250)
	add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var title := Label.new()
	title.text = "EMBERWOOD EQUIPMENT"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("e5a84b"))
	column.add_child(title)
	var detail := Label.new()
	detail.text = "LEGENDARY  •  Living Arrows\nBow impacts grow temporary attacking plants."
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(detail)
	var action := Button.new()
	action.text = "> EQUIP  (A)"
	action.custom_minimum_size = Vector2(0, 52)
	column.add_child(action)
	action.grab_focus.call_deferred()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 800), Color("172331"))
	for x: int in range(0, 1280, 64):
		for y: int in range(0, 420, 64):
			var asset_id := "path_horizontal" if y in [128, 192] else "grass"
			draw_texture_rect_region(VisualAssetLibrary.TERRAIN_V3_ATLAS, Rect2(x, y, 64, 64), VisualAssetLibrary.terrain_region(asset_id))
	draw_rect(Rect2(28, 28, 1224, 70), Color(0.03, 0.08, 0.08, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(52, 75), "PIXEL-PERFECT ART VALIDATION  •  1280 × 800  •  NEAREST / NO MIPMAPS", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("e8d8a8"))
	draw_string(ThemeDB.fallback_font, Vector2(52, 400), "HERO  •  ENEMY TELL  •  FOREST RANGER  •  RESOURCES  •  LOOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("e8d8a8"))
	draw_string(ThemeDB.fallback_font, Vector2(52, 520), "NORMAL HIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("e8d8a8"))
	draw_string(ThemeDB.fallback_font, Vector2(500, 520), "CRITICAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("e5a84b"))
