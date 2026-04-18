class_name PlatformerEnemy extends CharacterBody2D
# TODO: NUDGE_SPEED = 300 gives a ledge LEAPER — would make a great enemy type!

# -- Node References --
@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var nav_update_timer: Timer = %Timer
@onready var ray_cast_left: RayCast2D = %RayCastLeft
@onready var ray_cast_right: RayCast2D = %RayCastRight
@onready var health_component: HealthComponent = %HealthComponent
@onready var dusting_animation_player: AnimationPlayer = %DustingAnimationPlayer
@onready var sprite: Sprite2D = $Sprite

# -- Tuning --
@export var movement_speed: float = 180.0
@export var jump_force: float = 500.0
@export var knockback_friction: float = 800.0  # how fast knockback decelerates

const LEDGE_NUDGE_SPEED: float = 30.0
const SMALL_JUMP_RATIO: float = 3.0
const JUMP_DIRECTION_THRESHOLD: float = -0.62
const JUMP_HEIGHT_THRESHOLD: float = 10.0  # min Y diff to trigger a jump

# -- State --
var player: CharacterBody2D = null
var was_on_floor: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var enemy_active: bool = false


# ============================================================

func _clean_up() -> void:
		self.remove_from_group("Enemy")
		sprite.set_material(null)
		for child in get_children():
			if child is CollisionShape2D:
				child.disabled = true

func _ready() -> void:
	health_component.died.connect(func(): 
		self.remove_from_group("Enemy")
		CombatBus.enemyDied.emit()
		dusting_animation_player.play("Dust")
		await dusting_animation_player.animation_finished
		self.queue_free()
		)
	sprite.material = sprite.material.duplicate()


func _physics_process(delta: float) -> void:
	if not player:
		return

	enemy_active = _has_line_of_sight()
	print(enemy_active)
	if not enemy_active:
		return

	# drain knockback over time
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		move_and_slide()
		return  # skip nav while being knocked back

	if _handle_navigation_finished():
		return
	if not nav_agent.is_target_reached():
		if not is_on_floor():
			_handle_airborne(delta)
			return
		_handle_grounded()

# ============================================================

func _handle_navigation_finished() -> bool:
	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		move_and_slide()
		return true
	return false

func _handle_airborne(delta: float) -> void:
	velocity += get_gravity() * delta
	if was_on_floor: 
		# just left the ground — switch to air navmesh layer
		nav_agent.set_navigation_layers(2)
		nav_agent.get_next_path_position()
	was_on_floor = false
	move_and_slide()

func _handle_grounded() -> void:
	nav_agent.set_navigation_layers(1)
	was_on_floor = true 

	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var nav_direction: Vector2 = to_local(next_path_pos).normalized()

	_apply_horizontal_movement(nav_direction)
	_try_jump(nav_direction, next_path_pos)
	_try_ledge_aid(nav_direction)

	move_and_slide()

func _apply_horizontal_movement(nav_direction: Vector2) -> void:
	velocity.x = nav_direction.x * movement_speed

func _try_jump(nav_direction: Vector2, next_path_pos: Vector2) -> void:
	var target_is_above: bool = nav_direction.y < JUMP_DIRECTION_THRESHOLD
	var not_a_local_blip: bool = next_path_pos.y - player.global_position.y > JUMP_HEIGHT_THRESHOLD
	if target_is_above and not_a_local_blip and is_on_floor():
		velocity.y = -jump_force

func _try_ledge_aid(nav_direction: Vector2) -> void:
	if not is_on_floor():
		return
	var falling_left: bool = not ray_cast_left.is_colliding() and nav_direction.x < 0
	var falling_right: bool = not ray_cast_right.is_colliding() and nav_direction.x > 0
	if falling_left:
		velocity.x -= LEDGE_NUDGE_SPEED
		_small_jump()
	elif falling_right:
		velocity.x += LEDGE_NUDGE_SPEED
		_small_jump()

func _small_jump() -> void:
	velocity.y = -jump_force / SMALL_JUMP_RATIO

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func set_highlight(enable : bool) -> void:
	if sprite.material:
		sprite.material.set_shader_parameter("enabled", enable)
# ============================================================

func _on_timer_timeout() -> void:
	if not player:
		nav_update_timer.start()
		player = get_tree().get_first_node_in_group("Player")
		return
	if nav_agent.target_position != player.global_position:
		nav_agent.target_position = player.global_position
	var mext = nav_agent.get_next_path_position()
	nav_update_timer.start()

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
