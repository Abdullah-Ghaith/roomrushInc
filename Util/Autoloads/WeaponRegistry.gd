extends Node
# WeaponRegistry.gd
# Stores runtime stats for every weapon by string ID.
# Weapons read from here on _ready() and per-shot.
# WeaponStatEffect writes into here via apply().

# Base stats are defined here. Add a new entry for each weapon you add.
#TODO: Make this use a resource tbh
var _registry: Dictionary = {
	"basic_gun": {
		"fire_rate": 0.5,      # seconds between shots (lower = faster)
		"damage": 1.0,
		"bullet_speed": 800.0,
	}
}

func get_stat(weapon_id: String, stat_name: String) -> float:
	if not _registry.has(weapon_id):
		push_error("WeaponRegistry: unknown weapon_id '%s'" % weapon_id)
		return 0.0
	if not _registry[weapon_id].has(stat_name):
		push_error("WeaponRegistry: weapon '%s' has no stat '%s'" % [weapon_id, stat_name])
		return 0.0
	return _registry[weapon_id][stat_name]

func set_stat(weapon_id: String, stat_name: String, value: float) -> void:
	if not _registry.has(weapon_id):
		push_error("WeaponRegistry: unknown weapon_id '%s'" % weapon_id)
		return
	_registry[weapon_id][stat_name] = value

func modify_stat(weapon_id: String, stat_name: String, delta: float) -> void:
	var current = get_stat(weapon_id, stat_name)
	set_stat(weapon_id, stat_name, current + delta)

func register_weapon(weapon_id: String, base_stats: Dictionary) -> void:
	# Called by WeaponUnlockEffect when a new weapon is unlocked.
	# Safe to call again — won't overwrite if already registered (e.g. on load replay).
	if not _registry.has(weapon_id):
		_registry[weapon_id] = base_stats
