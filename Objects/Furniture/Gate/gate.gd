extends AnimatableBody2D

@export var disentigration_generator : Node = null

@onready var dusting_animation_player: AnimationPlayer = %DustingAnimationPlayer
@onready var sprite: Sprite2D = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_enable_collision()
	if disentigration_generator:
		disentigration_generator.trigger.connect(_handle_disentigration)

func _handle_disentigration() -> void:
	dusting_animation_player.play("Dust")

func set_highlight(enable : bool) -> void:
	sprite.material.set_shader_parameter("enabled", enable)

func clean_up() -> void:
	sprite.set_material(null)
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true

func _enable_collision() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false
