extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage) #Custom signal

func _on_area_entered(area):
	if area.is_in_group("attack"):
		if not area.get("damage") == null: #If something enters the hurtbox which does damage
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set","disabled",true) #Disable hurtbox collision
					disableTimer.start() #Start 0.5 second timer
				1: #HitOnce
					pass
				2:	#DisableHitBox
					if area.has_method("tempdisable"): #check if area has method tempdisable
						area.tempdisable()
			var damage = area.damage
			emit_signal("hurt",damage)	#emit signals which reduces hp of character
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false) #re enable Hurtbox Collision
