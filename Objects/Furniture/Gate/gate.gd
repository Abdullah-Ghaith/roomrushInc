extends AnimatableBody2D

@export var disentigration_generator : Node = null
@onready var dusting_animation_player: AnimationPlayer = %DustingAnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if disentigration_generator:
		disentigration_generator.trigger.connect(_handle_disentigration)

func _handle_disentigration():
	dusting_animation_player.play("Dust")
