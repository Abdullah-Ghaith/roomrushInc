class_name StatBonusEffect extends UpgradeEffect

# Adds a flat bonus to a named stat on PlayerStats each level.
# Example: stat_name = "speed", bonus_per_level = 20.0
# At level 3 this will have added 60.0 total to PlayerStats.speed.

@export var stat_name: String = ""
@export var bonus_per_level: float = 0.0

func apply(_level: int) -> void:
	if stat_name == "":
		push_error("StatBonusEffect: stat_name is empty.")
		return
	if not stat_name in PlayerStats:
		push_error("StatBonusEffect: PlayerStats has no property '%s'." % stat_name)
		return
	PlayerStats.set(stat_name, PlayerStats.get(stat_name) + bonus_per_level)
