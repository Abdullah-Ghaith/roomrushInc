class_name BaseEnemy extends CharacterBody2D

# -- Node References --
@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var nav_update_timer: Timer = %NavUpdateTimer
@onready var health_component: HealthComponent = %HealthComponent
@onready var dusting_animation_player: AnimationPlayer = %DustingAnimationPlayer
@onready var sprite: Sprite2D = $Sprite

# -- Tuning --
@export var movement_speed: float = 180.0
@export var knockback_friction: float = 800.0
@export var active_range: float = 1000.0

# -- State --
var player: CharacterBody2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
var enemy_active: bool = false


# -- Consts --
const WORLD_GEO_LAYER = 0b10
const WORLD_OBSTACLE_LAYER = 0b1000_0000
# ============================================================

func _clean_up() -> void:
	self.remove_from_group("Enemy")
	sprite.set_material(null)

# override in subclass to add extra cleanup
func _clean_up_extended() -> void:
	pass

func _ready() -> void:
	sprite.material = sprite.material.duplicate()
	health_component.died.connect(func():
		_clean_up()
		_clean_up_extended()
		CombatBus.enemyDied.emit()
		dusting_animation_player.play("Dust")
		await dusting_animation_player.animation_finished
		self.queue_free()
		)

func _physics_process(delta: float) -> void:
	if not player:
		return
	enemy_active = _has_path_to_player() and ( _player_within_range() or _has_line_of_sight())
	if not enemy_active:
		return
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		move_and_slide()
		return
	_handle_active_physics(delta)

# override this in subclasses for custom movement logic
func _handle_active_physics(_delta: float) -> void:
	if _handle_navigation_finished():
		return
	if not nav_agent.is_target_reached():
		_handle_grounded()

func _handle_navigation_finished() -> bool:
	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		move_and_slide()
		return true
	return false

# override in subclass for custom grounded behavior
func _handle_grounded() -> void:
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var nav_direction: Vector2 = to_local(next_path_pos).normalized()
	velocity.x = nav_direction.x * movement_speed
	move_and_slide()

func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force

func set_highlight(enable: bool) -> void:
	if sprite.material:
		sprite.material.set_shader_parameter("enabled", enable)

func _on_timer_timeout() -> void:
	if not player:
		nav_update_timer.start()
		player = get_tree().get_first_node_in_group("Player")
		return
	if nav_agent.target_position != player.global_position:
		nav_agent.target_position = player.global_position
	nav_agent.get_next_path_position()
	nav_update_timer.start()

# ======================

func _has_line_of_sight() -> bool:
	if player == null:
		return false
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.exclude = [self]
	query.collision_mask = WORLD_GEO_LAYER
	var result := space.intersect_ray(query)
	return result.is_empty() or result.collider == player

func _has_path_to_player() -> bool:
	if not player:
		return false
	var path = NavigationServer2D.map_get_path(
		nav_agent.get_navigation_map(),
		global_position,
		player.global_position,
		true
	)
	if path.size() < 2:
		return false
	
	# check each segment of the path against the gate's collision
	for i in range(path.size() - 1):
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(path[i], path[i + 1])
		query.collision_mask = WORLD_OBSTACLE_LAYER
		var result = space_state.intersect_ray(query)
		if result:
			return false
	
	return true

func _player_within_range() -> bool:
	return (player.global_position-self.global_position).length() < active_range
