extends TextureProgressBar

@onready var health_component: HealthComponent = %HealthComponent
var death_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_max( health_component.MAX_HEALTH)
	
	health_component.damaged.connect(_handle_damaged)
	health_component.died.connect(_handle_died)
	health_component.revived.connect(_handle_revived)


func _handle_damaged(amount: float) -> void:
	# Update progress
	var curr_progress: float = self.get_value()
	curr_progress -= amount
	self.set_value_no_signal(curr_progress)
	
	# Lerp color from green to orange
	var hp_ratio = curr_progress / health_component.MAX_HEALTH
	self.self_modulate = Color(0.0, 0.886, 0.149).lerp(Color(0.981, 0.386, 0.0), 1.0 - hp_ratio)

func _handle_died() -> void:
	self.set_value_no_signal(health_component.MAX_HEALTH)
	
	death_tween = create_tween().set_loops()
	death_tween.tween_property(self, "self_modulate", Color(0.0, 0.2, 0.6, 0.6), 0.4)
	death_tween.tween_property(self, "self_modulate", Color(0.0, 0.5, 0.5, 1.0), 0.4)

func _handle_revived() -> void:
	if death_tween:
		death_tween.kill()
	self.self_modulate = Color(0.0, 0.886, 0.149)
