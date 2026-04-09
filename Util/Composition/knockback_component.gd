extends Node2D
class_name KnockbackComponent

@export var hitbox_component: HitboxComponent
@export var character_body: CharacterBody2D

# how much to scale the knockback force from the attack
@export var knockback_multiplier: float = 1.0  

func _ready() -> void:
	hitbox_component.took_knockback.connect(_apply_knockback)

func _apply_knockback(attack: Attack) -> void:
	if not character_body:
		return
	var knockback_direction = (character_body.global_position - attack.attack_position).normalized()
	var force = knockback_direction * attack.knockback_force * knockback_multiplier
	if character_body.has_method("apply_knockback"):
		character_body.apply_knockback(force)
	else:
		character_body.velocity += force
