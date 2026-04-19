class_name CategoryBar extends HBoxContainer

# Horizontal row of four buttons shown only for the Player entity.
# Emits category_selected when the player picks a tree category.

signal category_selected(category: String)

# Valid category strings — these must match the keys used in
# upgrade_table.gd's _player_tree_scenes dictionary.
const CATEGORIES := ["offence", "defence", "mobility", "economy"]

@onready var buttons := {
	"offence":  $OffenceButton,
	"defence":  $DefenceButton,
	"mobility": $MobilityButton,
	"economy":  $EconomyButton,
}

var active_category: String = "offence"


func _ready() -> void:
	for category in buttons:
		var btn: Button = buttons[category]
		btn.pressed.connect(_on_category_pressed.bind(category))
	_update_button_states()


func _on_category_pressed(category: String) -> void:
	active_category = category
	_update_button_states()
	category_selected.emit(category)


func _update_button_states() -> void:
	for category in buttons:
		# Visually distinguish the active category however you like in the editor
		# (flat/normal StyleBox swap, color modulate, etc.)
		buttons[category].disabled = (category == active_category)
