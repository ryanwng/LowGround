extends CharacterBody2D

@export var movement_speed = 40.0 #Can change this var on the side in "Inspector"
@export var hp = 10
@export var knockback_recovery = 3.5 #Increase to reduce knockback
var knockback = Vector2.ZERO


@onready var player = get_tree().get_first_node_in_group("player") #Finds the player
@onready var sprite = $Sprite2D #allows to call the sprite
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit

var death_anim = preload("res://Enemy/explosion.tscn")

signal remove_from_array(object)

func _ready():
	anim.play("walk")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery) #Reduce knockback ev ery frame
	var direction = global_position.direction_to(player.global_position) #Finds the vector to get to the player
	velocity = direction * movement_speed
	velocity += knockback
	move_and_collide(velocity*delta) #avoids clipping
	
	sprite.flip_h = direction.x > 0 #flips sprite

func death():
	emit_signal("remove_from_array",self) #Clear enemy from array
	var enemy_death = death_anim.instantiate() #instances explosion scene
	#enemy_death.scale = sprite.scale #set explosion scale to sprite scale
	enemy_death.global_position = global_position #set global position to enemies position
	get_parent().call_deferred("add_child",enemy_death) #Spawn explosion on the enemy spawner
	queue_free()

func _on_hurt_box_hurt(damage,angle,knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
