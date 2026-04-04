class_name TransitionPortal extends Node2D

@onready var portal_particles: GPUParticles2D = %PortalParticles
@onready var player_detection_area: Area2D = %PlayerDetectionArea
@onready var e_to_interact: Node2D = %"E-to-interact"
@onready var money_requirement: MoneyReq = %MoneyRequirement

var player_nearby : bool = false
var enabled : bool = false :
	set(value):
		enabled = value
		enable(value)

func _ready() -> void:
	money_requirement.freed.connect(func():
		var tween = create_tween()
		tween.tween_property(e_to_interact, "position:y", -69.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_nearby:
		## Attempt to purchase portal upgrade
		if not enabled and Globals.money >= money_requirement.get_value():
			Globals.money -= money_requirement.get_value()
			money_requirement.fade_out()
			enabled = true
		
func enable(enable: bool) -> void:
	portal_particles.emitting = enable #for now, make this open up the actual menu for levels

func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		e_to_interact.reveal()
		player_nearby = true

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		e_to_interact.hide()
		player_nearby = false
