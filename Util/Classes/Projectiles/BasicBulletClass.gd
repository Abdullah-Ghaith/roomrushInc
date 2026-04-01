class_name basicBullet extends Area2D

@export var bullet_data : projectileData

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
		var attack = Attack.new()
		attack.attack_damage   = bullet_data.damage
		attack.attack_position = self.global_position
		attack.knockback_force = bullet_data.knockback
		area.take_damage(attack)
		queue_free()
