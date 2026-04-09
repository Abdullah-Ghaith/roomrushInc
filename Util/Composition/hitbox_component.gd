extends Area2D
class_name HitboxComponent

@export var health_component: HealthComponent
@onready var hitflash_animation_player: AnimationPlayer = %HitFlashAnimationPlayer

signal took_knockback(attack: Attack)

func take_damage(attack: Attack) -> void:
	if health_component and health_component.health > 0:
		health_component.take_damage(attack)
		if hitflash_animation_player:
			hitflash_animation_player.play("hit_flash")
		if attack.knockback_force > 0.0:
			took_knockback.emit(attack)

func _ready():
	health_component.died.connect(func():
		set_deferred("monitorable", false)
		)
	
	health_component.revived.connect(func():
		set_deferred("monitorable", true)
		)
