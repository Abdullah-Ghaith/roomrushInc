class_name meleeAttackBox extends Area2D

@export var melee_data : meleeData
@export var health_component : HealthComponent
@export var HIT_FX : Array[PackedScene]

func _ready() -> void:
	health_component.died.connect(func():
		self.queue_free()
		)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		## Compose attack
		var attack = Attack.new()
		attack.attack_damage   = melee_data.damage
		attack.crit_chance     = melee_data.crit_chance
		attack.crit_modifier   = melee_data.crit_modifier
		attack.attack_position = self.global_position
		attack.knockback_force = melee_data.knockback
		area.take_damage(attack)
		
		## Spawn in VFX
		for fx in HIT_FX:
			var fx_node = fx.instantiate()
			# add rand for juice (TODO? Could make these rand values a part of the data class)
			fx_node.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8)) 
			fx_node.scale = Vector2.ONE * randf_range(0.8, 1.2)
			fx_node.rotation = randf_range(-0.3, 0.3)
			# add to root so it doesn't get freed with the bullet
			get_tree().root.add_child(fx_node)  
