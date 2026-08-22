extends Area2D
# Dropped by enemies on death. Sits still until the player's GrabArea flags it,
# then accelerates toward the player. The player's CollectArea grants the XP.

@export var experience: int = 1

var target: Node2D = null
var follow_speed: float = 0.0

func _ready() -> void:
	# Cosmetic: bigger rewards use greener / redder gems.
	if experience >= 5:
		$Sprite2D.texture = load("res://Textures/Items/Gems/Gem_red.png")
	elif experience >= 3:
		$Sprite2D.texture = load("res://Textures/Items/Gems/Gem_green.png")

func _process(delta: float) -> void:
	if target:
		follow_speed = min(follow_speed + 800.0 * delta, 420.0)
		global_position = global_position.move_toward(target.global_position, follow_speed * delta)

func start_follow(who: Node2D) -> void:
	target = who
