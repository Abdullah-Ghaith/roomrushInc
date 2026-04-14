extends AnimatedSprite2D

@onready var health_component: HealthComponent = %HealthComponent
@onready var stun_marker: Marker2D = %StunMarker
@onready var stun_fx_ps = preload("res://Objects/VFX/StunFX/stun_fx.tscn")
@onready var gold_coins_ps = preload("res://Objects/VFX/GoldDrop/gold_drop.tscn")
@onready var gold_particles: GPUParticles2D = %goldParticles

var death_tween : Tween
var stun_fx     : AnimatedSprite2D
var gold_coins  : GPUParticles2D

func _ready() -> void:
	health_component.damaged.connect(func(_amount, _is_crit):
		self.play("Hit")
		await self.animation_finished
		self.play("idle")
	)
	health_component.died.connect(_handle_died)
	health_component.revived.connect(_handle_revived)
	
	stun_fx = stun_fx_ps.instantiate()
	stun_fx.hide()
	stun_marker.add_child(stun_fx)
	

func _handle_died() -> void:
	gold_particles.emitting = true
	death_tween = create_tween().set_loops()
	death_tween.tween_property(self, "modulate", Color(0.0, 0.2, 0.6, 0.6), 0.4)
	death_tween.tween_property(self, "modulate", Color(0.0, 0.5, 0.5, 1.0), 0.4)
	
	stun_fx.show()
	await health_component.revived
	stun_fx.hide()

func _handle_revived() -> void:
	if death_tween:
		death_tween.kill()
	modulate = Color.WHITE
