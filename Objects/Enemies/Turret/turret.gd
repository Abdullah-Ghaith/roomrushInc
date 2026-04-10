class_name Turret extends Node2D


@onready var detection_range: Area2D = %DetectionRange
@onready var geometry_ray_cast: RayCast2D = $GeometryRayCast
@onready var turret_sprite: AnimatedSprite2D = $TurretSprite
@onready var shoot_timer: Timer = %ShootTimer
@onready var shooting_point: Marker2D = %ShootingPoint
@onready var alert_sprite: Sprite2D = %AlertSprite
@onready var detection_range_shape: CollisionShape2D = %DetectionRangeShape
@onready var health_component: HealthComponent = $HealthComponent
@onready var pointer: Sprite2D = %Pointer

@export var bullet_scene : PackedScene = null
@export var range : float = 300.0:
	set(value):
		range = value
		if detection_range_shape:
			detection_range_shape.get_shape().radius = range
@export var health : float = 10.0
@onready var on_fire_particles: GPUParticles2D = $OnFireParticles

enum State { IDLE, TRACKING, SEARCHING }

var state: State = State.SEARCHING
var player_node: CharacterBody2D


# Search behaviour
var search_origin: float = 0.0       # the angle we sweep around
var search_amplitude: float = 0.6    # how wide the sweep is (radians)
var search_frequency: float = 0.4    # how fast the sweep oscillates
var search_time: float = 0.0         # accumulator driving the sin wave
var search_cycle_duration: float = 0.0  # how long before re-rolling params
var _track_tween: Tween
var _search_tween : Tween

func _ready() -> void:
	_randomize_search_params()
	health_component.died.connect(_handle_death)
	# Configure Child Nodes
	alert_sprite.position = self.position - Vector2(0, 60)
	on_fire_particles.position = self.position - Vector2(0, 20)
	detection_range_shape.get_shape().radius = range
	health_component.health = health

func _randomize_search_params() -> void:
	search_origin = rotation
	search_amplitude = randf_range(0.2, 0.25)
	search_frequency = randf_range(0.2, 0.4)
	search_time = 0.0
	# one full cycle = one full sin period, then re-roll
	search_cycle_duration = (1.0 / search_frequency) * randf_range(1.0, 3.0)

func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_node = body
		state = State.TRACKING

func _on_detection_range_body_exited(body: Node2D) -> void:
	player_node = null
	_randomize_search_params()
	state = State.SEARCHING

func _physics_process(delta: float) -> void:
	match state:
		State.TRACKING:
			if shoot_timer.is_stopped():
				shoot_timer.start(shoot_timer.wait_time)
			if _track_tween:
				_track_tween.kill()
			alert_sprite.show()
			geometry_ray_cast.target_position = to_local(player_node.position)

			## Track player if theyre not behind geometry, otherwise, enter search state
			if not geometry_ray_cast.is_colliding():
				var target_angle = get_angle_to(player_node.position)
				_track_tween = create_tween()
				_track_tween.tween_property(self, "rotation", rotation + target_angle, 0.15)
			else:
				_randomize_search_params()
				state = State.SEARCHING

		State.SEARCHING:
			shoot_timer.stop()
			alert_sprite.hide()
			search_time += delta
			if _search_tween:
				_search_tween.kill()
			_search_tween = create_tween()
			_search_tween.tween_property(self, "rotation", search_origin + sin(search_time * search_frequency * TAU) * search_amplitude, 0.15)

			if search_time >= search_cycle_duration:
				# Drift the origin slightly before re-rolling so it wanders
				search_origin += randf_range(-0.4, 0.4)
				_randomize_search_params()

			if player_node:
				geometry_ray_cast.target_position = to_local(player_node.position)
				if not geometry_ray_cast.is_colliding():
					state = State.TRACKING

func _handle_death() -> void:
	self.remove_from_group("Enemy")
	CombatBus.enemyDied.emit()
	self.state = State.IDLE
	pointer.hide()
	detection_range.set_deferred("monitoring", false)

func _on_shoot_timer_timeout() -> void:
	turret_sprite.play("Shoot")
	await turret_sprite.animation_finished
	var bullet = bullet_scene.instantiate()
	bullet.global_position = shooting_point.global_position
	bullet.global_rotation = shooting_point.global_rotation
	get_tree().root.add_child(bullet)
	turret_sprite.play("Idle")
	shoot_timer.start(shoot_timer.wait_time)
