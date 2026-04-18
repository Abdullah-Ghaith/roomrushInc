class_name ShooterEnemy extends BaseEnemy

@onready var shoot_timer: Timer = %ShootTimer
@onready var detection_range: Area2D = %DetectionRange
@onready var enemy_gun: EnemyGun = %EnemyGun

@export var shoot_cd_s: float = 0.5

func _ready() -> void:
	super._ready()
	shoot_timer.set_wait_time(shoot_cd_s)

func _clean_up_extended() -> void:
	detection_range.queue_free()
	shoot_timer.stop()
	enemy_gun.queue_free()

func _on_detection_range_body_entered(body: Node2D) -> void:
	if body == player:
		enemy_gun.set_target(player)
		shoot_timer.start(shoot_cd_s)

func _on_detection_range_body_exited(body: Node2D) -> void:
	if body == player:
		enemy_gun.set_target(null)
		shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	enemy_gun.shoot()
	shoot_timer.start(shoot_cd_s)
