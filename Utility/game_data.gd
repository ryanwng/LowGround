extends Node
# Autoloaded as "GameData". Persists the player's best survival time and the
# per-bus volume settings (Master / Music / SFX) to a small JSON file.

const SAVE_PATH := "user://savegame.json"

var best_time: float = 0.0        # longest run survived, in seconds
var master_volume: float = 1.0    # 0.0 - 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

# Session-only (not saved): when true the next run auto-plays for recording.
var demo_mode: bool = false

func _ready() -> void:
	load_game()
	apply_all_volumes()

func apply_all_volumes() -> void:
	_apply_bus("Master", master_volume)
	_apply_bus("Music", music_volume)
	_apply_bus("SFX", sfx_volume)

func _apply_bus(bus_name: String, v: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, v <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(clamp(v, 0.0001, 1.0)))

func set_master_volume(v: float) -> void:
	master_volume = clamp(v, 0.0, 1.0)
	_apply_bus("Master", master_volume)
	save_game()

func set_music_volume(v: float) -> void:
	music_volume = clamp(v, 0.0, 1.0)
	_apply_bus("Music", music_volume)
	save_game()

func set_sfx_volume(v: float) -> void:
	sfx_volume = clamp(v, 0.0, 1.0)
	_apply_bus("SFX", sfx_volume)
	save_game()

# Records a run time; returns true if it's a new best.
func record_time(t: float) -> bool:
	if t > best_time:
		best_time = t
		save_game()
		return true
	return false

func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"best_time": best_time,
			"master_volume": master_volume,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume,
		}))
		f.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(data) == TYPE_DICTIONARY:
		best_time = float(data.get("best_time", 0.0))
		master_volume = float(data.get("master_volume", 1.0))
		music_volume = float(data.get("music_volume", 1.0))
		sfx_volume = float(data.get("sfx_volume", 1.0))
