extends Node2D


@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0



func _on_timer_timeout():
	time+=1 #increase time by 1
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time>= i.time_start and time <= i.time_end: #Check if anything spawns in the elapsed time
			if i.spawn_delay_counter < i.enemy_spawn_delay: #Check if there's a delay
				i.spawn_delay_counter += 1 #Makes a enemy spawn every 2 seconds
			else:
				i.spawn_delay_counter = 0 #Reset delay counter
				var new_enemy = i.enemy #Load in the enemy (resource)
				var counter = 0
				while counter < i.enemy_num: #spawn number of enemies
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position() #sets global position
					add_child(enemy_spawn) #spawns it into world
					counter +=1 #increase counter until all enemies have spawned
					
func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1,1.4) #viewport rect and makes them spawn off screen
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
			
	
	
					
