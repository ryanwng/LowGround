extends Control

#var _is_paused:bool = false:
#	set = set_paused #calls function set_paused

var _is_paused:bool = false:
	set(value):
		_is_paused = value
		get_tree().paused = _is_paused
		visible = _is_paused #toggles visibility
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused #sets it to the opposite
	
#func set_paused(value:bool) -> void:
#	_is_paused = value
#	get_tree().paused = _is_paused
#	visible = _is_paused #toggles visibility


func _on_resume_btn_pressed():
	_is_paused = false

func _on_setting_btn_pressed():
	pass

func _on_quit_btn_pressed():
	get_tree().quit()
