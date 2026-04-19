class_name WeaponUnlockEffect extends UpgradeEffect

# Level 1 only: registers the weapon in WeaponRegistry with its base stats,
#               adds it to PlayerStats.unlocked_weapons, and emits a signal
#               so the upgrade table adds a new tab.
# This node should be a root-level (not child of another SkillNode) node
# in the Offence tree, enabled by default.

@export var weapon_id: String = ""
@export var base_stats: Dictionary = {}   # set in editor, e.g. {fire_rate: 0.5, damage: 1.0}

func apply(level: int) -> void:
	if weapon_id == "":
		push_error("WeaponUnlockEffect: weapon_id is empty.")
		return
	if level == 1:
		WeaponRegistry.register_weapon(weapon_id, base_stats)
		if not PlayerStats.unlocked_weapons.has(weapon_id):
			PlayerStats.unlocked_weapons.append(weapon_id)
			SignalBus.entity_unlocked.emit(weapon_id, "weapon")
