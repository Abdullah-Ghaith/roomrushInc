class_name LevelUpgradeButton extends Button
# Drop this button inside each WIPLevelProgressBar in the level select.
# Set level_panel to the matching LevelUpgradePanel instance,
# and level_display_name to a readable string like "Zone 1 - Level 1".

@export var level_panel: NodePath = ""
@export var level_display_name: String = "Level"

@onready var _panel: LevelUpgradePanel = get_node(level_panel)
@onready var _bar: LevelSelectBar = get_parent()


func _ready() -> void:
	pressed.connect(_on_pressed)
	# Hide button if level isn't unlocked yet
	_bar.unlocked_changed.connect(func(state): visible = state)
	visible = _bar.unlocked


func _on_pressed() -> void:
	if _bar.level_scene:
		_panel.open_for_level(_bar.level_scene.resource_path, level_display_name)
