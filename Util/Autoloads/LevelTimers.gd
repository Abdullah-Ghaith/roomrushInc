extends Node

# each entry: { "scene_path": String, "period": float, "elapsed": float }
var timers: Array[Dictionary] = []


func get_progress(scene_path: String) -> float:
	for timer in timers:
		if timer["scene_path"] == scene_path:
			return timer["elapsed"] / timer["period"]
	return 0.0

#=============================================
func _ready() -> void:
	SignalBus.level_completed.connect(_on_level_completed)
	_build_timers()

func _build_timers() -> void:
	timers.clear()
	var best_times: Dictionary = SaveManager.current_save.level_best_times
	for scene_path in best_times:
		timers.append({
			"scene_path": scene_path,
			"period": best_times[scene_path],
			"elapsed": 0.0
		})

func _process(delta: float) -> void:
	for timer in timers:
		timer["elapsed"] += delta
		if timer["elapsed"] >= timer["period"]:
			timer["elapsed"] = 0.0
			SignalBus.level_period_elapsed.emit(timer["scene_path"])

func _on_level_completed(scene_path: String, completion_time: float) -> void:
	# update or add timer entry when a new best is set
	var current_best = SaveManager.current_save.level_best_times.get(scene_path, INF)
	if completion_time < current_best:
		for timer in timers:
			if timer["scene_path"] == scene_path:
				timer["period"] = completion_time
				timer["elapsed"] = 0.0
				return
		# not found — add a new entry
		timers.append({
			"scene_path": scene_path,
			"period": completion_time,
			"elapsed": 0.0
		})
