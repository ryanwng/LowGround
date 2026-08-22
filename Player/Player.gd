extends CharacterBody2D

#Stats
var max_hp = 80
var hp = 80
var armor = 0
var movement_speed = 120.0
var last_movement = Vector2.UP
var is_dead = false

#Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")

#AttackNodes
@onready var cooldownTimer: Timer = get_node("Attack/CooldownTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")

#IceSpear
var icespear_count = 1        #spears fired per shot
var icespear_damage = 5
var icespear_cooldown = 0.5   #seconds between shots

#Tornado (locked until unlocked via upgrade)
var tornado_level = 0
var tornado_baseammo = 1
var tornado_ammo = 0
var tornado_attackspeed = 3.0

#Experience / leveling
var experience = 0
var experience_level = 1
var collected_experience = 0
var experience_target = 5
var pending_level_ups = 0

#Upgrades taken so far (id -> level)
var collected_upgrades = {}

#Run stats (for the end-of-run summary)
var kills = 0
var gems_collected = 0

#Camera shake
var shake_strength := 0.0

#Enemy Related
var enemy_close = []

var damage_number = preload("res://GUI/damage_number.tscn")

@onready var sprite = $Sprite2D
@onready var camera = $Camera2D
@onready var walkTimer = get_node("walkTimer")
@onready var grabShape = get_node("GrabArea/CollisionShape2D")

signal health_changed(current, maximum)
signal experience_changed(current, target, level)
signal player_died()

var demo_mode := false #hands-free auto-play for recording footage
var _demo_dir := Vector2.ZERO #smoothed auto-play heading

func _ready():
	demo_mode = GameData.demo_mode
	if demo_mode:
		# Tanky so the auto-player survives long enough for dense footage.
		max_hp = 500
		hp = 500
	cooldownTimer.wait_time = icespear_cooldown
	cooldownTimer.stop()
	tornadoTimer.wait_time = tornado_attackspeed
	experience_target = calculate_experience_target()
	# Push initial values to the HUD (GUI is a child, already _ready).
	health_changed.emit(hp, max_hp)
	experience_changed.emit(experience, experience_target, experience_level)

func _process(delta): #camera shake, independent of physics
	if shake_strength > 0.0:
		shake_strength = max(shake_strength - delta * 20.0, 0.0)
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
	elif camera.offset != Vector2.ZERO:
		camera.offset = Vector2.ZERO

func add_shake(amount: float):
	if demo_mode: #keep recordings calm, not spasmy
		amount *= 0.25
	shake_strength = min(shake_strength + amount, 8.0)

func register_kill():
	kills += 1

# --- Demo / auto-play (recording) ------------------------------------------

func _demo_direction() -> Vector2:
	var target := Vector2.ZERO
	# Kite: flee the nearest enemy when it gets close.
	var nearest = _nearest_enemy()
	if nearest:
		var away = global_position - nearest.global_position
		if away.length() < 140.0:
			target += away.normalized() * 1.4
	# Stay near the arena centre and keep orbiting so movement always reads.
	var to_center = Vector2.ZERO - global_position
	target += to_center.normalized() * 0.5
	target += Vector2(-to_center.y, to_center.x).normalized() * 0.8 #orbit
	if target == Vector2.ZERO:
		target = _demo_dir if _demo_dir != Vector2.ZERO else last_movement
	# Low-pass filter the heading so the character glides instead of spasming.
	_demo_dir = _demo_dir.lerp(target.normalized(), 0.06)
	return _demo_dir

func _nearest_enemy():
	var best = null
	var best_d = INF
	for e in enemy_close:
		if not is_instance_valid(e):
			continue
		var d = global_position.distance_squared_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best

func _physics_process(_delta): #runs every frame
	if is_dead:
		return
	movement()
	var wants_attack = cooldownTimer.is_stopped() and (demo_mode or Input.is_action_just_pressed("attack1"))
	if wants_attack:
		attack()
		cooldownTimer.start()

func movement():
	var mov = _demo_direction() if demo_mode else Input.get_vector("left", "right", "up", "down")
	if abs(mov.x) > 0.15: #debounce so the sprite doesn't flip-flop rapidly
		sprite.flip_h = mov.x > 0
	velocity = mov.normalized() * movement_speed
	move_and_slide()
	if mov != Vector2.ZERO: #walking animation
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()

func attack():
	var target_pos = get_random_target()
	for i in icespear_count:
		var spear = iceSpear.instantiate()
		spear.position = position
		spear.target = target_pos
		spear.damage = icespear_damage
		spear.angle_offset = deg_to_rad(_spread_offset(i, icespear_count))
		add_child(spear)
	play_sfx("res://Audio/SoundEffect/ice.wav", -6.0)

