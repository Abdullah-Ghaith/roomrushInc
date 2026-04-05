class_name LevelSelectBar extends Control

@export var level_scene : PackedScene = null


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
			if event.button_mask == 1: #LMB
				SceneManager.change_scene("res://UI/LevelSelectUI/level_select_ui.tscn", {"speed": 4})
