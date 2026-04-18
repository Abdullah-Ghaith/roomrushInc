extends AnimatableBody2D

@export var disentigration_generator : Node = null

@onready var dusting_animation_player: AnimationPlayer = %DustingAnimationPlayer
@onready var sprite: Sprite2D = $Sprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if disentigration_generator:
		disentigration_generator.trigger.connect(_handle_disentigration)

func _handle_disentigration() -> void:
	dusting_animation_player.play("Dust")

func set_highlight(enable : bool) -> void:
	sprite.material.set_shader_parameter("enabled", enable)


func remove_shader() -> void:
	sprite.set_material(null)
