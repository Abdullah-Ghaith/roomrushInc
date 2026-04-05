extends Node

var current_save : SaveGame = null


func save_game():
	var current_save = SaveGame.new()
	
	## Fields to populate
	current_save.money = Globals.money
	
	current_save.write_savegame()

func load_game():
	current_save = SaveGame.load_savegame()
	if current_save:
		Globals.money = current_save.money
	else:
		current_save = SaveGame.new()
		print("No save file found, starting fresh")
