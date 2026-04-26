class_name ExterminationLevelCondition extends LevelCondition

@onready var enemies : Array = get_tree().get_nodes_in_group("Enemy")
@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")

var last_enemy_death_position : Vector2

func _ready() -> void:
	CombatBus.enemyDied.connect(_check_for_annihilation)
	CombatBus.enemyDied.connect(_register_enemy_death_position)

func get_shock_position():
	return last_enemy_death_position

func _check_for_annihilation(enemy_node : BaseEnemy) -> void:
	enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		level_condition_reached.emit()

func _register_enemy_death_position(enemy_node : BaseEnemy) -> void:
	last_enemy_death_position = enemy_node.global_position
