class_name PlatformerEnemy extends BaseEnemy
# TODO: NUDGE_SPEED = 300 gives a ledge LEAPER — would make a great enemy type!

@onready var ray_cast_left: RayCast2D = %RayCastLeft
@onready var ray_cast_right: RayCast2D = %RayCastRight

@export var jump_force: float = 500.0

var was_on_floor: bool = true

const LEDGE_NUDGE_SPEED: float = 30.0
const SMALL_JUMP_RATIO: float = 3.0
const JUMP_DIRECTION_THRESHOLD: float = -0.62
const JUMP_HEIGHT_THRESHOLD: float = 10.0

func _handle_active_physics(delta: float) -> void:
	if _handle_navigation_finished():
		return
	if not nav_agent.is_target_reached():
		if not is_on_floor():
			_handle_airborne(delta)
			return
		_handle_grounded()

func _handle_airborne(delta: float) -> void:
	velocity += get_gravity() * delta
	if was_on_floor:
		nav_agent.set_navigation_layers(2)
		nav_agent.get_next_path_position()
	was_on_floor = false
	move_and_slide()

func _handle_grounded() -> void:
	nav_agent.set_navigation_layers(1)
	was_on_floor = true
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var nav_direction: Vector2 = to_local(next_path_pos).normalized()
	velocity.x = nav_direction.x * movement_speed
	_try_jump(nav_direction, next_path_pos)
	_try_ledge_aid(nav_direction)
	move_and_slide()

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
