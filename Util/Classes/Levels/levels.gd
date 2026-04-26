class_name Level extends Node2D

@export var level_money : LevelMoney = null
@export var level_timer : LevelTimer = null
@export var level_condition: LevelCondition


func _ready() -> void:
	level_condition.level_condition_reached.connect(func():
		var scene_path = get_tree().current_scene.scene_file_path
		CurrencyManager.money += level_money.completion_value
		CurrencyManager.add_level_tick(scene_path, level_money.tick_value)
		SignalBus.level_completed.emit(scene_path, level_timer.elapsed_time)
		SignalBus.emit_end_shockwave.emit(level_condition.get_shock_position())
		)
 
