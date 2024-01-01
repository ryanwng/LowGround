extends CharacterBody2D

var movement_speed = 70.0 #declares types by itself
var hp = 80
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("walkTimer")

func _physics_process(_delta): #runs every frame
	movement()
	
func movement():
	var mov = Input.get_vector("left", "right", "up", "down")  #left/right == 1, else == 0 AND #up < 0 and down > 0
	sprite.flip_h = mov.x > 0 #flips sprite in direction its facing
	
	velocity = mov.normalized()*movement_speed #Normalized so don't move 40% faster diagonally
	move_and_slide() #Makes character move
	if mov!= Vector2.ZERO: #if theres no movement, make a walking animation. Do other way instead for anim
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes -1:
				sprite.frame=0
			else:
				sprite.frame+=1
			walkTimer.start()


func _on_hurt_box_hurt(damage):
	hp -= damage
	print(hp)
