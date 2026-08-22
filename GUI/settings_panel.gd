extends Control
# Full-screen settings: Master / Music / SFX volume sliders.
# Two modes:
#   standalone = true  -> used as its own scene (main menu). Back returns to the menu.
#   standalone = false -> shown as an in-game overlay over the pause menu.
#                         Back frees it and emits `closed`. Set process_mode = ALWAYS
#                         by the opener so it works while the tree is paused.

const FONT = preload("res://Font/tenderness.otf")

@export var standalone := false

signal closed

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Opaque background so this reads as a dedicated screen, not a popup.
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.09, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	center.add_child(box)

	box.add_child(_label("Settings", 32))
	box.add_child(_spacer(6))
	box.add_child(_slider_row("Master", GameData.master_volume, GameData.set_master_volume))
	box.add_child(_slider_row("Music", GameData.music_volume, GameData.set_music_volume))
	box.add_child(_slider_row("SFX", GameData.sfx_volume, GameData.set_sfx_volume))
	box.add_child(_spacer(6))

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(240, 38)
	back.add_theme_font_override("font", FONT)
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_on_back)
	box.add_child(back)

func _slider_row(text: String, value: float, setter: Callable) -> VBoxContainer:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	var l := _label(text, 14)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(260, 18)
	s.value_changed.connect(func(v): setter.call(v))
	row.add_child(s)
	return row

func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	return l

func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

func _on_back() -> void:
	if standalone:
		get_tree().change_scene_to_file("res://GUI/main_menu.tscn")
	else:
		closed.emit()
		queue_free()
