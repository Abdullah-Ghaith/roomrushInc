class_name LevelTimerReductionEffect extends UpgradeEffect

# Reduces a specific level's passive payout timer period by a percentage
# each level. Faster period = more frequent passive income.
# Example: reduction_percent_per_level = 0.05 → each level shaves 5% off
# the period, compounding: period *= (1.0 - 0.05) per apply() call.

@export var scene_path: String = ""
@export var reduction_percent_per_level: float = 0.05

func apply(_level: int) -> void:
	if scene_path == "":
		push_error("LevelTimerReductionEffect: scene_path is empty.")
		return
	for timer in LevelTimers.timers:
		if timer["scene_path"] == scene_path:
			timer["period"] = timer["period"] * (1.0 - reduction_percent_per_level)
			return
	push_warning("LevelTimerReductionEffect: no timer found for '%s'. Level not completed yet?" % scene_path)
