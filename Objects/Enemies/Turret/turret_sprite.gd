extends AnimatedSprite2D

@onready var health_component: HealthComponent = %HealthComponent
@onready var on_fire_particles: GPUParticles2D = $"../OnFireParticles"

const TWEEN_DUR : float = 0.5 # seconds

var red_pulse_tween : Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#on_fire_particles.position = self.position - Vector2(0, 20)
	health_component.half_hp.connect(func():
		on_fire_particles.emitting = true
		_start_alert_tween()
		)
	health_component.died.connect(func():
		red_pulse_tween.kill()
		var fade_to_black_tween : Tween = create_tween()
		fade_to_black_tween.tween_property(self, "self_modulate", Color(0.094, 0.094, 0.094), TWEEN_DUR)
		)

func _start_alert_tween() -> void:
	red_pulse_tween = create_tween().set_loops()
	red_pulse_tween.tween_property(self, "self_modulate", Color(1.0, 0.612, 0.612), TWEEN_DUR)
	red_pulse_tween.tween_property(self, "self_modulate", Color.WHITE, TWEEN_DUR)
