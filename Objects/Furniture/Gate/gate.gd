class_name DustableGate extends AnimatableBody2D

@export var disentigration_generator : Node = null

@onready var dusting_animation_player: AnimationPlayer = %DustingAnimationPlayer
@onready var sprite: Sprite2D = $Sprite

var _enemy_lines: Dictionary = {}  # enemy -> Line2D
var drawing : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_enable_collision()
	if disentigration_generator:
		disentigration_generator.trigger.connect(_handle_disentigration)

func _process(_delta: float) -> void:
	if not drawing:
		return
	for enemy in _enemy_lines:
		if is_instance_valid(enemy):
			_enemy_lines[enemy].set_point_position(0, to_local(global_position))
			_enemy_lines[enemy].set_point_position(1, to_local(enemy.global_position))

func track_enemy(enemy: BaseEnemy) -> void:
	var line = Line2D.new()
	line.default_color = Color(1.0, 0.2, 0.2, 0.8)
	line.width = 2.0
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	add_child(line)
	_enemy_lines[enemy] = line
	# listen for death directly
	if enemy.has_signal("died"):
		enemy.health_component.died.connect(func(): _on_enemy_died(enemy))

func _on_enemy_died(enemy: BaseEnemy) -> void:
	if enemy in _enemy_lines:
		_enemy_lines[enemy].queue_free()
		_enemy_lines.erase(enemy)

func _handle_disentigration() -> void:
	dusting_animation_player.play("Dust")

func set_highlight(enable : bool) -> void:
	sprite.material.set_shader_parameter("enabled", enable)
	drawing = enable

func clean_up() -> void:
	sprite.set_material(null)
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true

func _enable_collision() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false
