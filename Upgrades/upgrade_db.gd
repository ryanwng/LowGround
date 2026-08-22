extends Node
# Autoloaded as "UpgradeDb". Holds metadata for every upgrade the player can pick
# on level-up. The actual stat changes live in Player.apply_upgrade(id) so this
# file stays pure data. Eligibility respects max_level and prerequisites.

const UPGRADES := {
	"icespear_amount": {
		"name": "Ice Spear +1",
		"description": "Fire one more ice spear per shot.",
		"icon": "res://Textures/Items/Weapons/ice_spear.png",
		"max_level": 5,
		"prerequisite": [],
	},
	"icespear_cooldown": {
		"name": "Faster Spears",
		"description": "Reduce ice spear cooldown by 12%.",
		"icon": "res://Textures/Items/Upgrades/scroll_old.png",
		"max_level": 5,
		"prerequisite": [],
	},
	"icespear_damage": {
		"name": "Sharper Spears",
		"description": "Ice spears deal +3 damage.",
		"icon": "res://Textures/Items/Weapons/sword.png",
		"max_level": 5,
		"prerequisite": [],
	},
	"tornado_unlock": {
		"name": "Tornado",
		"description": "Unlock the tornado, a roaming storm that shreds enemies.",
		"icon": "res://Textures/Items/Weapons/tornado.png",
		"max_level": 1,
		"prerequisite": [],
	},
	"tornado_amount": {
		"name": "Tornado +1",
		"description": "Spawn one more tornado each cycle.",
		"icon": "res://Textures/Items/Weapons/tornado.png",
		"max_level": 4,
		"prerequisite": ["tornado_unlock"],
	},
	"tornado_cooldown": {
		"name": "Rolling Storm",
		"description": "Tornadoes recharge faster.",
		"icon": "res://Textures/Items/Weapons/tornado.png",
		"max_level": 4,
		"prerequisite": ["tornado_unlock"],
	},
	"move_speed": {
		"name": "Swift Boots",
		"description": "Move 12% faster.",
		"icon": "res://Textures/Items/Upgrades/boots_4_green.png",
		"max_level": 5,
		"prerequisite": [],
	},
	"max_health": {
		"name": "Tough Hide",
		"description": "Increase max health by 20 (and heal 20).",
		"icon": "res://Textures/Items/Upgrades/thick_new.png",
		"max_level": 5,
		"prerequisite": [],
	},
	"restore_health": {
		"name": "Meat Chunk",
		"description": "Restore 30 health right now.",
		"icon": "res://Textures/Items/Upgrades/chunk.png",
		"max_level": 99,
		"prerequisite": [],
	},
	"armor": {
		"name": "Iron Helm",
		"description": "Reduce all incoming damage by 1.",
		"icon": "res://Textures/Items/Upgrades/helmet_1.png",
		"max_level": 5,
		"prerequisite": [],
	},
	"magnet": {
		"name": "Gem Magnet",
		"description": "Increase gem pickup range.",
		"icon": "res://Textures/Items/Upgrades/urand_mage.png",
		"max_level": 4,
		"prerequisite": [],
	},
}

# Returns up to `count` distinct eligible upgrade ids for this player, shuffled.
func get_random_options(player, count: int = 3) -> Array:
	var pool: Array = []
	for id in UPGRADES.keys():
		if _is_eligible(id, player):
			pool.append(id)
	pool.shuffle()
	if pool.size() > count:
		pool = pool.slice(0, count)
	# Fallback so the panel is never empty (restore_health is effectively uncapped).
	if pool.is_empty():
		pool.append("restore_health")
	return pool

func _is_eligible(id: String, player) -> bool:
	var data: Dictionary = UPGRADES[id]
	var current: int = int(player.collected_upgrades.get(id, 0))
	if current >= int(data["max_level"]):
		return false
	for req in data["prerequisite"]:
		if int(player.collected_upgrades.get(req, 0)) <= 0:
			return false
	return true

func get_upgrade(id: String) -> Dictionary:
	return UPGRADES.get(id, {})
