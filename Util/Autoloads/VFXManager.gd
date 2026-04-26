# VFXManager.gd (autoload)
extends Node

const SHOCKWAVE = preload("res://Objects/VFX/ShockWave/shockwave.tscn")
const SLOW_DURATION = 1.5
const SLOW_SCALE = 0.2

var _shockwave_instance = null

func _ready() -> void:
	SignalBus.emit_end_shockwave.connect(_on_shockwave_request)

func _on_shockwave_request(world_position: Vector2) -> void:
	_play_shockwave(world_position)
	_slow_time()

func _play_shockwave(world_position: Vector2) -> void:
	if _shockwave_instance:
		_shockwave_instance.queue_free()
	_shockwave_instance = SHOCKWAVE.instantiate()
	get_tree().root.add_child(_shockwave_instance)
	
	## convert world position to screen UV (0-1)
	var viewport = get_viewport()
	var camera = get_viewport().get_camera_2d()
	var screen_pos = world_position - camera.global_position
	screen_pos += (Vector2(viewport.get_visible_rect().size) / 2.0)
	var uv = screen_pos / Vector2(viewport.get_visible_rect().size)
	
	var mat = _shockwave_instance.get_node("ShockWave").material
	mat.set_shader_parameter("center", uv)
	mat.set_shader_parameter("radius", 0.0)
	mat.set_shader_parameter("strength", 0.08)
	
	_shockwave_instance.get_node("AnimationPlayer").play("shockwave_pulse")

func _slow_time() -> void:
	Engine.time_scale = SLOW_SCALE
	# use a real-time timer so it isn't affected by the slow
	await get_tree().create_timer(SLOW_DURATION, true, false, true).timeout
	Engine.time_scale = 1.0
