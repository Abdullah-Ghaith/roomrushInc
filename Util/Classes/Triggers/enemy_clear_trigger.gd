class_name EnemyClearTrigger extends Trigger

@export var enemies: Array[Node]
@export var gate: DustableGate


func _ready() -> void:
	for enemy in enemies:
		enemy.health_component.died.connect(func(): _on_enemy_died(enemy))

func _check_trigger() -> void:
	if enemies.is_empty():
		trigger.emit()

func _on_enemy_died(enemy: BaseEnemy) -> void:
	enemies.erase(enemy)
	_check_trigger()

func highlight_enemies() -> void:
	for enemy in enemies:
		if enemy.has_method("set_highlight"):
			enemy.set_highlight(true)
		else:
			printerr("ENEMY HAS NO SET_HIGHLIHGHT:" + str(enemy))
		
		if gate:
			gate.track_enemy(enemy)
