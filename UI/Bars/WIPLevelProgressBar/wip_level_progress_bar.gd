class_name LevelSelectBar extends Control

@export var level_scene: PackedScene = null
@export var unlocked: bool = false
@export var money_reward: float = 2.0

@onready var level_progress_bar: TextureProgressBar = %LevelProgressBar
@onready var bg_panel: Panel = %BGPanel
@onready var lock_icon: TextureRect = %LockIcon
@onready var lock_icon_2: TextureRect = %LockIcon2

var period: float = 0.0
var elapsed: float = 0.0
var has_best_time: bool = false

func _ready() -> void:
	if unlocked:
		lock_icon.hide()
		lock_icon_2.hide()
		level_progress_bar.self_modulate = Color.WHITE
		bg_panel.self_modulate = Color.WHITE
		_load_period()
		SignalBus.level_completed.connect(_on_level_completed)
	else:
		level_progress_bar.self_modulate = Color.BLACK
		bg_panel.self_modulate = Color.BLACK
		lock_icon.show()
		lock_icon_2.show()
		level_progress_bar.value = 0.0

func _load_period() -> void:
	if not level_scene:
		return
	var best = SaveManager.current_save.level_best_times.get(level_scene.resource_path, INF)
	if best != INF:
		period = best
		has_best_time = true
	else:
		has_best_time = false
		level_progress_bar.value = 0.0

func _process(delta: float) -> void:
	if not unlocked or not has_best_time or not is_visible_in_tree():
		return
	level_progress_bar.value = LevelTimers.get_progress(level_scene.resource_path) * 100.0


# Update period for best time if available
func _on_level_completed(scene_path: String, completion_time: float) -> void:
	if level_scene and scene_path == level_scene.resource_path:
		var current_best = SaveManager.current_save.level_best_times.get(scene_path, INF)
		if completion_time < current_best:
			period = completion_time
			elapsed = 0.0
			has_best_time = true

func _on_gui_input(event: InputEvent) -> void:
	if unlocked and event is InputEventMouseButton:
		if event.button_mask == 1:
			SceneManager.change_scene(level_scene, {"speed": 4, "pattern": "curtains"})
