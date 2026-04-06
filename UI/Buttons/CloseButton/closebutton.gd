extends TextureButton

@export var radius := 1.0
@export var speed := 2.0

var _time := 0.0
var _base_position : Vector2

func _ready() -> void:
	_base_position = self.position

func _process(delta: float) -> void:
	_time = fmod(_time + delta * speed, TAU)
	
	position = _base_position + Vector2(
		cos(_time),
		sin(_time)
	) * radius


func _on_pressed() -> void:
	get_parent().hide()
