class_name SaveGame extends Resource

const SAVE_GAME_PATH : String = "user://savegame.tres"

@export var money : float = CurrencyManager.money
@export var level_best_times: Dictionary = {}     # scene_path -> best_time (float)
@export var level_time_ticks: Dictionary = {}     # scene_path -> tick amount (float)
@export var purchased_upgrades: Dictionary = {}   # skill_id (String) -> level (int)

func write_savegame() -> void:
	ResourceSaver.save(self, SAVE_GAME_PATH)

static func load_savegame() -> SaveGame:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return load(SAVE_GAME_PATH) as SaveGame
	return null
