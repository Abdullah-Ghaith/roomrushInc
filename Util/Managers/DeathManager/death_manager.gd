class_name DeathManager extends Node

@onready var enemies : Array = get_tree().get_nodes_in_group("enemy")
@onready var players : Node2D = get_tree().get_first_node_in_group("player")

func _ready():
	for enemy in enemies:
		if enemy.has_node("HitboxComponent"):
			print("true")
