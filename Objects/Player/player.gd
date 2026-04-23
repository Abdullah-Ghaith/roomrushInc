extends CharacterBody2D

# --- Node refs ---
@onready var health_component: HealthComponent = $HealthComponent #TODO use a shader like the potion one for health

# --- Internal state ---
var _jumps_remaining: int = 0
var _is_on_wall_last_frame: bool = false
var _dash_cooldown_remaining: float = 0.0
var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_direction: float = 1.0
var _is_sliding: bool = false


func _ready() -> void:
	# Set max health from PlayerStats
	health_component.MAX_HEALTH = PlayerStats.max_health

	# Vampirism — heal on hit if unlocked
	CombatBus.player_hit_landed.connect(func(damage: float):
		if PlayerStats.vampirism_enabled:
			health_component.health = minf(
				health_component.health + damage * 0.1,
				health_component.MAX_HEALTH
			)
	)

	add_to_group("Player")


func _physics_process(delta: float) -> void:
	# --- Dash cooldown tick ---
	if _dash_cooldown_remaining > 0.0:
		_dash_cooldown_remaining -= delta

	# --- Active dash ---
	if _is_dashing:
		_dash_timer -= delta
		velocity.x = _dash_direction * PlayerStats.dash_speed
		velocity.y = 0.0
		if _dash_timer <= 0.0:
			_is_dashing = false
		move_and_slide()
		return  # skip normal movement during dash

	# --- Gravity ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Fast fall (press down at apex, like Smash) ---
	if PlayerStats.fast_fall_enabled:
		if Input.is_action_just_pressed("move_down") and not is_on_floor() and velocity.y >= -50.0:
			velocity.y = 600.0

	# --- Reset jumps on landing ---
	if is_on_floor():
		_jumps_remaining = PlayerStats.double_jump_count if PlayerStats.double_jump_enabled else 0
		_is_sliding = false

	# --- Jump ---
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			_perform_jump()
		elif PlayerStats.wall_jump_enabled and is_on_wall():
			_perform_wall_jump()
		elif _jumps_remaining > 0:
			_jumps_remaining -= 1
			_perform_jump()

	# --- Dash ---
	if PlayerStats.dash_enabled:
		if Input.is_action_just_pressed("dash") and _dash_cooldown_remaining <= 0.0:
			_start_dash()

	# --- Slide ---
	if PlayerStats.slide_enabled:
		_is_sliding = Input.is_action_pressed("move_down") and is_on_floor()

	# --- Horizontal movement ---
	var direction := Input.get_axis("move_left", "move_right")
	var current_speed = PlayerStats.speed * (0.4 if _is_sliding else 1.0)

	if direction:
		velocity.x = direction * current_speed
		if not _is_dashing:
			_dash_direction = direction  # track last direction for dash
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()
	_is_on_wall_last_frame = is_on_wall()


func _perform_jump() -> void:
	velocity.y = -PlayerStats.jump_force


func _perform_wall_jump() -> void:
	# Push away from the wall
	var wall_normal := get_wall_normal()
	velocity.x = wall_normal.x * PlayerStats.speed
	velocity.y = -PlayerStats.jump_force


func _start_dash() -> void:
	_is_dashing = true
	_dash_timer = PlayerStats.dash_duration
	_dash_cooldown_remaining = PlayerStats.dash_cooldown
	# Dash in the direction the player is moving, or facing if idle
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		_dash_direction = direction
