extends CharacterBody2D

@export var movement_speed = 40.0 #Can change this var on the side in "Inspector"
@export var hp = 10
@export var experience = 1 #XP dropped as a gem on death
@export var contact_damage = 5 #Damage dealt to the player on touch
@export var knockback_recovery = 3.5 #Increase to reduce knockback
var knockback = Vector2.ZERO

var exp_gem = preload("res://Utility/exp_gem.tscn")
var damage_number = preload("res://GUI/damage_number.tscn")


@onready var player = get_tree().get_first_node_in_group("player") #Finds the player
@onready var sprite = $Sprite2D #allows to call the sprite
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit

# Which death effect to spawn. Defaults to the generic explosion; the Among Us
# enemy overrides this with the original SUS death in its scene.
@export var death_anim: PackedScene = preload("res://Enemy/explosion_generic.tscn")

signal remove_from_array(object)

func _ready():
	$HitBox.damage = contact_damage
	anim.play("walk")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery) #Reduce knockback ev ery frame
	var direction = global_position.direction_to(player.global_position) #Finds the vector to get to the player
	velocity = direction * movement_speed
	velocity += knockback
	move_and_collide(velocity*delta) #avoids clipping
	
	sprite.flip_h = direction.x < 0 #flips sprite

func death():
	emit_signal("remove_from_array",self) #Clear enemy from array
	var enemy_death = death_anim.instantiate() #instances explosion scene
	#enemy_death.scale = sprite.scale #set explosion scale to sprite scale
	enemy_death.global_position = global_position #set global position to enemies position
	get_parent().call_deferred("add_child",enemy_death) #Spawn explosion on the enemy spawner
	var gem = exp_gem.instantiate() #drop an XP gem for the player to collect
	gem.global_position = global_position
	gem.experience = experience
	get_parent().call_deferred("add_child",gem)
	if is_instance_valid(player):
		if player.has_method("register_kill"):
			player.register_kill()
		if experience >= 3 and player.has_method("add_shake"): #big enemies punch the camera
			player.add_shake(2.5)
	queue_free()

func _on_hurt_box_hurt(damage,angle,knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	_spawn_damage_number(damage)
	if hp <= 0:
		death()
	else:
		snd_hit.play()
		_flash()

func _flash(): #brief bright flash so hits read clearly
	sprite.modulate = Color(4, 4, 4)
	var t = create_tween()
	t.tween_property(sprite, "modulate", Color(1, 1, 1), 0.12)

func _spawn_damage_number(amount):
	var n = damage_number.instantiate()
	n.global_position = global_position + Vector2(0, -8)
	n.amount = amount
	get_parent().call_deferred("add_child", n)
