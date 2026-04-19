extends Button

func _ready() -> void:
	pressed.connect(UpgradeManager.dev_reset_all_upgrades)
