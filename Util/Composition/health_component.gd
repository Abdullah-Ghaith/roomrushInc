extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0 :
	set(value):
		if value > MAX_HEALTH:
			health += value
		MAX_HEALTH = value

@export var revive_on_death : bool = true
@export var revive_time : float = 0.3

var health             : float

signal damaged(amount: float, is_crit: bool)
signal half_hp
signal died()
signal revived()

func _ready():
	health = MAX_HEALTH

func take_damage(attack: Attack) -> void:
	var damage = attack.attack_damage
	var is_crit = 100*randf() < attack.crit_chance
	if is_crit:
		damage *= attack.crit_modifier
	
	# Take Damage
	health -= damage
	damaged.emit(damage, is_crit)
	
	if health <= MAX_HEALTH/2:
		half_hp.emit()
	
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
