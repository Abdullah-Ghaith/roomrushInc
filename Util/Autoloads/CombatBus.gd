extends Node

signal enemyDied(enemy_node : BaseEnemy)
signal player_hit_landed(damage: float)  # emitted by bullets on enemy hits
