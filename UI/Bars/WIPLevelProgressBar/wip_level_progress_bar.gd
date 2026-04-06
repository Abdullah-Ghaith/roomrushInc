class_name LevelSelectBar extends Control

@export var level_scene : PackedScene = null
@export var unlocked : bool = false

@onready var level_progress_bar: TextureProgressBar = %LevelProgressBar
@onready var bg_panel: Panel = %BGPanel
@onready var lock_icon: TextureRect = %LockIcon
@onready var lock_icon_2: TextureRect = %LockIcon2

func _ready() -> void:
	if unlocked:
		level_progress_bar.self_modulate = Color.WHITE
		bg_panel.self_modulate = Color.WHITE
		lock_icon.hide()
		lock_icon_2.hide()
	else:
		level_progress_bar.self_modulate = Color.BLACK
		bg_panel.self_modulate = Color.BLACK
		lock_icon.show()
		lock_icon_2.show()

func _on_gui_input(event: InputEvent) -> void:
	if unlocked and event is InputEventMouseButton:
			if event.button_mask == 1: #LMB
				SceneManager.change_scene(level_scene, {"speed": 4, "pattern": "curtains"})
