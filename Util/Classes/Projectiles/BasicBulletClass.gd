class_name basicBullet extends Area2D

@export var bullet_data : projectileData
@export var HIT_FX : Array[PackedScene]

func _ready() -> void:
	self.top_level = true

func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * bullet_data.speed * delta
	bullet_data.lifetime -= delta
	if bullet_data.lifetime <= 0:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0.024, 0.024, 0.024, 0.0), 0.3)
		tween.tween_callback(queue_free)


func _on_hitbox_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		## Compose attack
		var attack = Attack.new()
		attack.attack_damage   = bullet_data.damage
		attack.crit_chance     = bullet_data.crit_chance
		attack.crit_modifier   = bullet_data.crit_modifier
		attack.attack_position = self.global_position
		attack.knockback_force = bullet_data.knockback
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
		
		queue_free()
