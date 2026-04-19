class_name AbilityUnlockEffect extends UpgradeEffect

# Level 1: unlocks the ability by setting its flag on PlayerStats
#           and adding ability_id to PlayerStats.unlocked_abilities.
#           This causes the upgrade table to add a new tab.
# Level 2+: applies an optional numeric stat improvement on top.

@export var ability_id: String = ""          # e.g. "dash", "wall_jump"
@export var flag_name: String = ""           # e.g. "dash_enabled" on PlayerStats
@export var stat_name: String = ""           # optional — leave blank if no numeric upgrade
@export var bonus_per_level: float = 0.0     # only used if stat_name is set

func apply(level: int) -> void:
	if ability_id == "":
		push_error("AbilityUnlockEffect: ability_id is empty.")
		return
	if level == 1:
		# Set the boolean flag on PlayerStats
		if flag_name != "" and flag_name in PlayerStats:
			PlayerStats.set(flag_name, true)
		# Register as unlocked so the upgrade table can build the tab
		if not PlayerStats.unlocked_abilities.has(ability_id):
			PlayerStats.unlocked_abilities.append(ability_id)
			SignalBus.entity_unlocked.emit(ability_id, "ability")
	# Every level (including 1) applies the stat bonus if configured
	if stat_name != "" and bonus_per_level != 0.0:
		if stat_name in PlayerStats:
			PlayerStats.set(stat_name, PlayerStats.get(stat_name) + bonus_per_level)
		else:
			push_error("AbilityUnlockEffect: PlayerStats has no property '%s'." % stat_name)
