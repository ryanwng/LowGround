extends Control
# Title screen: Play / Options / Quit, plus a controls hint.
# Built in code to avoid fragile hand-authored layout.

const FONT = preload("res://Font/tenderness.otf")

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_build_main()
	_play_music()

func _build_main() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	center.add_child(box)

	var title := _label("Impostor Killer", 36)
	title.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	box.add_child(title)

	box.add_child(_spacer(8))
	box.add_child(_button("Play", _on_play))
	box.add_child(_button("Demo (Auto)", _on_demo))
	box.add_child(_button("Options", _on_options))
	box.add_child(_button("Quit", _on_quit))
	box.add_child(_spacer(10))

	var hint := _label("WASD: Move    Space: Attack    Esc: Pause", 11)
	hint.modulate = Color(1, 1, 1, 0.6)
	box.add_child(hint)

# --- UI helpers ------------------------------------------------------------

func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	return l

func _button(text: String, handler: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(220, 40)
	b.add_theme_font_override("font", FONT)
	b.add_theme_font_size_override("font_size", 18)
	b.pressed.connect(handler)
	return b

func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

func _play_music() -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load("res://Audio/Music/battleThemeA.mp3")
	p.bus = "Music"
	add_child(p)
	p.play()

# --- Button handlers -------------------------------------------------------

func _on_play() -> void:
	GameData.demo_mode = false
	get_tree().change_scene_to_file("res://World/world.tscn")

func _on_demo() -> void:
	GameData.demo_mode = true
	get_tree().change_scene_to_file("res://World/world.tscn")

func _on_options() -> void:
	get_tree().change_scene_to_file("res://GUI/settings_menu.tscn")

func _on_quit() -> void:
	get_tree().quit()
