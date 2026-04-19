extends Control

@onready var enemy_list: VBoxContainer = %EnemyList
@onready var v_scroll_container: ScrollContainer = %VScrollContainer

@export var min_panels_on_screen : int = 2

var current_index := 0
var portraits := []

func _ready():
	portraits = enemy_list.get_children()
	_update_selection()


func _input(event):

	if event.is_action_pressed("ui_down"):
		select_next()

	if event.is_action_pressed("ui_up"):
		select_previous()

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select_next()

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			select_previous()

func select_next():
	current_index += 1
	current_index = clamp(current_index, 0, portraits.size() - 1)
	_update_selection()

func select_previous():
	current_index -= 1
	current_index = clamp(current_index, 0, portraits.size() - 1)
	_update_selection()

func _update_selection():
	for i in range(portraits.size()):
		portraits[i].set_active(i == current_index)

	var target = portraits[current_index]

	if current_index < portraits.size() - min_panels_on_screen:
		await get_tree().process_frame

		var target_center = target.position.y + target.size.y * 0.3 # 0.3 empirically determined as allowing full tile visible when active
		var container_center = v_scroll_container.size.y * 0.5

		var scroll_target = target_center - container_center

		var tween = create_tween()
		tween.tween_property(v_scroll_container, "scroll_vertical", scroll_target, 0.2)
