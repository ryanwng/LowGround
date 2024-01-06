#Line of sight blockers?
#Rolling/Dodge

extends CharacterBody2D

var movement_speed = 120.0 #declares types by itself
var hp = 80
var last_movement = Vector2.UP

#Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")

#AttackNodes
@onready var cooldownTimer: Timer = get_node("Attack/CooldownTimer");
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")

#IceSpear
var icespear_ammo = 1
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

#Tornado
var tornado_ammo = 1
var tornado_baseammo = 1 #increases number spawned in
var tornado_attackspeed = 3
var tornado_level = 1

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
		last_movement = mov
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
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed
		if tornadoTimer.is_stopped():
			tornadoTimer.start()

func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	print(hp)

		
func get_random_target() -> Vector2: #Technically targets closest and not random
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
	#OR for TRUE "RANDOMNESS" 
	#if enemy_close.size() > 0:
		#return enemy_close.pick_random().global_position
	#else:
		#return Vector2.UP
	
func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo
	tornadoAttackTimer.start()


func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
			enemy_close.append(body)
			

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
		

func _on_cooldown_timer_timeout(): #Makes cooldown between attacks
	icespear_ammo += icespear_baseammo #Loading ammunition
	cooldownTimer.stop()
