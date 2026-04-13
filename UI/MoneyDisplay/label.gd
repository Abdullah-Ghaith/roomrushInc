extends Label

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var money_tween: Tween

var displayed_money: float:
	set(value):
		displayed_money = value
		text = str(round(displayed_money))

func _ready() -> void:
	displayed_money = CurrencyManager.money

	SignalBus.money_collected.connect(_handle_money_collected)
	SignalBus.money_spent.connect(_handle_money_spent)

func _handle_money_collected(amount: float) -> void:
	animation_player.play("money_collected")
	_tween_money_display()

func _handle_money_spent(amount: float) -> void:
	animation_player.play("money_spent")
	_tween_money_display()

func _tween_money_display() -> void:
	if money_tween:
		money_tween.kill()

	money_tween = create_tween()

	money_tween.tween_property(
		self,
		"displayed_money",
		CurrencyManager.money,
		0.4
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
