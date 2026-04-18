class_name ShooterEnemy extends CharacterBody2D

# -- Node References --
@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var nav_update_timer: Timer = %NavUpdateTimer
@onready var health_component: HealthComponent = %HealthComponent
@onready var dusting_animation_player: AnimationPlayer = %DustingAnimationPlayer
@onready var shoot_timer: Timer = %ShootTimer
@onready var detection_range: Area2D = %DetectionRange
@onready var enemy_gun: EnemyGun = %EnemyGun
@onready var sprite: Sprite2D = $Sprite

# -- Tuning --
@export var movement_speed: float = 180.0
@export var knockback_friction: float = 800.0
@export var shoot_cd_s: float = 0.5


# -- State --
var player: CharacterBody2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
var enemy_active: bool = false

# ============================================================
func _clean_up() -> void:
		self.remove_from_group("Enemy")
		detection_range.queue_free()
		shoot_timer.stop()
		enemy_gun.queue_free()
		sprite.set_material(null)

func _ready() -> void:
	health_component.died.connect(func(): 
		_clean_up()
		CombatBus.enemyDied.emit()
		dusting_animation_player.play("Dust")
		await dusting_animation_player.animation_finished
		self.queue_free()
		)
	
	shoot_timer.set_wait_time(shoot_cd_s)
	sprite.material = sprite.material.duplicate()

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	enemy_active = _has_line_of_sight()
	if not enemy_active:
		return

	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		move_and_slide()
		return

	if _handle_navigation_finished():
		return

	if not nav_agent.is_target_reached():
		_handle_grounded()

# ============================================================

func _handle_navigation_finished() -> bool:
	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		move_and_slide()
		return true
	return false

func _handle_grounded() -> void:
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var nav_direction: Vector2 = to_local(next_path_pos).normalized()
	velocity.x = nav_direction.x * movement_speed
	move_and_slide()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func set_highlight(enable : bool) -> void:
	sprite.material.set_shader_parameter("enabled", enable)

# ============================================================

func _on_timer_timeout() -> void:
	if not player:
		nav_update_timer.start()
		player = get_tree().get_first_node_in_group("Player")
		return
	if nav_agent.target_position != player.global_position:
		nav_agent.target_position = player.global_position
	nav_update_timer.start()


func _on_detection_range_body_entered(body: Node2D) -> void:
	if body == player:
		enemy_gun.set_target(player)
		shoot_timer.start(shoot_cd_s)


func _on_detection_range_body_exited(body: Node2D) -> void:
	if body == player:
		enemy_gun.set_target(null)
		shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	enemy_gun.shoot()
	shoot_timer.start(shoot_cd_s)


func _has_line_of_sight() -> bool:
	if player == null:
		return false

	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	# Exclude the object itself so it doesn't block its own raycast
	query.exclude = [self]
	query.collision_mask = 2  # this is binary layer 2 — hits buildings
	
	var result := space.intersect_ray(query)

	# LOS is clear only if we hit the player — any other hit means a wall is in the way
	return result.is_empty() or result.collider == player
