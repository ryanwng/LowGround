extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

var hit_once_array = [] #Attacks that have already hit

signal hurt(damage, angle, knockback) #Custom signal

func _on_area_entered(area):
	if area.is_in_group("attack"):
		if not area.get("damage") == null: #If something enters the hurtbox which does damage
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set","disabled",true) #Disable hurtbox collision
					disableTimer.start() #Start 0.5 second timer
				1: #HitOnce
					if hit_once_array.has(area) == false: #Check if attack isnt in array 
						hit_once_array.append(area)
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array",Callable(self,"remove_from_list")):
								area.connect("remove_from_array",Callable(self,"remove_from_list"))
					else:
						return #To avoid enemies being hit twice
				2:	#DisableHitBox
					if area.has_method("tempdisable"): #check if area has method tempdisable
						area.tempdisable()
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback = 1
			if not area.get("angle") == null: #Checks if attack has a variable angle
				angle = area.angle #set angle to attack.angle
			if not area.get("knockback_amount") == null: #Checks if attack has var knockback_amount
				knockback = area.knockback_amount #set knockback to attack.knockback_amount
			
			emit_signal("hurt",damage, angle, knockback)	#emit signals which reduces hp of character
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false) #re enable Hurtbox Collision
