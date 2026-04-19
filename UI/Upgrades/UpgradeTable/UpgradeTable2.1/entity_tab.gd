class_name EntityTab extends Panel

const ACTIVE_SCALE = Vector2(1.15, 1.15)
const NORMAL_SCALE = Vector2(1, 1)
const ACTIVE_OFFSET = 30
const NORMAL_OFFSET = 0

var entity_id: String = ""
var entity_type: String = ""
var active := false

@onready var label: Label = $MarginContainer/Label


func setup(id: String, type: String, display_name: String) -> void:
	entity_id = id
	entity_type = type
	label.text = display_name


func set_active(state: bool) -> void:
	active = state
	var tween = create_tween()
	if active:
		tween.tween_property(self, "scale", ACTIVE_SCALE, 0.15)
		tween.tween_property(self, "position:x", float(NORMAL_OFFSET + ACTIVE_OFFSET), 0.15)
		modulate.a = 1.0
	else:
		tween.tween_property(self, "scale", NORMAL_SCALE, 0.15)
		tween.tween_property(self, "position:x", float(NORMAL_OFFSET), 0.15)
		modulate.a = 0.5
