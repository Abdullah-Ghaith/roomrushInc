class_name MoneyReq extends Control

signal freed

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var unlock_rich_text: RichTextLabel = %UnlockRichText
@onready var price: Label = %Price
@onready var margin_container: MarginContainer = %MarginContainer

@export var value : int  = 0

func _ready() -> void:
	price.text = _format_value(value)
	_update_margin_container()

func display_unlocked_text() -> void:
	unlock_rich_text.visible = true
	
func fade_out() -> void:
	animation_player.play("setup_fadeout")
	await animation_player.animation_finished
	await get_tree().create_timer(1.5).timeout # Allow user to enjoy the UNLOCKED!
	animation_player.play("fade_out")
	await animation_player.animation_finished
	freed.emit()
	queue_free()

func get_value() -> float:
	return value

func _format_value(val: float) -> String:
	if val >= 1_000_000:
		return str(snapped(val / 1_000_000.0, 0.1)).trim_suffix(".0") + "M"
	elif val >= 1_000:
		return str(snapped(val / 1_000.0, 0.1)).trim_suffix(".0") + "K"
	else:
		return str(int(val))

func _update_margin_container() -> void:
	var text = price.text
	var margin = 140  # default

	if text.ends_with("M"):
		if "." in text:
			margin = 106  # XX.XM
		else:
			margin = 175  # X.XM
			print("X,XM")
	elif text.ends_with("K"):
		var num = text.trim_suffix("K")
		if "." in num:
			if num.length() == 3:  # X.XK
				margin = 140
			elif num.length() == 4: # XX.XK
				margin = 120
			elif num.length() == 5:
				margin = 90        # XXX.K
		else:
			if num.length() == 1:
				margin = 175       # XK
			elif num.length() == 2:
				margin = 150       # XXK
			elif num.length() == 3:
				margin = 105       # XXXK
	else:
		margin = 142               # XXX
	margin_container.add_theme_constant_override("margin_left", margin)
