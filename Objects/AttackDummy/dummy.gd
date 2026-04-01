extends Node2D

@export var value : float = 5.0

@onready var health_component: HealthComponent = %HealthComponent
@onready var stun_marker: Marker2D = %StunMarker

@onready var stun_fx_ps = preload("res://Objects/VFX/StunFX/stun_fx.tscn")

func _ready() -> void:
	health_component.died.connect(func():
		Globals.money += value
		var stun_fx = stun_fx_ps.instantiate()
		stun_marker.add_child(stun_fx)
		await health_component.revived
		stun_fx.queue_free()
	)
