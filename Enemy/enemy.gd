extends CharacterBody2D

@export var movement_speed = 20.0 #Can change this var on the side in "Inspector"
@export var hp = 10

@onready var player = get_tree().get_first_node_in_group("player") #Finds the player
@onready var sprite = $Sprite2D #allows to call the sprite
@onready var anim = $AnimationPlayer

func _ready():
	anim.play("walk")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position) #Finds the vector to get to the player
	velocity = direction * movement_speed
	move_and_collide(velocity*delta) #avoids clipping
	
	sprite.flip_h = direction.x > 0 #flips sprite


func _on_hurt_box_hurt(damage):
	hp -= damage
	if hp <= 0:
		queue_free()

