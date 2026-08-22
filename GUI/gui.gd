extends CanvasLayer
# HUD + orchestrator for level-up and end-game screens. Lives as a child of the
# Player so it can read/connect to the player directly.

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var hp_label: Label = $HPLabel
@onready var exp_bar: TextureProgressBar = $ExpBar
@onready var level_label: Label = $ExpBar/LevelLabel
@onready var timer_label: Label = $TimerLabel
@onready var level_flash: ColorRect = $LevelFlash

const LevelUpPanel = preload("res://GUI/level_up.gd")
const GameOverScreen = preload("res://GUI/game_over.gd")

var player: Node = null
var survival_time := 0.0
var target_time := 300.0   # 5 minutes to victory
var game_ended := false
var _last_level := 1

func _ready() -> void:
	# Demo runs cap at 30s so a recording has a clean victory beat to end on.
	target_time = 30.0 if GameData.demo_mode else 300.0
	player = get_parent()
	if player:
		player.health_changed.connect(_on_health_changed)
		player.experience_changed.connect(_on_experience_changed)
		player.player_died.connect(_on_player_died)
		_on_health_changed(player.hp, player.max_hp)
		_on_experience_changed(player.experience, player.experience_target, player.experience_level)
	_update_timer_label()

func _process(delta: float) -> void:
	if game_ended:
		return
	survival_time += delta
	_update_timer_label()
	if survival_time >= target_time:
		_end_game(true)

func _update_timer_label() -> void:
	var t := int(survival_time)
	timer_label.text = "%02d:%02d" % [t / 60, t % 60]

func _on_health_changed(current, maximum) -> void:
	health_bar.max_value = maximum
	health_bar.value = max(current, 0)
	hp_label.text = "%d/%d" % [max(current, 0), maximum]

func _on_experience_changed(current, target, level) -> void:
	exp_bar.max_value = target
	exp_bar.value = current
	level_label.text = "Lv %d" % level
	if level > _last_level:
		_last_level = level
		_level_up_juice()

func _level_up_juice() -> void:
	# Gold screen flash + a quick pop on the level label.
	level_flash.color = Color(1.0, 0.85, 0.3, 0.35)
	var tf := create_tween()
	tf.tween_property(level_flash, "color:a", 0.0, 0.4)
	level_label.pivot_offset = level_label.size / 2.0
	level_label.scale = Vector2(1.5, 1.5)
	var ts := create_tween()
	ts.tween_property(level_label, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func show_level_up() -> void:
	get_tree().paused = true
	var panel := Control.new()
	panel.set_script(LevelUpPanel)
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(panel)

func _on_player_died() -> void:
	_end_game(false)

func _end_game(victory: bool) -> void:
	if game_ended:
		return
	game_ended = true
	get_tree().paused = true
	var is_record := GameData.record_time(survival_time)
	var screen := Control.new()
	screen.set_script(GameOverScreen)
	screen.process_mode = Node.PROCESS_MODE_ALWAYS
	screen.is_victory = victory
	screen.survival_time = survival_time
	screen.player_level = player.experience_level if player else 1
	screen.kills = player.kills if player else 0
	screen.gems = player.gems_collected if player else 0
	screen.is_record = is_record
	screen.best_time = GameData.best_time
	add_child(screen)
