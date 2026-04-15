class_name ReachEndLevelCondition extends LevelCondition

@export var exit_portal : ExitPortal = null

func _ready() -> void:
	if exit_portal:
		exit_portal.player_detected.connect(level_condition_reached.emit)
