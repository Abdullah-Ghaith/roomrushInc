extends Area2D
class_name HitboxComponent


@export var health_component : HealthComponent
@onready var hitflash_animation_player: AnimationPlayer = %HitFlashAnimationPlayer


func take_damage(attack: Attack):
	if health_component and health_component.health > 0:
		health_component.take_damage(attack)
		if hitflash_animation_player:
			hitflash_animation_player.play("hit_flash")
