class_name LevelPayoutBonusEffect extends UpgradeEffect

# Increases a specific level's passive tick payout and/or one-time
# completion payout by a flat amount each level.

@export var scene_path: String = ""
@export var tick_bonus_per_level: float = 0.0
@export var completion_bonus_per_level: float = 0.0

func apply(_level: int) -> void:
	if scene_path == "":
		push_error("LevelPayoutBonusEffect: scene_path is empty.")
		return
	if tick_bonus_per_level != 0.0:
		var current = CurrencyManager.level_reward_ticks.get(scene_path, 0.0)
		CurrencyManager.level_reward_ticks[scene_path] = current + tick_bonus_per_level
	# completion_bonus would need a parallel dict in CurrencyManager if you
	# want it to persist across level loads — flag this for Step 8 expansion.
