extends Node2D

@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0 #elapsed seconds (Timer ticks once per second)


func _on_timer_timeout():
	# Demo mode races through the difficulty curve and spawns denser crowds so a
	# short recording shows the full escalation and lots of on-screen action.
	var demo := GameData.demo_mode
	time += (10 if demo else 1) #race through the 5-min curve in ~30s
	var burst_mult := (4 if demo else 1)
	for i in spawns:
		if time >= i.time_start and time <= i.time_end: #inside this wave's window
			if i.spawn_delay_counter < i.enemy_spawn_delay: #wait out the delay
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0 #reset delay counter
				var counter = 0
				while counter < i.enemy_num * burst_mult: #spawn a burst
					var enemy_spawn = i.enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					enemy_spawn.hp = int(enemy_spawn.hp * hp_scale()) #ramp toughness over time
					add_child(enemy_spawn)
					counter += 1

# Enemies get gradually tankier as the run goes on (up to +100% HP at 5 minutes).
func hp_scale() -> float:
	return 1.0 + float(time) / 300.0

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(0.7,0.95) #viewport rect and makes them spawn off screen
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2) #Minus as up is negative in Godot
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up","down","right","left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO

	match pos_side: #switch statement to pick a side randomly
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left

	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn) #Returns coords of mob to spawn in
