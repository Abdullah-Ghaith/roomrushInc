extends Panel


var active := false

const ACTIVE_SCALE = Vector2(1.15, 1.15)
const NORMAL_SCALE = Vector2(1,1)

const ACTIVE_OFFSET = 30
const NORMAL_OFFSET = 0

func set_active(state: bool):
	active = state
	
	var tween = create_tween()
	
	if active:
		tween.tween_property(self, "scale", ACTIVE_SCALE, 0.15)
		tween.tween_property(self, "position:x", NORMAL_OFFSET + ACTIVE_OFFSET, 0.15)
		self.modulate.a = 1.0
	else:
		tween.tween_property(self, "scale", NORMAL_SCALE, 0.15)
		tween.tween_property(self, "position:x", NORMAL_OFFSET, 0.15)
		self.modulate.a = 0.5
