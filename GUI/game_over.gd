extends Control
# Built in code, shown while paused. Doubles as the death screen (is_victory=false)
# and the survival-victory screen (is_victory=true).

const FONT = preload("res://Font/tenderness.otf")

var is_victory := false
var survival_time := 0.0
var player_level := 1
var kills := 0
var gems := 0
var is_record := false
var best_time := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "YOU SURVIVED!" if is_victory else "YOU DIED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.5, 1, 0.6) if is_victory else Color(1, 0.4, 0.4))
	vbox.add_child(title)

	var t := int(survival_time)
	var bt := int(best_time)
	var stats := Label.new()
	stats.text = "Time  %02d:%02d      Level  %d\nKills  %d      Gems  %d\nBest  %02d:%02d" % [
		t / 60, t % 60, player_level, kills, gems, bt / 60, bt % 60]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_override("font", FONT)
	stats.add_theme_font_size_override("font_size", 16)
	vbox.add_child(stats)

	if is_record:
		var record := Label.new()
		record.text = "NEW BEST!"
		record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		record.add_theme_font_override("font", FONT)
		record.add_theme_font_size_override("font_size", 20)
		record.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		vbox.add_child(record)

	vbox.add_child(_spacer(6))
	vbox.add_child(_make_button("Restart", _on_restart))
	vbox.add_child(_make_button("Main Menu", _on_menu))
	vbox.add_child(_make_button("Quit", _on_quit))

	var snd := AudioStreamPlayer.new()
	snd.stream = load("res://Audio/SoundEffect/Victory.wav") if is_victory else load("res://Audio/SoundEffect/Lose.ogg")
	snd.bus = "SFX"
	snd.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(snd)
	snd.play()

func _make_button(text: String, handler: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 40)
	btn.add_theme_font_override("font", FONT)
	btn.add_theme_font_size_override("font_size", 18)
	btn.pressed.connect(handler)
	return btn

func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://GUI/main_menu.tscn")

func _on_quit() -> void:
	get_tree().quit()
