extends Resource

class_name Spawn_info

@export var time_start:int
@export var time_end:int
@export var enemy:Resource
@export var enemy_num:int
@export var enemy_spawn_delay:int #Seconds of delay between spawns

var spawn_delay_counter = 0 #tracks seconds elapsed
