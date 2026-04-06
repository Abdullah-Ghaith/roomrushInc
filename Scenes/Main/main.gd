extends Node2D

@onready var zone_1_transition_portal: TransitionPortal = %Zone1TransitionPortal
@onready var zone_1_level_select_ui: Control = %Zone1LevelSelectUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveManager.load_game()
	zone_1_transition_portal.transition_portal_interact.connect(zone_1_level_select_ui.show)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_timer_timeout() -> void:
	SaveManager.save_game()
