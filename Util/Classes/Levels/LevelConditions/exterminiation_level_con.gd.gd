class_name ExterminationLevelCondition extends LevelCondition

@onready var enemies : Array = get_tree().get_nodes_in_group("Enemy")
@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	CombatBus.enemyDied.connect(_check_for_annihilation)

func _check_for_annihilation() -> void:
	enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		level_condition_reached.emit()
