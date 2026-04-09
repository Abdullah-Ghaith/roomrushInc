class_name DamageNumberSpawner extends Node2D

const TOP_Z_LEVEL: int = 1000

@export_group("References")
@export var label_settings: LabelSettings
@export var health_component: HealthComponent

@export_group("Colors")
@export var critical_hit_color: Color = Color(0.0, 0.5, 0.5, 1.0)

@export_group("Movement")
@export var horizontal_spread: Vector2 = Vector2(-5.0, 5.0)   # min/max X drift
@export var vertical_rise: Vector2 = Vector2(-22.0, -16.0)    # min/max Y rise

@export_group("Animation")
@export var tween_length: float = 0.92
@export var pop_scale: float = 1.35
@export var tween_transition: Tween.TransitionType = Tween.TRANS_BACK
@export var tween_ease: Tween.EaseType = Tween.EASE_OUT

func _ready() -> void:
	health_component.damaged.connect(func(_amount, _is_crit):
		spawn_label(_amount, _is_crit))

func spawn_label(number: float, critical_hit: bool = false) -> void:
	var new_label: Label = Label.new()
	new_label.top_level = true
	new_label.global_position = get_parent().global_position
	new_label.text = str(number)
	new_label.label_settings = label_settings.duplicate()
	new_label.z_index = TOP_Z_LEVEL
	new_label.pivot_offset = Vector2(0.5, 1.0)
	if critical_hit:
		new_label.label_settings.font_color = critical_hit_color

	call_deferred("add_child", new_label)
	await new_label.resized
	new_label.position -= Vector2(new_label.size.x / 2.0, new_label.size.y)

	var drift := Vector2(randf_range(horizontal_spread.x, horizontal_spread.y),
						 randf_range(vertical_rise.x, vertical_rise.y))
	var target_rise_pos: Vector2 = new_label.position + drift

	var label_tween: Tween = create_tween().set_trans(tween_transition).set_ease(tween_ease)
	label_tween.tween_property(new_label, "position", target_rise_pos, tween_length)
	label_tween.parallel().tween_property(new_label, "scale", Vector2.ONE * pop_scale, tween_length)
	label_tween.parallel().tween_property(new_label, "modulate:a", 0.0, tween_length).connect("finished", new_label.queue_free)
