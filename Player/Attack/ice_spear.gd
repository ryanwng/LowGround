extends Area2D

var level = 1
var hp = 1 #amount of pierce
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO


@onready var player = get_tree().get_first_node_in_group("player")
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135) #gets angle in radians
	match level:
		1:	
			hp = 100 #Change this number to change pierce
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0
			
	

		
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
		
func _physics_process(delta):
	position += angle*speed*delta
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array",self) 
		queue_free() #get rids of enemy


func _on_visible_on_screen_notifier_2d_screen_exited():
	emit_signal("remove_from_array",self)
	queue_free() #once it leaves the screen the projectile disappears 
