class_name UpgradeState extends Resource

var active_effects : Array[UpgradeEffect] = []

func add_effect(effect: UpgradeEffect):
	active_effects.append(effect)
