extends Node
# CurrencyManager.gd
# scene_path -> money reward
@onready var level_reward_ticks: Dictionary = SaveManager.current_save.level_time_ticks

var money : float = 0 :
	set(value):
		var diff = abs(value - money)
		if value > money:
			money = value
			SignalBus.money_collected.emit(diff)
		elif value < money:
			money = value
			SignalBus.money_spent.emit(diff)
		SaveManager.save_game()


func _ready() -> void:
	SignalBus.level_period_elapsed.connect(func(_scene_path):
		self.money += level_reward_ticks[_scene_path]
		pass
		)

func add_level_tick(scene_path: String, tick_amount: float) -> void:
	level_reward_ticks[scene_path] = tick_amount
