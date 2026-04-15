class_name EnemyGun extends Node2D
@export var bullet_scene: PackedScene = null

@onready var shooting_point: Marker2D = %"Shooting Point"
@onready var gun_sprite: Sprite2D = %"Gun Sprite"

var target: Node2D
var _track_tween: Tween

func _physics_process(_delta: float) -> void:
	if not target:
		return
	if _track_tween:
		_track_tween.kill()
	var target_angle = get_angle_to(target.global_position)
	_track_tween = create_tween()
	_track_tween.tween_property(self, "rotation", rotation + target_angle, 0.15)

	rotation = wrapf(rotation, -PI, PI)
	if rotation > PI/2 or rotation < -PI/2:
		gun_sprite.set_flip_v(true)
	else:
		gun_sprite.set_flip_v(false)

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = shooting_point.global_position
	bullet.global_rotation = shooting_point.global_rotation
	get_tree().root.add_child(bullet)

func set_target(new_target: Node) -> void:
	target = new_target
