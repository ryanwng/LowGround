extends Sprite2D


func _ready():
	$AnimationPlayer.play("explode")


func _on_animation_player_animation_finished(_anim_name):
	queue_free()
