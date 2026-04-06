extends AnimatedSprite2D

@onready var health_component: HealthComponent = %HealthComponent
@onready var on_fire_particles: GPUParticles2D = $"../OnFireParticles"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#on_fire_particles.position = self.position - Vector2(0, 20)
	health_component.half_hp.connect(func():
		on_fire_particles.emitting = true
		_start_alert_tween()
		)

func _start_alert_tween() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "self_modulate", Color(1.0, 0.612, 0.612), 0.5)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
