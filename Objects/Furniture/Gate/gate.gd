class_name DustableGate extends AnimatableBody2D

@export var disentigration_generator : Node = null

@onready var dusting_animation_player: AnimationPlayer = %DustingAnimationPlayer
@onready var sprite: Sprite2D = $Sprite
@onready var beam_spawn_point: Marker2D = %BeamSpawnPoint

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
			_enemy_lines[enemy].set_point_position(0, to_local(beam_spawn_point.global_position))
			_enemy_lines[enemy].set_point_position(1, to_local(_get_sprite_center(enemy)))

func track_enemy(enemy: BaseEnemy) -> void:
	var line : ConnectionBeam = preload("res://Objects/VFX/EnemyConnectionLine/enemy_connection_beam.tscn").instantiate()
	add_child(line)
	line.set_beam_between(to_local(beam_spawn_point.global_position), to_local(enemy.global_position))
	_enemy_lines[enemy] = line
	enemy.health_component.died.connect(func(): _on_enemy_died(enemy))

func _on_enemy_died(enemy: BaseEnemy) -> void:
	print('enemy died')
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

# ====
func _enable_collision() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _get_sprite_center(node: Node2D) -> Vector2:
	# tries to find a sprite and use its center, falls back to a fixed offset
	var sprite = node.get_node_or_null("Sprite2D")
	if sprite:
		return node.global_position + Vector2(0, -sprite.texture.get_height() * sprite.scale.y / 2.0)
	return node.global_position + Vector2(0, -16.0)  # fallback offset
