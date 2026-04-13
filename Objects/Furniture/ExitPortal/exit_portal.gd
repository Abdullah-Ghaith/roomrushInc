class_name ExitPortal extends Node2D


signal transition_portal_interact

@onready var portal_particles: GPUParticles2D = %PortalParticles
@onready var player_detection_area: Area2D = %PlayerDetectionArea
@onready var e_to_interact: eToInteract = %"E-to-interact"

var enabled : bool = false :
	set(value):
		enabled = value
		enable(value)


var player_nearby : bool = false

func _ready() -> void:
	SignalBus.level_completed.connect(func(_scene_path, _completion_time):
		enabled = true
		)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_nearby and enabled:
		transition_portal_interact.emit()
		#Placeholder
		SceneManager.change_scene("res://Scenes/Main/main.tscn", {"speed": 4, "pattern": "curtains"})


func enable(enable: bool) -> void:
	portal_particles.emitting = enable


func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and enabled:
		e_to_interact.reveal()
		player_nearby = true

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		e_to_interact.hide()
		player_nearby = false
