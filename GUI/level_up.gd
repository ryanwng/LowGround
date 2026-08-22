extends Control
# Built entirely in code and shown while the tree is paused. Presents up to three
# upgrade choices from UpgradeDb; picking one calls player.finish_upgrade(id),
# which applies it and either reopens (if more levels are pending) or unpauses.

const FONT = preload("res://Font/tenderness.otf")

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var player = get_tree().get_first_node_in_group("player")
	var options: Array = UpgradeDb.get_random_options(player, 3)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.65)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "LEVEL UP  -  choose an upgrade"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	for id in options:
		var data: Dictionary = UpgradeDb.get_upgrade(id)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(340, 52)
		btn.icon = load(data["icon"])
		btn.expand_icon = false
		btn.text = "  %s\n  %s" % [data["name"], data["description"]]
		btn.add_theme_font_override("font", FONT)
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect(_on_pick.bind(id))
		vbox.add_child(btn)

	# Demo mode: show the card briefly, then auto-pick so recording stays hands-free.
	if GameData.demo_mode and not options.is_empty():
		var pick_id: String = options.pick_random()
		var t := get_tree().create_timer(0.4)
		t.timeout.connect(func(): _on_pick(pick_id))

func _on_pick(id: String) -> void:
	_play_click()
	var player = get_tree().get_first_node_in_group("player")
	queue_free()
	if player:
		player.finish_upgrade(id)

func _play_click() -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load("res://Audio/GUI/click.wav")
	p.bus = "SFX"
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