# Even spread of extra spears around the aim direction.
func _spread_offset(i: int, count: int) -> float:
	if count <= 1:
		return 0.0
	return (i - (count - 1) / 2.0) * 15.0

func get_random_target() -> Vector2: #Targets the closest enemy
	if enemy_close.size() == 0:
		return global_position + last_movement.normalized() * 50.0
	var closest_distance = INF
	var closest_enemy
	for enemy in enemy_close:
		var distance = (global_position - enemy.global_position).length()
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy.global_position

# --- Health / damage -------------------------------------------------------

func _on_hurt_box_hurt(damage, _angle, _knockback):
	if is_dead:
		return
	var taken = max(damage - armor, 1)
	hp -= taken
	health_changed.emit(hp, max_hp)
	add_shake(3.0)
	if hp <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	player_died.emit()

# --- Experience / leveling -------------------------------------------------

func collect_experience(amount):
	if demo_mode: #race up the upgrade curve so a ~30s clip shows it all
		amount *= 8
	experience += amount
	collected_experience += amount
	while experience >= experience_target:
		experience -= experience_target
		level_up()
	experience_changed.emit(experience, experience_target, experience_level)
	if pending_level_ups > 0:
		_open_upgrade_ui()

func level_up():
	experience_level += 1
	experience_target = calculate_experience_target()
	pending_level_ups += 1
	play_sfx("res://Audio/SoundEffect/levelup.ogg", 0.0, true)

func calculate_experience_target() -> int:
	var lvl = experience_level
	if lvl < 20:
		return 5 + lvl * 4
	elif lvl < 40:
		return 81 + (lvl - 19) * 8
	else:
		return 249 + (lvl - 39) * 12

func _open_upgrade_ui():
	var gui = get_node_or_null("GUI")
	if gui and gui.has_method("show_level_up"):
		gui.show_level_up()

# Called by the level-up panel once the player picks an option.
func finish_upgrade(id):
	apply_upgrade(id)
	pending_level_ups -= 1
	if pending_level_ups > 0:
		_open_upgrade_ui()
	else:
		get_tree().paused = false

func apply_upgrade(id):
	collected_upgrades[id] = int(collected_upgrades.get(id, 0)) + 1
	match id:
		"icespear_amount":
			icespear_count += 1
		"icespear_cooldown":
			icespear_cooldown *= 0.88
			cooldownTimer.wait_time = icespear_cooldown
		"icespear_damage":
			icespear_damage += 3
		"tornado_unlock":
			tornado_level = 1
			tornadoTimer.wait_time = tornado_attackspeed
			if tornadoTimer.is_stopped():
				tornadoTimer.start()
		"tornado_amount":
			tornado_baseammo += 1
		"tornado_cooldown":
			tornado_attackspeed = max(tornado_attackspeed - 0.5, 0.5)
			tornadoTimer.wait_time = tornado_attackspeed
		"move_speed":
			movement_speed *= 1.12
		"max_health":
			max_hp += 20
			hp += 20
			health_changed.emit(hp, max_hp)
		"restore_health":
			hp = min(hp + 30, max_hp)
			health_changed.emit(hp, max_hp)
		"armor":
			armor += 1
		"magnet":
			if grabShape and grabShape.shape is CircleShape2D:
				grabShape.shape.radius += 20.0

# --- Gem pickup ------------------------------------------------------------

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot") and area.has_method("start_follow"):
		area.start_follow(self)

func _on_collect_area_area_entered(area):
	if is_dead:
		return
	if area.is_in_group("loot"):
		var xp = area.experience
		gems_collected += 1
		collect_experience(xp)
		play_sfx("res://Audio/SoundEffect/collectgem.mp3", -4.0)
		_spawn_pickup_number(xp)
		area.queue_free()

func _spawn_pickup_number(xp):
	var n = damage_number.instantiate()
	n.global_position = global_position + Vector2(0, -10)
	n.amount = xp
	n.prefix = "+"
	n.color = Color(0.5, 1, 0.5) #green for XP
	get_parent().call_deferred("add_child", n)

# --- Tornado (timer driven) ------------------------------------------------

func _on_tornado_timer_timeout():
	if tornado_level <= 0:
		return
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
		play_sfx("res://Audio/SoundEffect/tornado.ogg", -10.0)
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

# --- Enemy tracking --------------------------------------------------------

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_cooldown_timer_timeout():
	pass #ice spear cooldown gate; nothing to reload

# --- Helpers ---------------------------------------------------------------

func play_sfx(path: String, volume_db: float = 0.0, always: bool = false):
	var p = AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = volume_db
	p.bus = "SFX"
	if always:
		p.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
