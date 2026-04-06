extends AnimatedSprite2D

@onready var health_component: HealthComponent = %HealthComponent
@onready var stun_marker: Marker2D = %StunMarker
@onready var stun_fx_ps = preload("res://Objects/VFX/StunFX/stun_fx.tscn")

var death_tween : Tween

func _ready() -> void:
	health_component.damaged.connect(func(_amount, _is_crit):
		self.play("Hit")
		await self.animation_finished
		self.play("idle")
	)
	health_component.died.connect(_handle_died)
	health_component.revived.connect(_handle_revived)

func _handle_died() -> void:
	death_tween = create_tween().set_loops()
	death_tween.tween_property(self, "modulate", Color(0.0, 0.2, 0.6, 0.6), 0.4)
	death_tween.tween_property(self, "modulate", Color(0.0, 0.5, 0.5, 1.0), 0.4)
	
	var stun_fx = stun_fx_ps.instantiate()
	stun_marker.add_child(stun_fx)
	await health_component.revived
	stun_fx.queue_free()

func _handle_revived() -> void:
	if death_tween:
		death_tween.kill()
	modulate = Color.WHITE
