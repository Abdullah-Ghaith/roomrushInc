class_name EnemyClearTrigger extends Trigger

@export var enemies: Array[Node]
var _num_dead: int = 0

func _ready() -> void:
	for enemy in enemies:
		enemy.health_component.died.connect(_on_enemy_died)

func _check_trigger() -> void:
	if _num_dead >= enemies.size():
		trigger.emit()

func _on_enemy_died() -> void:
	_num_dead += 1
	_check_trigger()

func highlight_enemies() -> void:
	for enemy in enemies:
		if enemy.has_method("set_highlight"):
			enemy.set_highlight(true)
