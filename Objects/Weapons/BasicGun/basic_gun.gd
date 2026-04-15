class_name BasicGun extends Node2D


@export var bullet_scene : PackedScene = null
@export var FIRE_CD : float = 0.5

@onready var shooting_point: Marker2D = %"Shooting Point"
@onready var gun_sprite: Sprite2D = %"Gun Sprite"

var curr_fire_cd : float = FIRE_CD 

func _physics_process(delta: float) -> void:
	# Rotate gun with mouse
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	rotation = wrapf(rotation, -PI, PI)
	if rotation > PI/2 or rotation < -PI/2:
		gun_sprite.set_flip_v(true)
	else:
		gun_sprite.set_flip_v(false)
	curr_fire_cd -= delta
	

	if curr_fire_cd > 0.0:
		return
		
	if Input.is_action_pressed("shoot"):
		curr_fire_cd = FIRE_CD
		
		var bullet = bullet_scene.instantiate()
		bullet.global_position = shooting_point.global_position
		bullet.global_rotation = shooting_point.global_rotation
		shooting_point.add_child(bullet)
		
