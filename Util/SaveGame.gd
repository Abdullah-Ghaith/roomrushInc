class_name SaveGame extends Resource

const SAVE_GAME_PATH : String = "user://savegame.tres"

#upgrades unlocked, (levels unlocked bool, time per level, level upgrade), player cash 

@export var money : float = Globals.money

func write_savegame() -> void:
	ResourceSaver.save(self, SAVE_GAME_PATH)

static func load_savegame()-> SaveGame:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return load(SAVE_GAME_PATH) as SaveGame
	return null
