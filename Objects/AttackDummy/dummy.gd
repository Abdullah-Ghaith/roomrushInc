extends Node2D

@export var value : float = 5.0

@onready var health_component: HealthComponent = %HealthComponent


func _ready() -> void:
	health_component.died.connect(func():
		Globals.money += value
	)
