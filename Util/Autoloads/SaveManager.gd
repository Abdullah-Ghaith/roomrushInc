extends Node

var current_save : SaveGame = null

func _ready() -> void:
	load_game()
	SignalBus.level_completed.connect(_on_level_completed)

# =============================================================
# Update best time if possible
func _on_level_completed(scene_path: String, completion_time: float) -> void:
	var current_best = current_save.level_best_times.get(scene_path, INF)
	if completion_time < current_best:
		current_save.level_best_times[scene_path] = completion_time
	
	current_save.level_time_ticks = CurrencyManager.level_reward_ticks
	save_game()

# =============================================================
func save_game():
	## Fields to populate
	current_save.money = CurrencyManager.money
	
	current_save.write_savegame()

func load_game():
	current_save = SaveGame.load_savegame()
	if current_save:
		CurrencyManager.money = current_save.money
	else:
		current_save = SaveGame.new()
		print("No save file found, starting fresh")
