class_name TransitionPortal extends Node2D

@onready var portal_particles: GPUParticles2D = %PortalParticles
@onready var player_detection_area: Area2D = %PlayerDetectionArea
@onready var e_to_interact: Node2D = %"E-to-interact"

var player_nearby : bool = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_nearby:
		self.enable()

func enable() -> void:
	portal_particles.emitting = true #for now, make this open up the actual menu for levels

func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		e_to_interact.reveal()
		player_nearby = true

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		e_to_interact.hide()
		player_nearby = false
