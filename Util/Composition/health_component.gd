extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0 :
	set(value):
		MAX_HEALTH = value
		health += value
@export var revive_on_death : bool = true
@export var revive_time : float = 0.3

var health             : float

signal damaged(amount)
signal died()
signal revived()

func _ready():
	health = MAX_HEALTH

func take_damage(attack: Attack) -> void:
	
	# Take Damage
	health -= attack.attack_damage
	damaged.emit(attack.attack_damage)

	if health <= 0:
		_die()

func revive() -> void:
	health = MAX_HEALTH
	revived.emit()

func _die() -> void:
	died.emit()
	if revive_on_death:
		await get_tree().create_timer(revive_time).timeout
		revive()
