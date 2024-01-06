extends Area2D

var level = 1
var hp = 9999
var speed = 100.0
var damage = 5
var attack_size=1.0
var knockback_amount = 100


var last_movement = Vector2.ZERO
var angle = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO

signal remove_from_array(object) #To avoid double hits

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	match level:
		1:
			hp = 9999
			speed = 100.0
			damage = 5
			knockback_amount = 100
			attack_size = 1.0
	
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1,-0.25), last_movement.y)*500
			move_to_more = global_position + Vector2(randf_range(0.25,1), last_movement.y)*500
		Vector2.RIGHT, Vector2.LEFT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1,-0.25))*500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25,1))*500
		Vector2(1,1), Vector2(-1,-1), Vector2(1,-1), Vector2(-1,1): #btm right,top left, btm left, top right
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0,0.75))*500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0,0.75), last_movement.y)*500
			
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self,"scale",Vector2(1,1)*attack_size,3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) #Increase size as it exists 3 secs
	var final_speed = speed
	speed = speed/5.0
	initial_tween.tween_property(self,"speed",final_speed,6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) #Increase speed as it exists 6 secs
	initial_tween.play()
	
	var tween = create_tween() #Where the tween goes
	var set_angle = randi_range(0,1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self,"angle",angle_more,2)
		tween.tween_property(self,"angle",angle_less,2)
		tween.set_loops(3)
	else:
		angle = angle_more
		tween.set_loops(3)
	tween.play()
	
func _physics_process(delta):
	position += angle*speed*delta
	


func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()


#var time: float = 0
#var level = 1
#var hp = 9999
#var speed = 100.0
#var damage = 5
#var attack_size = 1.0
#var knockback_amount = 100
#
#var last_movement = Vector2.ZERO
#var angle = Vector2.ZERO
#var angle_less = Vector2.ZERO
#var angle_more = Vector2.ZERO
#
#@export_range(1, 1000) var frequency := 8.0
#@export_range(1, 1000) var amplitude := 100.0
#@export_range(1, 1000) var initial_boost := 150
#@export_range(0, 360) var wave_offset := 0.0
#@export_range(1, 1000) var length_multiplier := 15.0
#@export var num_of_points := 1200
#@export var spawn_point := Vector2(50, 150)
#
#@onready var player = get_tree().get_first_node_in_group("player")
#@onready var timer := $Timer as Timer
#
#signal remove_from_array(object)
#
#func _ready() -> void:
	##assert(timer.timeout.connect(_on_timer_timeout) == OK)
	#match level:
		#1:
			#hp = 9999
			#speed = 200.0
			#damage = 5
			#knockback_amount = 100
			#attack_size = 1.0
	#
	#var initial_tween = create_tween().set_parallel(true)
	#initial_tween.tween_property(self,"scale",Vector2(1,1)*attack_size,3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) #Increase size as it exists 3 secs
	#var final_speed = speed
	#speed = speed/5.0
	#initial_tween.tween_property(self,"speed",final_speed,6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) #Increase speed as it exists 6 secs
	#initial_tween.play()
	#get_parent().rotation = last_movement.angle() # set the rotation of the parent to the player direction
	#rotation -= last_movement.angle() # reset the rotation of the sprite irrespective of the parent
	#
#
#
#func _physics_process(delta: float) -> void:
	#time += delta
	#var movement := sin(time * frequency + wave_offset) * ((amplitude * time) + initial_boost)
	#position.y += movement * delta
	#position.x += speed * delta
#
#
#func _on_timer_timeout() -> void:
	#remove_from_array.emit("remove_from_array",self)
	#queue_free()

