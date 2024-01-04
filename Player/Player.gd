extends CharacterBody2D

var movement_speed = 70.0 #declares types by itself
var hp = 80

#Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")

#AttackNodes
#@onready var iceSpearTimer: Timer = get_node("%IceSpearTimer");
#@onready var iceSpearAttackTimer: Timer = iceSpearTimer.get_node("%IceSpearAttackTimer")
@onready var cooldownTimer: Timer = get_node("Attack/CooldownTimer");

#IceSpear
var icespear_ammo = 1
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

#Enemy Related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("walkTimer")

func _ready():
	pass #attack()

func _physics_process(_delta): #runs every frame
	movement()
	if Input.is_action_just_pressed("attack1"): #If space is pressed
		attack()
		if cooldownTimer.is_stopped():
			cooldownTimer.start()   
	
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

func attack():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position #Shooting the shot
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		
	#if icespear_level > 0:
		#iceSpearTimer.wait_time = icespear_attackspeed
		#if iceSpearTimer.is_stopped():
			#iceSpearTimer.start()

func _on_hurt_box_hurt(damage):
	hp -= damage
	print(hp)


#func _on_ice_spear_timer_timeout():
	#pass
	#icespear_ammo += icespear_baseammo #Loading ammunition
	#iceSpearAttackTimer.start()


#func _on_ice_spear_attack_timer_timeout():
	#pass
	#if icespear_ammo > 0:
		#var icespear_attack = iceSpear.instantiate()
		#icespear_attack.position = position #Shooting the shot
		#icespear_attack.target = get_random_target()
		#icespear_attack.level = icespear_level
		#add_child(icespear_attack)
		#icespear_ammo -= 1
	#if icespear_ammo > 0:
		#iceSpearAttackTimer.start()
	#else:
		#iceSpearAttackTimer.stop()
		
func get_random_target() -> Vector2:
	if enemy_close.size() == 0:
		return Vector2.UP
	var closest_distance = INF
	var closest_enemy
	for enemy in enemy_close:
		var distance = (global_position - enemy.global_position).length()
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy.global_position


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
			enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_cooldown_timer_timeout():
	icespear_ammo += icespear_baseammo #Loading ammunition
	cooldownTimer.stop()
