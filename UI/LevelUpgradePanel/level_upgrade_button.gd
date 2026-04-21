class_name LevelUpgradeButton extends Button

# Assign the matching LevelUpgradeData .tres in the inspector
@export var level_data: LevelUpgradeData = null

@onready var _bar: LevelSelectBar = get_parent()


func _ready() -> void:
	pressed.connect(_on_pressed)
	_bar.unlocked_changed.connect(func(state): visible = state)
	visible = _bar.unlocked


func _on_pressed() -> void:
	print("pressed")
	if level_data == null:
		push_error("LevelUpgradeButton: no LevelUpgradeData assigned.")
		return
	# Find the single shared panel by group rather than NodePath
	var panel : LevelUpgradePanel = get_tree().get_first_node_in_group("level_upgrade_panel") as LevelUpgradePanel
	if panel == null:
		push_error("LevelUpgradeButton: no node in group 'level_upgrade_panel' found.")
		return
	panel.open_for_level(level_data)
