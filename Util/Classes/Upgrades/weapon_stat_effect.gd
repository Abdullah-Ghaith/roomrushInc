class_name WeaponStatEffect extends UpgradeEffect

# Modifies a named stat on a registered weapon in WeaponRegistry.
# Example: weapon_id = "basic_gun", stat_name = "fire_rate", bonus = -0.05
# (negative bonus reduces fire_rate cooldown, making the gun shoot faster)

@export var weapon_id: String = ""
@export var stat_name: String = ""
@export var bonus_per_level: float = 0.0

func apply(_level: int) -> void:
	if weapon_id == "" or stat_name == "":
		push_error("WeaponStatEffect: weapon_id or stat_name is empty.")
		return
	WeaponRegistry.modify_stat(weapon_id, stat_name, bonus_per_level)
